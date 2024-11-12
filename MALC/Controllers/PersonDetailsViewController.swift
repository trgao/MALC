//
//  PersonDetailsViewController.swift
//  MALC
//
//  Created by Gao Tianrun on 21/5/24.
//

import Foundation

@MainActor
class PersonDetailsViewController: ObservableObject {
    @Published var person: Person?
    @Published var isLoading = true
    @Published var isLoadingError = false
    private let id: Int
    let networker = NetworkManager.shared
    
    init(_ id: Int) {
        self.id = id
        Task {
            do {
                let person = try await networker.getPersonDetails(id: id)
                self.person = person
                await withTaskGroup(of: Void.self) { taskGroup in
                    for voice in person.voices {
                        taskGroup.addTask {
                            await self.networker.downloadImage(id: "anime\(voice.anime.id)", urlString: voice.anime.images?.jpg.imageUrl)
                        }
                    }
                    for anime in person.anime {
                        taskGroup.addTask {
                            await self.networker.downloadImage(id: "anime\(anime.id)", urlString: anime.anime.images?.jpg.imageUrl)
                        }
                    }
                    for manga in person.manga {
                        taskGroup.addTask {
                            await self.networker.downloadImage(id: "manga\(manga.id)", urlString: manga.manga.images?.jpg.imageUrl)
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
