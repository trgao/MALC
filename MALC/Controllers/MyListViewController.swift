//
//  MyListViewController.swift
//  MALC
//
//  Created by Gao Tianrun on 19/4/24.
//

import Foundation

class MyListViewController: ObservableObject {
    @Published var animeItems = [MALListAnime]()
    @Published var mangaItems = [MALListManga]()
    @Published var isLoading = false
    @Published var isLoadingError = false
    @Published var type: TypeEnum = .anime
    @Published var animeStatus: StatusEnum = .completed
    @Published var animeSort = "anime_title"
    @Published var mangaStatus: StatusEnum = .completed
    @Published var mangaSort = "manga_title"
    private var currentPage = 1
    var canLoadMorePages = true
    let networker = NetworkManager.shared
    
    init() {
        if networker.isSignedIn {
            refresh()
        }
    }
    
    func refresh(_ clear: Bool = false) {
        currentPage = 1
        canLoadMorePages = true
        DispatchQueue.main.async {
            self.isLoading = true
            self.isLoadingError = false
            if clear {
                self.animeItems = []
                self.mangaItems = []
            }
        }
        if type == .anime {
            networker.getUserAnimeList(page: currentPage, status: animeStatus, sort: animeSort) { data, error in
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
            networker.getUserMangaList(page: currentPage, status: mangaStatus, sort: mangaSort) { data, error in
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
    
    func refreshClear() {
        refresh(true)
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
            networker.getUserAnimeList(page: currentPage, status: animeStatus, sort: animeSort) { data, error in
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
            networker.getUserMangaList(page: currentPage, status: mangaStatus, sort: mangaSort) { data, error in
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
