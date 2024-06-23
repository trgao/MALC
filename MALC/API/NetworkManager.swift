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

class NetworkManager: NSObject, ObservableObject, ASWebAuthenticationPresentationContextProviding {
    @Published var isSignedIn = false
    @Published var isExpired = false
    @Published var user: User?
    static var shared = NetworkManager()
    let imageCache = NSCache<NSString, ImageCache>()
    private var defaultSession = URLSession(configuration: URLSessionConfiguration.default)
    private let jikanBaseApi = "https://api.jikan.moe/v4"
    private let malBaseApi = "https://api.myanimelist.net/v2"
    private let decoder: JSONDecoder
    private let client_id = Bundle.main.infoDictionary?["API_CLIENT_ID"] as! String
    private let keychain = Keychain(service: "mal-api")
    private let dateFormatter = ISO8601DateFormatter()
    
    override init() {
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
        if keychain["accessToken"] != nil {
            DispatchQueue.main.async {
                self.isSignedIn = true
            }
            print("Currently logged in")
            checkExpired()
            self.getUserProfile(completion: { user, error in
                if let user = user {
                    self.user = user
                }
            })
        }
    }
    
    private func getAccessToken(_ code: String, _ codeVerifier: String, completion: @escaping (Error?) -> Void) {
        let url = URL(string: "https://myanimelist.net/v1/oauth2/token")!
        let parameters: Data = "client_id=\(client_id)&code=\(code)&code_verifier=\(codeVerifier)&grant_type=authorization_code".data(using: .utf8)!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField:"Content-Type")
        request.httpBody = parameters

        let task = URLSession.shared.dataTask(with: request) { (data: Data?, response: URLResponse?, error: Error?) in
            if let error = error {
                DispatchQueue.main.async {
                   completion(error)
               }
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse else {
                DispatchQueue.main.async {
                   completion(NetworkError.badResponse)
                }
                return
            }
            
            guard (200...299).contains(httpResponse.statusCode) else {
                DispatchQueue.main.async {
                   completion(NetworkError.badStatusCode)
                }
                return
            }
            
            if let data = data {
                do {
                    let responseObject = try self.decoder.decode(MALAuthenticationResponse.self, from: data)
                    print(responseObject)
                    DispatchQueue.main.async {
                        self.keychain["accessToken"] = responseObject.accessToken
                        self.keychain["refreshToken"] = responseObject.refreshToken
                        self.keychain["expiresIn"] = String(responseObject.expiresIn)
                        self.keychain["retrieveDate"] = self.dateFormatter.string(from: Date())
                        completion(nil)
                    }
                } catch {
                    print(error)
                    DispatchQueue.main.async {
                        completion(error)
                    }
                }
            }
        }
        task.resume()
    }
    
    private func checkExpired() {
        if Date() - dateFormatter.date(from: keychain["retrieveDate"]!)! >= Double(keychain["expiresIn"]!)! {
            signOut()
            DispatchQueue.main.async {
                self.isExpired = true
            }
        }
    }
    
    func signIn(completion: @escaping (Error?) -> Void) {
        let pkce = PKCE.generateCodeVerifier()
        let session = ASWebAuthenticationSession(url: URL(string: "https://myanimelist.net/v1/oauth2/authorize?response_type=code&client_id=\(client_id)&code_challenge=\(pkce)")!, callbackURLScheme: "malc") { callbackURL, error in
            if let error = error {
                DispatchQueue.main.async {
                    completion(error)
                }
                return
            }
            if let callbackURL = callbackURL {
                if let urlComponents = URLComponents(url: callbackURL, resolvingAgainstBaseURL: true), let items = urlComponents.queryItems {
                    self.getAccessToken(items[0].value!, pkce) { error in
                        if let error = error {
                            DispatchQueue.main.async {
                               completion(error)
                            }
                            return
                        }
                        self.getUserProfile(completion: { user, error in
                            if let user = user {
                                DispatchQueue.main.async {
                                    self.isSignedIn = true
                                    self.user = user
                                    completion(nil)
                                }
                                return
                            }
                            DispatchQueue.main.async {
                               completion(error)
                           }
                        })
                    }
                }
            }
        }
        session.presentationContextProvider = self
        session.prefersEphemeralWebBrowserSession = true
        session.start()
    }

    func signOut() {
        DispatchQueue.main.async {
            self.isSignedIn = false
            self.keychain["accessToken"] = nil
            self.keychain["refreshToken"] = nil
            self.keychain["expiresIn"] = nil
            self.keychain["retrieveDate"] = nil
        }
    }
    
    func getAccessToken() {
        checkExpired()
        // still need to check if get 401 unauthorized code to see if need to refresh token
    }
    
    private func getMALResponse<T: Codable>(urlExtend: String, type: T.Type, completion: @escaping (T?, Error?) -> Void) {
        let url = URL(string: malBaseApi + urlExtend)!
        let config = URLSessionConfiguration.default
        config.httpAdditionalHeaders = [
            "X-MAL-CLIENT-ID": client_id,
            "Authorization": "Bearer \(keychain["accessToken"] ?? "")"
        ]
        let session = URLSession(configuration: config)
        let task = session.dataTask(with: url) { (data: Data?, response: URLResponse?, error: Error?) in
            if let error = error {
                DispatchQueue.main.async {
                    completion(nil, error)
                }
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse else {
                DispatchQueue.main.async {
                    completion(nil, NetworkError.badResponse)
                }
                return
            }
            
            guard (200...299).contains(httpResponse.statusCode) else {
                DispatchQueue.main.async {
                    if httpResponse.statusCode == 404 {
                        completion(nil, NetworkError.notFound)
                    } else {
                        completion(nil, NetworkError.badStatusCode)
                    }
                }
                return
            }
            
            guard let data = data else {
                DispatchQueue.main.async {
                    completion(nil, NetworkError.badData)
                }
                return
            }
            
            do {
                let decoded = try self.decoder.decode(type.self, from: data)
                DispatchQueue.main.async {
                    completion(decoded, nil)
                }
            } catch let error {
                DispatchQueue.main.async {
                    completion(nil, error)
                }
            }
        }
        task.resume()
    }
    
    func getJikanResponse<T: Codable>(urlExtend: String, type: T.Type, completion: @escaping (T?, Error?) -> Void) {
        let url = URL(string: jikanBaseApi + urlExtend)!
        let task = defaultSession.dataTask(with: url) { (data: Data?, response: URLResponse?, error: Error?) in
            if let error = error {
                DispatchQueue.main.async {
                    completion(nil, error)
                }
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse else {
                DispatchQueue.main.async {
                    completion(nil, NetworkError.badResponse)
                }
                return
            }
            
            guard (200...299).contains(httpResponse.statusCode) else {
                DispatchQueue.main.async {
                    completion(nil, NetworkError.badStatusCode)
                }
                return
            }
            
            guard let data = data else {
                DispatchQueue.main.async {
                    completion(nil, NetworkError.badData)
                }
                return
            }
            
            do {
                let decoded = try self.decoder.decode(T.self, from: data)
                DispatchQueue.main.async {
                    completion(decoded, nil)
                }
            } catch let error {
                DispatchQueue.main.async {
                    completion(nil, error)
                }
            }
        }
        task.resume()
    }
    
    private func deleteItem(id: Int, type: TypeEnum, completion: @escaping (Error?) -> Void) {
        let url = URL(string: malBaseApi + "/\(type)/\(id)/my_list_status")!
        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"
        request.allHTTPHeaderFields = [
            "Authorization": "Bearer \(keychain["accessToken"] ?? "")"
        ]

        let task = URLSession.shared.dataTask(with: request) { (data: Data?, response: URLResponse?, error: Error?) in
            if let error = error {
                DispatchQueue.main.async {
                   completion(error)
               }
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse else {
                DispatchQueue.main.async {
                   completion(NetworkError.badResponse)
                }
                return
            }
            
            guard (200...299).contains(httpResponse.statusCode) else {
                DispatchQueue.main.async {
                   completion(NetworkError.badStatusCode)
                }
                return
            }
            
            print("deleted successfully")
            completion(nil)
        }
        task.resume()
    }
    
    func editUserAnime(id: Int, listStatus: AnimeListStatus, completion: @escaping (Error?) -> Void) {
        let url = URL(string: malBaseApi + "/anime/\(id)/my_list_status")!
        let parameters: Data = "status=\(listStatus.status!.toParameter())&score=\(listStatus.score)&num_watched_episodes=\(listStatus.numEpisodesWatched)".data(using: .utf8)!
        var request = URLRequest(url: url)
        request.httpMethod = "PATCH"
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField:"Content-Type")
        request.httpBody = parameters
        request.allHTTPHeaderFields = [
            "Authorization": "Bearer \(keychain["accessToken"] ?? "")"
        ]

        let task = URLSession.shared.dataTask(with: request) { (data: Data?, response: URLResponse?, error: Error?) in
            if let error = error {
                DispatchQueue.main.async {
                   completion(error)
               }
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse else {
                DispatchQueue.main.async {
                   completion(NetworkError.badResponse)
                }
                return
            }
            
            guard (200...299).contains(httpResponse.statusCode) else {
                DispatchQueue.main.async {
                   completion(NetworkError.badStatusCode)
                }
                return
            }
            
            print("edited successfully")
            completion(nil)
        }
        task.resume()
    }
    
    func editUserManga(id: Int, listStatus: MangaListStatus, completion: @escaping (Error?) -> Void) {
        let url = URL(string: malBaseApi + "/manga/\(id)/my_list_status")!
        let parameters: Data = "status=\(listStatus.status!.toParameter())&score=\(listStatus.score)&num_volumes_read=\(listStatus.numVolumesRead)&num_chapters_read=\(listStatus.numChaptersRead)".data(using: .utf8)!
        var request = URLRequest(url: url)
        request.httpMethod = "PATCH"
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField:"Content-Type")
        request.httpBody = parameters
        request.allHTTPHeaderFields = [
            "Authorization": "Bearer \(keychain["accessToken"] ?? "")"
        ]

        let task = URLSession.shared.dataTask(with: request) { (data: Data?, response: URLResponse?, error: Error?) in
            if let error = error {
                DispatchQueue.main.async {
                   completion(error)
               }
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse else {
                DispatchQueue.main.async {
                   completion(NetworkError.badResponse)
                }
                return
            }
            
            guard (200...299).contains(httpResponse.statusCode) else {
                DispatchQueue.main.async {
                   completion(NetworkError.badStatusCode)
                }
                return
            }
            
            print("edited successfully")
            completion(nil)
        }
        task.resume()
    }
    
    func getUserProfile(completion: @escaping (User?, Error?) -> Void) {
        getMALResponse(urlExtend: "/users/@me?fields=mainPicture", type: User.self, completion: completion)
    }
    
    func getUserAnimeList(page: Int, status: StatusEnum, sort: String, completion: @escaping (MALAnimeListResponse?, Error?) -> Void) {
        getMALResponse(urlExtend: "/users/@me/animelist?fields=list_status,num_episodes\(status == .none ? "" : "&status=\(status.toParameter())")&sort=\(sort)&limit=50&offset=\((page - 1) * 50)&nsfw=true", type: MALAnimeListResponse.self, completion: completion)
    }
    
    func getUserMangaList(page: Int, status: StatusEnum, sort: String, completion: @escaping (MALMangaListResponse?, Error?) -> Void) {
        getMALResponse(urlExtend: "/users/@me/mangalist?fields=list_status,num_volumes,num_chapters\(status == .none ? "" : "&status=\(status.toParameter())")&sort=\(sort)&limit=50&offset=\((page - 1) * 50)&nsfw=true", type: MALMangaListResponse.self, completion: completion)
    }
    
    func getUserAnimeSuggestionList(completion: @escaping (MALAnimeListResponse?, Error?) -> Void) {
        getMALResponse(urlExtend: "/anime/suggestions", type: MALAnimeListResponse.self, completion: completion)
    }
    
    func getAnimeTopAiringList(completion: @escaping (MALAnimeListResponse?, Error?) -> Void) {
        getMALResponse(urlExtend: "/anime/ranking?ranking_type=airing&limit=10", type: MALAnimeListResponse.self, completion: completion)
    }
    
    func getAnimeTopUpcomingList(completion: @escaping (MALAnimeListResponse?, Error?) -> Void) {
        getMALResponse(urlExtend: "/anime/ranking?ranking_type=upcoming&limit=10", type: MALAnimeListResponse.self, completion: completion)
    }
    
    func getAnimeTopPopularList(completion: @escaping (MALAnimeListResponse?, Error?) -> Void) {
        getMALResponse(urlExtend: "/anime/ranking?ranking_type=bypopularity&limit=10", type: MALAnimeListResponse.self, completion: completion)
    }
    
    func getMangaTopPopularList(completion: @escaping (MALMangaListResponse?, Error?) -> Void) {
        getMALResponse(urlExtend: "/manga/ranking?ranking_type=bypopularity&limit=10", type: MALMangaListResponse.self, completion: completion)
    }
    
    func deleteUserAnime(id: Int, completion: @escaping (Error?) -> Void) {
        deleteItem(id: id, type: .anime, completion: completion)
    }
    
    func deleteUserManga(id: Int, completion: @escaping (Error?) -> Void) {
        deleteItem(id: id, type: .manga, completion: completion)
    }
    
    func getTopAnimeList(page: Int, completion: @escaping (MALAnimeListResponse?, Error?) -> Void) {
        getMALResponse(urlExtend: "/anime/ranking?ranking_type=all&limit=50&offset=\((page - 1) * 50)", type: MALAnimeListResponse.self, completion: completion)
    }
    
    func getTopMangaList(page: Int, completion: @escaping (MALMangaListResponse?, Error?) -> Void) {
        getMALResponse(urlExtend: "/manga/ranking?ranking_type=all&limit=50&offset=\((page - 1) * 50)", type: MALMangaListResponse.self, completion: completion)
    }
    
    func getSeasonAnimeList(season: String, year: Int, page: Int, completion: @escaping (MALAnimeListResponse?, Error?) -> Void) {
        getMALResponse(urlExtend: "/anime/season/\(year)/\(season)?fields=start_season&sort=anime_num_list_users&limit=50&offset=\((page - 1) * 50)&nsfw=true", type: MALAnimeListResponse.self, completion: completion)
    }
    
    func searchAnime(anime: String, page: Int, completion: @escaping (MALAnimeListResponse?, Error?) -> Void) {
        getMALResponse(urlExtend: "/anime?q=\(anime)&limit=50&offset=\((page - 1) * 50)&nsfw=true", type: MALAnimeListResponse.self, completion: completion)
    }
    
    func searchManga(manga: String, page: Int, completion: @escaping (MALMangaListResponse?, Error?) -> Void) {
        getMALResponse(urlExtend: "/manga?q=\(manga)&limit=50&offset=\((page - 1) * 50)&nsfw=true", type: MALMangaListResponse.self, completion: completion)
    }
    
    func getAnimeList(urlExtend: String, page: Int, completion: @escaping (JikanListResponse?, Error?) -> Void) {
        getJikanResponse(urlExtend: "/anime?" + urlExtend + "&page=\(page)", type: JikanListResponse.self, completion: completion)
    }
    
    func getMangaList(urlExtend: String, page: Int, completion: @escaping (JikanListResponse?, Error?) -> Void) {
        getJikanResponse(urlExtend: "/manga?" + urlExtend + "&page=\(page)", type: JikanListResponse.self, completion: completion)
    }
    
    func getAnimeDetails(id: Int, completion: @escaping (Anime?, Error?) -> Void) {
        getMALResponse(urlExtend: "/anime/\(id)?fields=alternative_titles,start_date,end_date,synopsis,mean,rank,media_type,status,genres,my_list_status,num_episodes,start_season,broadcast,source,average_episode_duration,rating,studios,opening_themes,ending_themes,videos,recommendations", type: Anime.self, completion: completion)
    }
    
    func getAnimeCharacters(id: Int, completion: @escaping (JikanCharactersListResponse?, Error?) -> Void) {
        getJikanResponse(urlExtend: "/anime/\(id)/characters", type: JikanCharactersListResponse.self, completion: completion)
    }
    
    func getCharacterDetails(id: Int, completion: @escaping (JikanCharacterDetailsResponse?, Error?) -> Void) {
        getJikanResponse(urlExtend: "/characters/\(id)/full", type: JikanCharacterDetailsResponse.self, completion: completion)
    }
    
    func getAnimeRelations(id: Int, completion: @escaping (JikanRelationsListResponse?, Error?) -> Void) {
        getJikanResponse(urlExtend: "/anime/\(id)/relations", type: JikanRelationsListResponse.self, completion: completion)
    }
    
    func getAnimeStaff(id: Int, completion: @escaping (JikanStaffListResponse?, Error?) -> Void) {
        getJikanResponse(urlExtend: "/anime/\(id)/staff", type: JikanStaffListResponse.self, completion: completion)
    }
    
    func getPersonDetails(id: Int, completion: @escaping (JikanPersonDetailsResponse?, Error?) -> Void) {
        getJikanResponse(urlExtend: "/people/\(id)/full", type: JikanPersonDetailsResponse.self, completion: completion)
    }
    
    func getMangaDetails(id: Int, completion: @escaping (Manga?, Error?) -> Void) {
        getMALResponse(urlExtend: "/manga/\(id)?fields=alternative_titles,start_date,end_date,synopsis,mean,rank,media_type,status,genres,my_list_status,num_volumes,num_chapters,recommendations", type: Manga.self, completion: completion)
    }
    
    func getMangaCharacters(id: Int, completion: @escaping (JikanCharactersListResponse?, Error?) -> Void) {
        getJikanResponse(urlExtend: "/manga/\(id)/characters", type: JikanCharactersListResponse.self, completion: completion)
    }
    
    func getMangaRelations(id: Int, completion: @escaping (JikanRelationsListResponse?, Error?) -> Void) {
        getJikanResponse(urlExtend: "/manga/\(id)/relations", type: JikanRelationsListResponse.self, completion: completion)
    }
    
    private func download(id: String, imageUrl: URL, completion: @escaping (Data?, Error?) -> Void) {
        let task = defaultSession.downloadTask(with: imageUrl) { (localUrl: URL?, response: URLResponse?, error: Error?) in
            if let error = error {
                DispatchQueue.main.async {
                    completion(nil, error)
                }
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse else {
                DispatchQueue.main.async {
                    completion(nil, NetworkError.badResponse)
                }
                return
            }
            
            guard (200...299).contains(httpResponse.statusCode) else {
                DispatchQueue.main.async {
                    completion(nil, NetworkError.badStatusCode)
                }
                return
            }
            
            guard let localUrl = localUrl else {
                DispatchQueue.main.async {
                    completion(nil, NetworkError.badLocalUrl)
                }
                return
            }
            
            do {
                let data = try Data(contentsOf: localUrl)
                let cache = ImageCache()
                cache.image = data as NSData
                self.imageCache.setObject(cache, forKey: id as NSString)
                DispatchQueue.main.async {
                    completion(data, nil)
                }
            } catch let error {
                DispatchQueue.main.async {
                    completion(nil, error)
                }
            }
        }
        task.resume()
    }
    
    func getImage(id: String) -> Image {
        if let cache = imageCache.object(forKey: id as NSString) {
            if let image = UIImage(data: cache.image as Data) {
                return Image(uiImage: image)
            }
        }
        return Image(uiImage: UIImage(named: "placeholder.jpg")!)
    }
    
    func downloadImage(id: String, urlString: String?, completion: @escaping (Data?, Error?) -> Void) {
        if let urlString = urlString {
            let url = URL(string: urlString)!
            download(id: id, imageUrl: url, completion: completion)
            return
        }
        DispatchQueue.main.async {
            completion(nil, NetworkError.noImage)
        }
    }
    
    func presentationAnchor(for session: ASWebAuthenticationSession) -> ASPresentationAnchor {
        return ASPresentationAnchor()
    }
}

enum NetworkError: Error {
    case badResponse, badStatusCode, badData, badLocalUrl, noImage, notFound
}

class ImageCache: NSObject, NSDiscardableContent {
    public var image: NSData!

    func beginContentAccess() -> Bool {
        return true
    }

    func endContentAccess() {}

    func discardContentIfPossible() {}

    func isContentDiscarded() -> Bool {
        return false
    }
}
