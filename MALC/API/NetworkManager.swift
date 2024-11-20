//
//  NetworkManager.swift
//  MALC
//
//  Created by Gao Tianrun on 19/4/24.
//

import Foundation
import SwiftUI
import AuthenticationServices
import KeychainAccess

@MainActor
class NetworkManager: NSObject, ObservableObject, ASWebAuthenticationPresentationContextProviding {
    @Published var isSignedIn = false
    @Published var user: User?
    static var shared = NetworkManager()
    let imageCache = NSCache<NSString, ImageCache>()
    var imageUrlMap = ThreadSafeDictionary<String, String>()
    let animeCache = ItemCache<Int, AnimeDetails>()
    let mangaCache = ItemCache<Int, MangaDetails>()
    private let jikanBaseApi = "https://api.jikan.moe/v4"
    private let malBaseApi = "https://api.myanimelist.net/v2"
    private let decoder: JSONDecoder
    private let client_id = Bundle.main.infoDictionary?["API_CLIENT_ID"] as! String
    private let keychain = Keychain(service: "mal-api")
    private let dateFormatter = ISO8601DateFormatter()
    
    override init() {
        // JSON Decoder
        decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        decoder.dateDecodingStrategy = .custom({ (decoder) -> Date in
            let container = try decoder.singleValueContainer()
            let dateStr = try container.decode(String.self)
            let len = dateStr.count
            var date: Date? = nil
            let monthOnlyFormatter = DateFormatter()
            monthOnlyFormatter.dateFormat = "yyyy-MM"
            let normalDateFormatter = DateFormatter()
            normalDateFormatter.dateFormat = "yyyy-MM-dd"
            let iso8601DateFormatter = ISO8601DateFormatter()
            if len == 7 {
                date = monthOnlyFormatter.date(from: dateStr)
            } else if len == 10 {
                date = normalDateFormatter.date(from: dateStr)
            } else {
                date = iso8601DateFormatter.date(from: dateStr)
            }
            guard let date_ = date else {
                throw DecodingError.dataCorruptedError(in: container, debugDescription: "Cannot decode date string \(dateStr)")
            }
            return date_
        })
        
        super.init()
        
        // Check if user is currently signed in and retrieve user profile
        Task {
            if keychain["accessToken"] != nil {
                DispatchQueue.main.async {
                    self.isSignedIn = true
                }
                print("Currently logged in")
                
                let user = try await self.getUserProfile()
                self.user = user
                imageUrlMap["userImage"] = user.picture
                await downloadImage(id: "userImage", urlString: user.picture)
            }
        }
    }
    
    // Get access token when user is signing in for the first time
    private func getAccessToken(_ code: String, _ codeVerifier: String) async throws -> Void {
        let url = URL(string: "https://myanimelist.net/v1/oauth2/token")!
        let parameters: Data = "client_id=\(client_id)&code=\(code)&code_verifier=\(codeVerifier)&grant_type=authorization_code".data(using: .utf8)!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField:"Content-Type")
        request.httpBody = parameters
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw NetworkError.badResponse
        }
        
        guard (200...299).contains(httpResponse.statusCode) else {
            throw NetworkError.badStatusCode(httpResponse.statusCode)
        }
        
        do {
            let responseObject = try decoder.decode(MALAuthenticationResponse.self, from: data)
            print(responseObject)
            DispatchQueue.main.async {
                self.keychain["accessToken"] = responseObject.accessToken
                self.keychain["refreshToken"] = responseObject.refreshToken
            }
        } catch {
            throw NetworkError.jsonParseFailure
        }
    }
    
    // Refresh access token using stored refresh token
    private func refreshToken() async throws -> Void {
        guard let token = keychain["refreshToken"] else {
            throw NetworkError.invalidRefreshToken
        }
        let url = URL(string: "https://myanimelist.net/v1/oauth2/token")!
        let parameters: Data = "client_id=\(client_id)&grant_type=refresh_token&refresh_token=\(token)".data(using: .utf8)!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField:"Content-Type")
        request.httpBody = parameters

        let (data, response) = try await URLSession.shared.data(for: request)
            
        guard let httpResponse = response as? HTTPURLResponse else {
            throw NetworkError.badResponse
        }
            
        guard httpResponse.statusCode != 403 else {
            throw NetworkError.invalidRefreshToken
        }
            
        guard (200...299).contains(httpResponse.statusCode) else {
            throw NetworkError.badStatusCode(httpResponse.statusCode)
        }
            
        do {
            let responseObject = try decoder.decode(MALAuthenticationResponse.self, from: data)
            print(responseObject)
            DispatchQueue.main.async {
                self.keychain["accessToken"] = responseObject.accessToken
                self.keychain["refreshToken"] = responseObject.refreshToken
            }
        } catch {
            throw NetworkError.jsonParseFailure
        }
    }
    
    // Sign in function with old completion handler syntax
    private func signInWithCompletion(_ pkce: String, completion: @escaping (Result<String, NetworkError>) -> Void) {
        let session = ASWebAuthenticationSession(url: URL(string: "https://myanimelist.net/v1/oauth2/authorize?response_type=code&client_id=\(client_id)&code_challenge=\(pkce)")!, callbackURLScheme: "malc") { callbackURL, error in
            if let error = error {
                DispatchQueue.main.async {
                    completion(.failure(.unknownError(error)))
                }
                return
            }

            if let callbackURL = callbackURL {
                if let urlComponents = URLComponents(url: callbackURL, resolvingAgainstBaseURL: true), let items = urlComponents.queryItems, let token = items[0].value {
                    completion(.success(token))
                }
            } else {
                completion(.failure(.badResponse))
            }
        }
        session.presentationContextProvider = self
        session.prefersEphemeralWebBrowserSession = true
        session.start()
    }
    
    // Sign in user (async wrapper for signInWithCompletion)
    func signIn() async throws -> Void {
        let pkce = PKCE.generateCodeVerifier()
        let token = try await withCheckedThrowingContinuation { continuation in
            signInWithCompletion(pkce) { result in
                switch result {
                case .success(let token):
                    continuation.resume(returning: token)
                case .failure(let error):
                    continuation.resume(throwing: error)
                }
            }
        }
        try await getAccessToken(token, pkce)
        let user = try await getUserProfile()
        DispatchQueue.main.async {
            self.isSignedIn = true
            self.user = user
        }
    }

    // Sign out user
    func signOut() {
        DispatchQueue.main.async {
            self.isSignedIn = false
            self.keychain["accessToken"] = nil
            self.keychain["refreshToken"] = nil
        }
    }
    
    // Generic MALApi GET request
    private func getMALResponse<T: Codable>(urlExtend: String, type: T.Type) async throws -> T {
        let url = URL(string: malBaseApi + urlExtend)!
        let config = URLSessionConfiguration.default
        config.httpAdditionalHeaders = [
            "X-MAL-CLIENT-ID": client_id
        ]
        if let token = keychain["accessToken"] {
            config.httpAdditionalHeaders?["Authorization"] = "Bearer \(token)"
        }
        let session = URLSession(configuration: config)
        let (data, response) = try await session.data(for: URLRequest(url: url))
            
        guard let httpResponse = response as? HTTPURLResponse else {
            throw NetworkError.badResponse
        }
            
        guard httpResponse.statusCode != 401 else {
            try await refreshToken()
            return try await getMALResponse(urlExtend: urlExtend, type: type)
        }
            
        guard (200...299).contains(httpResponse.statusCode) else {
            if httpResponse.statusCode == 404 {
                throw NetworkError.notFound
            } else {
                throw NetworkError.badStatusCode(httpResponse.statusCode)
            }
        }
            
        do {
            let decoded = try decoder.decode(type.self, from: data)
            return decoded
        } catch {
            throw NetworkError.jsonParseFailure
        }
    }
    
    // Generic JikanAPI GET request
    private func getJikanResponse<T: Codable>(urlExtend: String, type: T.Type) async throws -> T {
        let url = URL(string: jikanBaseApi + urlExtend)!
        let (data, response) = try await URLSession.shared.data(for: URLRequest(url: url))
            
        guard let httpResponse = response as? HTTPURLResponse else {
            throw NetworkError.badResponse
        }
            
        guard (200...299).contains(httpResponse.statusCode) else {
            throw NetworkError.badStatusCode(httpResponse.statusCode)
        }
            
        do {
            let decoded = try decoder.decode(T.self, from: data)
            return decoded
        } catch {
            throw NetworkError.jsonParseFailure
        }
    }
    
    // Delete anime or manga from user list
    private func deleteItem(id: Int, type: TypeEnum) async throws -> Void {
        let url = URL(string: malBaseApi + "/\(type)/\(id)/my_list_status")!
        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"
        if let token = keychain["accessToken"] {
            request.allHTTPHeaderFields = [
                "Authorization": "Bearer \(token)"
            ]
        }

        let (_, response) = try await URLSession.shared.data(for: request)
            
        guard let httpResponse = response as? HTTPURLResponse else {
            throw NetworkError.badResponse
        }
            
        guard httpResponse.statusCode != 401 else {
            try await refreshToken()
            return try await deleteItem(id: id, type: type)
        }
            
        guard (200...299).contains(httpResponse.statusCode) else {
            throw NetworkError.badStatusCode(httpResponse.statusCode)
        }
            
        print("deleted successfully")
    }
    
    func editUserAnime(id: Int, listStatus: AnimeListStatus) async throws -> Void {
        let url = URL(string: malBaseApi + "/anime/\(id)/my_list_status")!
        let parameters: Data = "status=\(listStatus.status!.toParameter())&score=\(listStatus.score)&num_watched_episodes=\(listStatus.numEpisodesWatched)".data(using: .utf8)!
        var request = URLRequest(url: url)
        request.httpMethod = "PATCH"
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField:"Content-Type")
        request.httpBody = parameters
        if let token = keychain["accessToken"] {
            request.allHTTPHeaderFields = [
                "Authorization": "Bearer \(token)"
            ]
        }

        let (_, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw NetworkError.badResponse
        }
            
        guard httpResponse.statusCode != 401 else {
            try await refreshToken()
            return try await editUserAnime(id: id, listStatus: listStatus)
        }
            
        guard (200...299).contains(httpResponse.statusCode) else {
            throw NetworkError.badStatusCode(httpResponse.statusCode)
        }
            
        print("edited successfully")
    }
    
    func editUserManga(id: Int, listStatus: MangaListStatus) async throws -> Void {
        let url = URL(string: malBaseApi + "/manga/\(id)/my_list_status")!
        let parameters: Data = "status=\(listStatus.status!.toParameter())&score=\(listStatus.score)&num_volumes_read=\(listStatus.numVolumesRead)&num_chapters_read=\(listStatus.numChaptersRead)".data(using: .utf8)!
        var request = URLRequest(url: url)
        request.httpMethod = "PATCH"
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField:"Content-Type")
        request.httpBody = parameters
        request.allHTTPHeaderFields = [
            "Authorization": "Bearer \(keychain["accessToken"] ?? "")"
        ]

        let (_, response) = try await URLSession.shared.data(for: request)
            
        guard let httpResponse = response as? HTTPURLResponse else {
            throw NetworkError.badResponse
        }
            
        guard httpResponse.statusCode != 401 else {
            try await refreshToken()
            return try await editUserManga(id: id, listStatus: listStatus)
        }
            
        guard (200...299).contains(httpResponse.statusCode) else {
            throw NetworkError.badStatusCode(httpResponse.statusCode)
        }
            
        print("edited successfully")
    }
    
    func getUserProfile() async throws -> User {
        let response = try await getMALResponse(urlExtend: "/users/@me", type: User.self)
        return response
    }
    
    func getUserAnimeList(page: Int, status: StatusEnum, sort: String) async throws -> [MALListAnime] {
        let response = try await getMALResponse(urlExtend: "/users/@me/animelist?fields=list_status,num_episodes\(status == .none ? "" : "&status=\(status.toParameter())")&sort=\(sort)&limit=50&offset=\((page - 1) * 50)", type: MALAnimeListResponse.self)
        return response.data
    }
    
    func getUserMangaList(page: Int, status: StatusEnum, sort: String) async throws -> [MALListManga] {
        let response = try await getMALResponse(urlExtend: "/users/@me/mangalist?fields=list_status,num_volumes,num_chapters\(status == .none ? "" : "&status=\(status.toParameter())")&sort=\(sort)&limit=50&offset=\((page - 1) * 50)", type: MALMangaListResponse.self)
        return response.data
    }
    
    func getUserAnimeSuggestionList() async throws -> [MALListAnime] {
        let response = try await getMALResponse(urlExtend: "/anime/suggestions", type: MALAnimeListResponse.self)
        return response.data
    }
    
    func getAnimeTopAiringList() async throws -> [MALListAnime] {
        let response = try await getMALResponse(urlExtend: "/anime/ranking?ranking_type=airing&limit=10", type: MALAnimeListResponse.self)
        return response.data
    }
    
    func getAnimeTopUpcomingList() async throws -> [MALListAnime] {
        let response = try await getMALResponse(urlExtend: "/anime/ranking?ranking_type=upcoming&limit=10", type: MALAnimeListResponse.self)
        return response.data
    }
    
    func getAnimeTopPopularList() async throws -> [MALListAnime] {
        let response = try await getMALResponse(urlExtend: "/anime/ranking?ranking_type=bypopularity&limit=10", type: MALAnimeListResponse.self)
        return response.data
    }
    
    func getMangaTopPopularList() async throws -> [MALListManga] {
        let response = try await getMALResponse(urlExtend: "/manga/ranking?ranking_type=bypopularity&limit=10", type: MALMangaListResponse.self)
        return response.data
    }
    
    func deleteUserAnime(id: Int) async throws -> Void {
        return try await deleteItem(id: id, type: .anime)
    }
    
    func deleteUserManga(id: Int) async throws -> Void {
        return try await deleteItem(id: id, type: .manga)
    }
    
    func getTopAnimeList(page: Int) async throws -> [MALListAnime] {
        let response = try await getMALResponse(urlExtend: "/anime/ranking?ranking_type=all&limit=50&offset=\((page - 1) * 50)", type: MALAnimeListResponse.self)
        return response.data
    }
    
    func getTopMangaList(page: Int) async throws -> [MALListManga] {
        let response = try await getMALResponse(urlExtend: "/manga/ranking?ranking_type=all&limit=50&offset=\((page - 1) * 50)", type: MALMangaListResponse.self)
        return response.data
    }
    
    func getSeasonAnimeList(season: String, year: Int, page: Int) async throws -> [MALListAnime] {
        let response = try await getMALResponse(urlExtend: "/anime/season/\(year)/\(season)?fields=start_season&sort=anime_num_list_users&limit=50&offset=\((page - 1) * 50)", type: MALAnimeListResponse.self)
        return response.data
    }
    
    func searchAnime(anime: String, page: Int) async throws -> [MALListAnime] {
        let response = try await getMALResponse(urlExtend: "/anime?q=\(anime)&limit=50&offset=\((page - 1) * 50)", type: MALAnimeListResponse.self)
        return response.data
    }
    
    func searchManga(manga: String, page: Int) async throws -> [MALListManga] {
        let response = try await getMALResponse(urlExtend: "/manga?q=\(manga)&limit=50&offset=\((page - 1) * 50)", type: MALMangaListResponse.self)
        return response.data
    }
    
    func getAnimeList(urlExtend: String, page: Int) async throws -> [JikanListItem] {
        let response = try await getJikanResponse(urlExtend: "/anime?" + urlExtend + "&page=\(page)", type: JikanListResponse.self)
        return response.data
    }
    
    func getMangaList(urlExtend: String, page: Int) async throws -> [JikanListItem] {
        let response = try await getJikanResponse(urlExtend: "/manga?" + urlExtend + "&page=\(page)", type: JikanListResponse.self)
        return response.data
    }
    
    func getAnimeDetails(id: Int) async throws -> Anime {
        let response = try await getMALResponse(urlExtend: "/anime/\(id)?fields=alternative_titles,start_date,end_date,synopsis,mean,rank,media_type,status,genres,my_list_status,num_episodes,start_season,broadcast,source,average_episode_duration,rating,studios,opening_themes,ending_themes,videos,recommendations", type: Anime.self)
        return response
    }
    
    func getAnimeCharacters(id: Int) async throws -> [ListCharacter] {
        let response = try await getJikanResponse(urlExtend: "/anime/\(id)/characters", type: JikanCharactersListResponse.self)
        return response.data
    }
    
    func getCharacterDetails(id: Int) async throws -> Character {
        let response = try await getJikanResponse(urlExtend: "/characters/\(id)/full", type: JikanCharacterDetailsResponse.self)
        return response.data
    }
    
    func getAnimeRelations(id: Int) async throws -> [Related] {
        let response = try await getJikanResponse(urlExtend: "/anime/\(id)/relations", type: JikanRelationsListResponse.self)
        return response.data
    }
    
    func getAnimeStaff(id: Int) async throws -> [Staff] {
        let response = try await getJikanResponse(urlExtend: "/anime/\(id)/staff", type: JikanStaffListResponse.self)
        return response.data
    }
    
    func getPersonDetails(id: Int) async throws -> Person {
        let response = try await getJikanResponse(urlExtend: "/people/\(id)/full", type: JikanPersonDetailsResponse.self)
        return response.data
    }
    
    func getMangaDetails(id: Int) async throws -> Manga {
        let response = try await getMALResponse(urlExtend: "/manga/\(id)?fields=alternative_titles,start_date,end_date,synopsis,mean,rank,media_type,status,genres,my_list_status,num_volumes,num_chapters,recommendations", type: Manga.self)
        return response
    }
    
    func getMangaCharacters(id: Int) async throws -> [ListCharacter] {
        let response = try await getJikanResponse(urlExtend: "/manga/\(id)/characters", type: JikanCharactersListResponse.self)
        return response.data
    }
    
    func getMangaRelations(id: Int) async throws -> [Related] {
        let response = try await getJikanResponse(urlExtend: "/manga/\(id)/relations", type: JikanRelationsListResponse.self)
        return response.data
    }
    
    // Download image
    private func download(id: String, imageUrl: URL) async throws -> Void {
        let (localUrl, response) = try await URLSession.shared.download(for: URLRequest(url: imageUrl))
            
        guard let httpResponse = response as? HTTPURLResponse else {
            throw NetworkError.badResponse
        }
            
        guard (200...299).contains(httpResponse.statusCode) else {
            throw NetworkError.badStatusCode(httpResponse.statusCode)
        }
            
        do {
            let data = try Data(contentsOf: localUrl)
            let cache = ImageCache()
            cache.image = data as NSData
            self.imageCache.setObject(cache, forKey: id as NSString)
        } catch let error {
            throw NetworkError.unknownError(error)
        }
    }
    
    // Retrieve image from image cache
    func getImage(id: String) -> Image {
        if let cache = imageCache.object(forKey: id as NSString) {
            if let image = UIImage(data: cache.image as Data) {
                return Image(uiImage: image)
            }
        }
        return Image(uiImage: UIImage(named: "placeholder.jpg")!)
    }
    
    // Wrapper function for download
    func downloadImage(id: String, urlString: String?) async -> Void {
        if let urlString = urlString {
            do {
                imageUrlMap[id] = urlString
                let url = URL(string: urlString)!
                return try await download(id: id, imageUrl: url)
            } catch {
                print("Error downloading image")
            }
        }
    }
    
    func presentationAnchor(for session: ASWebAuthenticationSession) -> ASPresentationAnchor {
        return ASPresentationAnchor()
    }
}
