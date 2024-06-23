//
//  SeasonsViewController.swift
//  MALC
//
//  Created by Gao Tianrun on 1/5/24.
//

import Foundation

class SeasonsViewController: ObservableObject {
    @Published var winterItems = [MALListAnime]()
    @Published var springItems = [MALListAnime]()
    @Published var summerItems = [MALListAnime]()
    @Published var fallItems = [MALListAnime]()
    @Published var isWinterLoading = false
    @Published var isSpringLoading = false
    @Published var isSummerLoading = false
    @Published var isFallLoading = false
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
        refresh(season)
    }
    
    private func toggleSeasonLoading(_ value: Bool) {
        if season == "winter" {
            isWinterLoading = value
        } else if season == "spring" {
            isSpringLoading = value
        } else if season == "summer" {
            isSummerLoading = value
        } else {
            isFallLoading = value
        }
    }
    
    func currentSeasonLoading() -> Bool {
        return (season == "winter" && isWinterLoading) || (season == "spring" && isSpringLoading) || (season == "summer" && isSummerLoading) || (season == "fall" && isFallLoading)
    }
    
    func refresh(_ season: String, _ clear: Bool = false) {
        currentPage = 1
        canLoadMorePages = true
        DispatchQueue.main.async {
            self.toggleSeasonLoading(true)
            self.isLoadingError = false
            if clear {
                self.winterItems = []
                self.springItems = []
                self.summerItems = []
                self.fallItems = []
            }
        }
        networker.getSeasonAnimeList(season: season, year: year, page: currentPage) { data, error in
            if let error = error {
                if case NetworkError.notFound = error {
                    self.canLoadMorePages = false
                }
                DispatchQueue.main.async {
                    self.toggleSeasonLoading(false)
                    if case NetworkError.notFound = error {} else {
                        self.isLoadingError = true
                    }
                }
                return
            }
            
            guard let data = data else {
                DispatchQueue.main.async {
                    self.toggleSeasonLoading(false)
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
                        if season == "winter" {
                            self.winterItems = data.data.filter { $0.node.startSeason?.season == season && $0.node.startSeason?.year == self.year }
                        } else if season == "spring" {
                            self.springItems = data.data.filter { $0.node.startSeason?.season == season && $0.node.startSeason?.year == self.year }
                        } else if season == "summer" {
                            self.summerItems = data.data.filter { $0.node.startSeason?.season == season && $0.node.startSeason?.year == self.year }
                        } else {
                            self.fallItems = data.data.filter { $0.node.startSeason?.season == season && $0.node.startSeason?.year == self.year }
                        }
                        self.toggleSeasonLoading(false)
                    }
                })
            }
        }
    }
    
    private func loadMore() {
        guard !currentSeasonLoading() && canLoadMorePages else {
            return
        }
        guard (season == "winter" && winterItems.count >= 10) || (season == "spring" && springItems.count >= 10) || (season == "summer" && summerItems.count >= 10) || (season == "fall" && fallItems.count >= 10) else {
            return
        }
        DispatchQueue.main.async {
            self.toggleSeasonLoading(true)
            self.isLoadingError = false
        }
        networker.getSeasonAnimeList(season: season, year: year, page: currentPage) { data, error in
            if let _ = error {
                DispatchQueue.main.async {
                    self.toggleSeasonLoading(false)
                    self.isLoadingError = true
                }
                return
            }
            
            guard let data = data else {
                DispatchQueue.main.async {
                    self.toggleSeasonLoading(false)
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
                        if self.season == "winter" {
                            self.winterItems.append(contentsOf: data.data.filter { $0.node.startSeason?.season == self.season && $0.node.startSeason?.year == self.year })
                        } else if self.season == "spring" {
                            self.springItems.append(contentsOf: data.data.filter { $0.node.startSeason?.season == self.season && $0.node.startSeason?.year == self.year })
                        } else if self.season == "summer" {
                            self.summerItems.append(contentsOf: data.data.filter { $0.node.startSeason?.season == self.season && $0.node.startSeason?.year == self.year })
                        } else {
                            self.fallItems.append(contentsOf: data.data.filter { $0.node.startSeason?.season == self.season && $0.node.startSeason?.year == self.year })
                        }
                        self.toggleSeasonLoading(false)
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
        if season == "winter" {
            let thresholdIndex = winterItems.index(winterItems.endIndex, offsetBy: -5)
            if winterItems.firstIndex(where: { $0.id == item.id }) == thresholdIndex {
                loadMore()
            }
        } else if season == "spring" {
            let thresholdIndex = springItems.index(springItems.endIndex, offsetBy: -5)
            if springItems.firstIndex(where: { $0.id == item.id }) == thresholdIndex {
                loadMore()
            }
        } else if season == "summer" {
            let thresholdIndex = summerItems.index(summerItems.endIndex, offsetBy: -5)
            if summerItems.firstIndex(where: { $0.id == item.id }) == thresholdIndex {
                loadMore()
            }
        } else {
            let thresholdIndex = fallItems.index(fallItems.endIndex, offsetBy: -5)
            if fallItems.firstIndex(where: { $0.id == item.id }) == thresholdIndex {
                loadMore()
            }
        }
    }
}
