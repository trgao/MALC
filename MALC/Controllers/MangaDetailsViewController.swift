//
//  MangaDetailsViewController.swift
//  MALC
//
//  Created by Gao Tianrun on 12/5/24.
//

import Foundation

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
        DispatchQueue.global().async {
            let group = DispatchGroup()
            group.enter()
            self.networker.getMangaDetails(id: id) { manga, error in
                if let manga = manga {
                    self.manga = manga
                    for item in manga.recommendations {
                        group.enter()
                        self.networker.downloadImage(id: "manga\(item.id)", urlString: item.node.mainPicture?.medium) { data, error in
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
            self.networker.getMangaCharacters(id: id) { data, error in
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
            self.networker.getMangaRelations(id: id) { data, error in
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
        networker.getMangaDetails(id: id) { manga, error in
            DispatchQueue.main.async {
                if let manga = manga {
                    self.manga = manga
                } else {
                    self.isLoadingError = true
                }
                self.isLoading = false
            }
        }
    }
}

