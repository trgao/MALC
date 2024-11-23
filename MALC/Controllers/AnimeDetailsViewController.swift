//
//  AnimeDetailsViewController.swift
//  MALC
//
//  Created by Gao Tianrun on 29/4/24.
//

import Foundation

@MainActor
class AnimeDetailsViewController: ObservableObject {
    @Published var anime: Anime?
    @Published var characters: [ListCharacter] = []
    @Published var relations: [Related] = []
    @Published var isInitialLoading = true
    @Published var isLoading = false
    @Published var isLoadingError = false
    private let id: Int
    let networker = NetworkManager.shared
    
    init(_ id: Int) {
        self.id = id
        
        // Check if anime details is already in cache
        if let animeDetails = networker.animeCache[id] {
            self.anime = animeDetails.anime
            self.characters = animeDetails.characters
            self.relations = animeDetails.relations
            self.isInitialLoading = false
        } else {
            Task {
                do {
                    try await getAnimeDetails()
                    
                    isInitialLoading = false
                } catch {
                    isLoadingError = true
                    isInitialLoading = false
                }
            }
        }
    }
    
    // Load all anime details
    private func getAnimeDetails() async throws -> Void {
        let anime = try await networker.getAnimeDetails(id: id)
        let characterList = try await networker.getAnimeCharacters(id: id)
        let relationList = try await networker.getAnimeRelations(id: id)
        self.anime = anime
        self.characters = characterList
        self.relations = relationList
        networker.animeCache[id] = AnimeDetails(anime: anime, characters: characterList, relations: relationList)
        
        await withTaskGroup(of: Void.self) { taskGroup in
            for item in anime.recommendations.prefix(10) {
                taskGroup.addTask {
                    await self.networker.downloadImage(id: "anime\(item.id)", urlString: item.node.mainPicture?.medium)
                }
            }
            
            for character in characterList.prefix(10) {
                taskGroup.addTask {
                    await self.networker.downloadImage(id: "character\(character.id)", urlString: character.character.images?.jpg.imageUrl)
                }
            }
            
            for relation in relationList.flatMap({ $0.entry }).prefix(10) {
                taskGroup.addTask {
                    do {
                        if relation.type == .anime {
                            let anime = try await self.networker.getAnimeDetails(id: relation.id)
                            await self.networker.downloadImage(id: "anime\(relation.id)", urlString: anime.mainPicture?.medium)
                        } else if relation.type == .manga {
                            let manga = try await self.networker.getMangaDetails(id: relation.id)
                            await self.networker.downloadImage(id: "manga\(relation.id)", urlString: manga.mainPicture?.medium)
                        }
                    } catch {
                        print("Some unknown error occurred")
                    }
                }
            }
        }
    }
    
    // Refresh the current anime details page
    func refresh() async -> Void {
        isLoading = true
        isLoadingError = false
        do {
            try await getAnimeDetails()
            isLoading = false
        } catch {
            isLoadingError = true
            isLoading = false
        }
    }
}
