//
//  AnimeDetailsViewController.swift
//  MALC
//
//  Created by Gao Tianrun on 29/4/24.
//

import Foundation

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
        DispatchQueue.global().async {
            let group = DispatchGroup()
            group.enter()
            self.networker.getAnimeDetails(id: id) { anime, error in
                if let anime = anime {
                    self.anime = anime
                    for item in anime.recommendations {
                        group.enter()
                        self.networker.downloadImage(id: "anime\(item.id)", urlString: item.node.mainPicture?.medium) { data, error in
                            group.leave()
                        }
                    }
                } else {
                    DispatchQueue.main.async {
                        self.isLoadingError = true
                        self.isInitialLoading = false
                    }
                }
                group.leave()
            }
            group.enter()
            self.networker.getAnimeCharacters(id: id) { data, error in
                if let data = data {
                    self.characters = data.data
                    for item in data.data.prefix(10) {
                        group.enter()
                        self.networker.downloadImage(id: "character\(item.id)", urlString: item.character.images?.jpg.imageUrl) { data, error in
                            group.leave()
                        }
                    }
                    group.leave()
                    return
                }
                DispatchQueue.main.async {
                    self.isLoadingError = true
                    self.isInitialLoading = false
                }
                group.leave()
            }
            group.enter()
            self.networker.getAnimeRelations(id: id) { data, error in
                if let data = data {
                    self.relations = data.data
                    for item in self.relations.flatMap({ $0.entry }).prefix(10) {
                        group.enter()
                        if item.type == .anime {
                            self.networker.getAnimeDetails(id: item.id) { info, error in
                                self.networker.downloadImage(id: "anime\(item.id)", urlString: info?.mainPicture?.medium) { image, error in
                                    group.leave()
                                }
                            }
                        } else if item.type == .manga {
                            self.networker.getMangaDetails(id: item.id) { info, error in
                                self.networker.downloadImage(id: "manga\(item.id)", urlString: info?.mainPicture?.medium) { image, error in
                                    group.leave()
                                }
                            }
                        }
                    }
                    group.leave()
                    return
                }
                DispatchQueue.main.async {
                    self.isLoadingError = true
                    self.isInitialLoading = false
                }
                group.leave()
            }
            group.notify(queue: .main, execute: {
                DispatchQueue.main.async {
                    self.isInitialLoading = false
                }
            })
        }
    }
    
    func refresh() {
        DispatchQueue.main.async {
            self.isLoading = true
            self.isLoadingError = false
        }
        networker.getAnimeDetails(id: id) { anime, error in
            DispatchQueue.main.async {
                if let anime = anime {
                    self.anime = anime
                } else {
                    self.isLoadingError = true
                }
                self.isLoading = false
            }
        }
    }
}
