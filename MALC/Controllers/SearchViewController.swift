//
//  SearchViewController.swift
//  MALC
//
//  Created by Gao Tianrun on 29/5/24.
//

import Foundation

class SearchViewController: ObservableObject {
    @Published var animeItems = [MALListAnime]()
    @Published var mangaItems = [MALListManga]()
    @Published var animeSuggestions = [MALListAnime]()
    @Published var topAiringAnime = [MALListAnime]()
    @Published var topUpcomingAnime = [MALListAnime]()
    @Published var topPopularAnime = [MALListAnime]()
    @Published var topPopularManga = [MALListManga]()
    @Published var isPageLoading = true
    @Published var isSearchLoading = false
    @Published var isLoadingError = false
    @Published var type: TypeEnum = .anime
    private var currentPage = 1
    private var canLoadMorePages = true
    let networker = NetworkManager.shared
    
    init() {
        refresh()
    }
    
    func refresh() {
        loadSuggestions()
        DispatchQueue.global().async {
            DispatchQueue.main.async {
                self.isPageLoading = true
                self.isLoadingError = false
            }
            let group = DispatchGroup()
            group.enter()
            self.networker.getAnimeTopAiringList { data, error in
                if let _ = error {
                    DispatchQueue.main.async {
                        self.isPageLoading = false
                        self.isLoadingError = true
                    }
                    return
                }
                
                guard let data = data else {
                    DispatchQueue.main.async {
                        self.isPageLoading = false
                        self.isLoadingError = true
                    }
                    return
                }
                
                DispatchQueue.main.async {
                    self.topAiringAnime = data.data
                }
                for anime in data.data {
                    group.enter()
                    self.networker.downloadImage(id: "anime\(anime.id)", urlString: anime.node.mainPicture?.medium) { data, error in
                        group.leave()
                    }
                }
                group.leave()
            }
            group.enter()
            self.networker.getAnimeTopUpcomingList { data, error in
                if let _ = error {
                    DispatchQueue.main.async {
                        self.isPageLoading = false
                        self.isLoadingError = true
                    }
                    return
                }
                
                guard let data = data else {
                    DispatchQueue.main.async {
                        self.isPageLoading = false
                        self.isLoadingError = true
                    }
                    return
                }
                
                DispatchQueue.main.async {
                    self.topUpcomingAnime = data.data
                }
                for anime in data.data {
                    group.enter()
                    self.networker.downloadImage(id: "anime\(anime.id)", urlString: anime.node.mainPicture?.medium) { data, error in
                        group.leave()
                    }
                }
                group.leave()
            }
            group.enter()
            self.networker.getAnimeTopPopularList { data, error in
                if let _ = error {
                    DispatchQueue.main.async {
                        self.isPageLoading = false
                        self.isLoadingError = true
                    }
                    return
                }
                
                guard let data = data else {
                    DispatchQueue.main.async {
                        self.isPageLoading = false
                        self.isLoadingError = true
                    }
                    return
                }
                
                DispatchQueue.main.async {
                    self.topPopularAnime = data.data
                }
                for anime in data.data {
                    group.enter()
                    self.networker.downloadImage(id: "anime\(anime.id)", urlString: anime.node.mainPicture?.medium) { data, error in
                        group.leave()
                    }
                }
                group.leave()
            }
            group.enter()
            self.networker.getMangaTopPopularList { data, error in
                if let _ = error {
                    DispatchQueue.main.async {
                        self.isPageLoading = false
                        self.isLoadingError = true
                    }
                    return
                }
                
                guard let data = data else {
                    DispatchQueue.main.async {
                        self.isPageLoading = false
                        self.isLoadingError = true
                    }
                    return
                }
                
                DispatchQueue.main.async {
                    self.topPopularManga = data.data
                }
                for manga in data.data {
                    group.enter()
                    self.networker.downloadImage(id: "manga\(manga.id)", urlString: manga.node.mainPicture?.medium) { data, error in
                        group.leave()
                    }
                }
                group.leave()
            }
            group.notify(queue: .main, execute: {
                DispatchQueue.main.async {
                    self.isPageLoading = false
                }
            })
        }
    }
    
    func loadSuggestions() {
        if !networker.isSignedIn || !animeSuggestions.isEmpty {
            return
        }
        DispatchQueue.global().async {
            DispatchQueue.main.async {
                self.isPageLoading = true
                self.isLoadingError = false
            }
            self.networker.getUserAnimeSuggestionList { data, error in
                let group = DispatchGroup()
                if let _ = error {
                    DispatchQueue.main.async {
                        self.isPageLoading = false
                        self.isLoadingError = true
                    }
                    return
                }
                
                guard let data = data else {
                    DispatchQueue.main.async {
                        self.isPageLoading = false
                        self.isLoadingError = true
                    }
                    return
                }
                
                for anime in data.data {
                    group.enter()
                    self.networker.downloadImage(id: "anime\(anime.id)", urlString: anime.node.mainPicture?.medium) { data, error in
                        group.leave()
                    }
                }
                group.notify(queue: .main, execute: {
                    DispatchQueue.main.async {
                        self.animeSuggestions = data.data
                        self.isPageLoading = false
                    }
                })
            }
        }
    }
    
    func search(_ title: String) {
        currentPage = 1
        canLoadMorePages = true
        DispatchQueue.main.async {
            self.isSearchLoading = true
            self.isLoadingError = false
            self.animeItems = []
            self.mangaItems = []
        }
        if type == .anime {
            networker.searchAnime(anime: title, page: currentPage) { data, error in
                if let _ = error {
                    DispatchQueue.main.async {
                        self.isSearchLoading = false
                        self.isLoadingError = true
                    }
                    return
                }
                
                guard let data = data else {
                    DispatchQueue.main.async {
                        self.isSearchLoading = false
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
                            self.isSearchLoading = false
                        }
                    })
                }
            }
        } else {
            networker.searchManga(manga: title, page: currentPage) { data, error in
                if let _ = error {
                    DispatchQueue.main.async {
                        self.isSearchLoading = false
                        self.isLoadingError = true
                    }
                    return
                }
                
                guard let data = data else {
                    DispatchQueue.main.async {
                        self.isSearchLoading = false
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
                            self.isSearchLoading = false
                        }
                    })
                }
            }
        }
    }
    
    private func loadMore() {
        guard !isSearchLoading && canLoadMorePages else {
            return
        }
        DispatchQueue.main.async {
            self.isSearchLoading = true
            self.isLoadingError = false
        }
        if type == .anime {
            networker.getTopAnimeList(page: currentPage) { data, error in
                if let _ = error {
                    DispatchQueue.main.async {
                        self.isSearchLoading = false
                        self.isLoadingError = true
                    }
                    return
                }
                
                guard let data = data else {
                    DispatchQueue.main.async {
                        self.isSearchLoading = false
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
                            self.isSearchLoading = false
                        }
                    })
                }
            }
        } else {
            networker.getTopMangaList(page: currentPage) { data, error in
                if let _ = error {
                    DispatchQueue.main.async {
                        self.isSearchLoading = false
                        self.isLoadingError = true
                    }
                    return
                }
                
                guard let data = data else {
                    DispatchQueue.main.async {
                        self.isSearchLoading = false
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
                            self.isSearchLoading = false
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

