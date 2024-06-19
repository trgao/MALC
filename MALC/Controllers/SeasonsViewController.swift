//
//  SeasonsViewController.swift
//  MALC
//
//  Created by Gao Tianrun on 1/5/24.
//

import Foundation

class SeasonsViewController: ObservableObject {
    @Published var items = [MALListAnime]()
    @Published var isLoading = false
    @Published var isLoadingError = false
    @Published var season: String
    @Published var year: Int
    private var currentPage = 1
    private var canLoadMorePages = true
    let networker = NetworkManager.shared
    
    init() {
        let seasons = ["winter", "spring", "summer", "fall"]
        self.season = seasons[((Calendar(identifier: .gregorian).dateComponents([.month], from: .now).month ?? 9) - 1) / 3]
        self.year = Calendar(identifier: .gregorian).dateComponents([.year], from: .now).year ?? 2001
        refresh()
    }
    
    func refresh(_ clear: Bool = false) {
        currentPage = 1
        canLoadMorePages = true
        DispatchQueue.main.async {
            self.isLoading = true
            self.isLoadingError = false
            if clear {
                self.items = []
            }
        }
        networker.getSeasonAnimeList(season: season, year: year, page: currentPage) { data, error in
            if let error = error {
                if case NetworkError.notFound = error {
                    self.canLoadMorePages = false
                }
                DispatchQueue.main.async {
                    self.isLoading = false
                    if case NetworkError.notFound = error {} else {
                        self.isLoadingError = true
                    }
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
                        self.items = data.data.filter { $0.node.startSeason?.season == self.season && $0.node.startSeason?.year == self.year }
                        self.isLoading = false
                    }
                })
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
        networker.getSeasonAnimeList(season: season, year: year, page: currentPage) { data, error in
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
                        self.items.append(contentsOf: data.data.filter { $0.node.startSeason?.season == self.season && $0.node.startSeason?.year == self.year })
                        self.isLoading = false
                    }
                })
            }
        }
    }
    
    func loadMoreIfNeeded(currentItem item: MALListAnime?) {
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
