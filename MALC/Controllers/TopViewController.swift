//
//  TopViewController.swift
//  MALC
//
//  Created by Gao Tianrun on 1/5/24.
//

import Foundation

class TopViewController: ObservableObject {
    @Published var animeItems = [MALListAnime]()
    @Published var mangaItems = [MALListManga]()
    @Published var isLoading = false
    @Published var isLoadingError = false
    @Published var type: TypeEnum = .anime
    private var currentPage = 1
    private var canLoadMorePages = true
    let networker = NetworkManager.shared
    
    init() {
        refresh()
    }
    
    func refresh() {
        currentPage = 1
        canLoadMorePages = true
        DispatchQueue.main.async {
            self.isLoading = true
            self.isLoadingError = false
        }
        if type == .anime {
            networker.getTopAnimeList(page: currentPage) { data, error in
                if let _ = error {
                    DispatchQueue.main.async {
                        self.isLoading = false
                        self.isLoadingError = true
                    }
                    return
                }
                
                guard let data = data else {
                    DispatchQueue.main.async {
                        self.isLoading = false
                        self.isLoadingError = true
                    }
                    return
                }
                
                DispatchQueue.global().async {
                    let group = DispatchGroup()
                    for anime in data.data {
                        group.enter()
                        self.networker.downloadImage(id: "anime\(anime.id)", urlString: anime.node.mainPicture?.medium) { data, error in
                            group.leave()
                        }
                    }
                    group.notify(queue: .main, execute: {
                        self.currentPage = 2
                        self.canLoadMorePages = !(data.data.isEmpty)
                        DispatchQueue.main.async {
                            self.animeItems = data.data
                            self.isLoading = false
                        }
                    })
                }
            }
        } else {
            networker.getTopMangaList(page: currentPage) { data, error in
                if let _ = error {
                    DispatchQueue.main.async {
                        self.isLoading = false
                        self.isLoadingError = true
                    }
                    return
                }
                
                guard let data = data else {
                    DispatchQueue.main.async {
                        self.isLoading = false
                        self.isLoadingError = true
                    }
                    return
                }
                
                DispatchQueue.global().async {
                    let group = DispatchGroup()
                    for manga in data.data {
                        group.enter()
                        self.networker.downloadImage(id: "manga\(manga.id)", urlString: manga.node.mainPicture?.medium) { data, error in
                            group.leave()
                        }
                    }
                    group.notify(queue: .main, execute: {
                        self.currentPage = 2
                        self.canLoadMorePages = !(data.data.isEmpty)
                        DispatchQueue.main.async {
                            self.mangaItems = data.data
                            self.isLoading = false
                        }
                    })
                }
            }
        }
    }
    
    private func loadMore() {
        guard !isLoading && canLoadMorePages else {
            return
        }
        guard (type == .anime && animeItems.count >= 50) || (type == .manga && mangaItems.count >= 50) else {
            return
        }
        DispatchQueue.main.async {
            self.isLoading = true
            self.isLoadingError = false
        }
        if type == .anime {
            networker.getTopAnimeList(page: currentPage) { data, error in
                if let _ = error {
                    DispatchQueue.main.async {
                        self.isLoading = false
                        self.isLoadingError = true
                    }
                    return
                }
                
                guard let data = data else {
                    DispatchQueue.main.async {
                        self.isLoading = false
                        self.isLoadingError = true
                    }
                    return
                }
                
                DispatchQueue.global().async {
                    let group = DispatchGroup()
                    for anime in data.data {
                        group.enter()
                        self.networker.downloadImage(id: "anime\(anime.id)", urlString: anime.node.mainPicture?.medium) { data, error in
                            group.leave()
                        }
                    }
                    group.notify(queue: .main, execute: {
                        self.currentPage += 1
                        self.canLoadMorePages = !(data.data.isEmpty)
                        DispatchQueue.main.async {
                            self.animeItems.append(contentsOf: data.data)
                            self.isLoading = false
                        }
                    })
                }
            }
        } else {
            networker.getTopMangaList(page: currentPage) { data, error in
                if let _ = error {
                    DispatchQueue.main.async {
                        self.isLoading = false
                        self.isLoadingError = true
                    }
                    return
                }
                
                guard let data = data else {
                    DispatchQueue.main.async {
                        self.isLoading = false
                        self.isLoadingError = true
                    }
                    return
                }
                
                DispatchQueue.global().async {
                    let group = DispatchGroup()
                    for manga in data.data {
                        group.enter()
                        self.networker.downloadImage(id: "manga\(manga.id)", urlString: manga.node.mainPicture?.medium) { data, error in
                            group.leave()
                        }
                    }
                    group.notify(queue: .main, execute: {
                        self.currentPage += 1
                        self.canLoadMorePages = !(data.data.isEmpty)
                        DispatchQueue.main.async {
                            self.mangaItems.append(contentsOf: data.data)
                            self.isLoading = false
                        }
                    })
                }
            }
        }
    }
    
    func loadMoreIfNeeded(currentItem item: MALListAnime?) {
        guard let item = item else {
            loadMore()
            return
        }
        let thresholdIndex = animeItems.index(animeItems.endIndex, offsetBy: -5)
        if animeItems.firstIndex(where: { $0.node.id == item.node.id }) == thresholdIndex {
            loadMore()
        }
    }
    
    func loadMoreIfNeeded(currentItem item: MALListManga?) {
        guard let item = item else {
            loadMore()
            return
        }
        let thresholdIndex = mangaItems.index(mangaItems.endIndex, offsetBy: -5)
        if mangaItems.firstIndex(where: { $0.node.id == item.node.id }) == thresholdIndex {
            loadMore()
        }
    }
}
