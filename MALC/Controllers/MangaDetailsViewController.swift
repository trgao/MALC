//
//  MangaDetailsViewController.swift
//  MALC
//
//  Created by Gao Tianrun on 12/5/24.
//

import Foundation

@MainActor
class MangaDetailsViewController: ObservableObject {
    @Published var manga: Manga?
    @Published var characters: [ListCharacter] = []
    @Published var relations: [Related] = []
    @Published var isInitialLoading = true
    @Published var isLoading = false
    @Published var isLoadingError = false
    private let id: Int
    let networker = NetworkManager.shared
    
    init(_ id: Int) {
        self.id = id
        if let mangaDetails = networker.mangaCache[id] {
            self.manga = mangaDetails.manga
            self.characters = mangaDetails.characters
            self.relations = mangaDetails.relations
            self.isInitialLoading = false
        } else {
            Task {
                do {
                    try await getMangaDetails()
                    isInitialLoading = false
                } catch {
                    isLoadingError = true
                    isInitialLoading = false
                }
            }
        }
    }
    
    private func getMangaDetails() async throws -> Void {
        let manga = try await networker.getMangaDetails(id: id)
        let characterList = try await networker.getMangaCharacters(id: id)
        let relationList = try await networker.getMangaRelations(id: id)
        self.manga = manga
        self.characters = characterList
        self.relations = relationList
        networker.mangaCache[id] = MangaDetails(manga: manga, characters: characterList, relations: relationList)
        
        await withTaskGroup(of: Void.self) { taskGroup in
            for item in manga.recommendations.prefix(10) {
                taskGroup.addTask {
                    await self.networker.downloadImage(id: "manga\(item.id)", urlString: item.node.mainPicture?.medium)
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
    
    func refresh() async -> Void {
        isLoading = true
        isLoadingError = false
        do {
            try await getMangaDetails()
            isLoading = false
        } catch {
            isLoading = false
            isLoadingError = true
        }
    }
}

