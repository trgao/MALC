//
//  JikanGridInfiniteScrollViewController.swift
//  MALC
//
//  Created by Gao Tianrun on 1/5/24.
//

import Foundation

class JikanGridInfiniteScrollViewController: ObservableObject {
    @Published var items = [JikanListItem]()
    @Published var isLoading = false
    @Published var isLoadingError = false
    private var ids: Set<Int> = []
    private var currentPage = 1
    private var canLoadMorePages = true
    private let urlExtend: String
    private let type: TypeEnum
    let networker = NetworkManager.shared
    
    init(_ urlExtend: String, _ type: TypeEnum) {
        self.urlExtend = urlExtend
        self.type = type
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
            networker.getAnimeList(urlExtend: urlExtend, page: currentPage) { data, error in
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
                        self.networker.downloadImage(id: "anime\(anime.id)", urlString: anime.images?.jpg.imageUrl) { data, error in
                            group.leave()
                        }
                    }
                    group.notify(queue: .main, execute: {
                        self.currentPage = 2
                        self.canLoadMorePages = data.pagination.hasNextPage
                        DispatchQueue.main.async {
                            for item in data.data {
                                if !self.ids.contains(item.id) {
                                    self.ids.insert(item.id)
                                    self.items.append(item)
                                }
                            }
                            self.isLoading = false
                        }
                    })
                }
            }
        } else {
            networker.getMangaList(urlExtend: urlExtend, page: currentPage) { data, error in
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
                        self.networker.downloadImage(id: "manga\(manga.id)", urlString: manga.images?.jpg.imageUrl) { data, error in
                            group.leave()
                        }
                    }
                    group.notify(queue: .main, execute: {
                        self.currentPage = 2
                        self.canLoadMorePages = data.pagination.hasNextPage
                        DispatchQueue.main.async {
                            for item in data.data {
                                if !self.ids.contains(item.id) {
                                    self.ids.insert(item.id)
                                    self.items.append(item)
                                }
                            }
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
        guard items.count >= 50 else {
            return
        }
        DispatchQueue.main.async {
            self.isLoading = true
            self.isLoadingError = false
        }
        if type == .anime {
            networker.getAnimeList(urlExtend: urlExtend, page: currentPage) { data, error in
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
                        self.networker.downloadImage(id: "anime\(anime.id)", urlString: anime.images?.jpg.imageUrl) { data, error in
                            group.leave()
                        }
                    }
                    group.notify(queue: .main, execute: {
                        self.currentPage += 1
                        self.canLoadMorePages = data.pagination.hasNextPage
                        DispatchQueue.main.async {
                            for item in data.data {
                                if !self.ids.contains(item.id) {
                                    self.ids.insert(item.id)
                                    self.items.append(item)
                                }
                            }
                            self.isLoading = false
                        }
                    })
                }
            }
        } else {
            networker.getMangaList(urlExtend: urlExtend, page: currentPage) { data, error in
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
                        self.networker.downloadImage(id: "manga\(manga.id)", urlString: manga.images?.jpg.imageUrl) { data, error in
                            group.leave()
                        }
                    }
                    group.notify(queue: .main, execute: {
                        self.currentPage += 1
                        self.canLoadMorePages = data.pagination.hasNextPage
                        DispatchQueue.main.async {
                            for item in data.data {
                                if !self.ids.contains(item.id) {
                                    self.ids.insert(item.id)
                                    self.items.append(item)
                                }
                            }
                            self.isLoading = false
                        }
                    })
                }
            }
        }
    }
    
    func loadMoreIfNeeded(currentItem item: JikanListItem?) {
        guard let item = item else {
            loadMore()
            return
        }
        let thresholdIndex = items.index(items.endIndex, offsetBy: -5)
        if items.firstIndex(where: { $0.id == item.id }) == thresholdIndex {
            loadMore()
        }
    }
}
