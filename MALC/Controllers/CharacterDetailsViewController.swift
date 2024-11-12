//
//  CharacterDetailsViewController.swift
//  MALC
//
//  Created by Gao Tianrun on 2/5/24.
//

import Foundation

@MainActor
class CharacterDetailsViewController: ObservableObject {
    @Published var character: Character?
    @Published var isLoading = true
    @Published var isLoadingError = false
    private let id: Int
    let networker = NetworkManager.shared
    
    init(_ id: Int) {
        self.id = id
        Task {
            do {
                let character = try await networker.getCharacterDetails(id: id)
                self.character = character

                await withTaskGroup(of: Void.self) { taskGroup in
                    for anime in character.anime {
                        taskGroup.addTask {
                            await self.networker.downloadImage(id: "anime\(anime.id)", urlString: anime.anime.images?.jpg.imageUrl)
                        }
                    }
                    for manga in character.manga {
                        taskGroup.addTask {
                            await self.networker.downloadImage(id: "manga\(manga.id)", urlString: manga.manga.images?.jpg.imageUrl)
                        }
                    }
                    for voice in character.voices {
                        taskGroup.addTask {
                            await self.networker.downloadImage(id: "person\(voice.id)", urlString: voice.person.images?.jpg.imageUrl)
                        }
                    }
                }
                
                isLoading = false
            } catch {
                isLoading = false
                isLoadingError = true
            }
        }
    }
}
