//
//  SeasonsViewController.swift
//  MALC
//
//  Created by Gao Tianrun on 1/5/24.
//

import Foundation

@MainActor
class SeasonsViewController: ObservableObject {
    var appState: AppState
    @Published var winterItems = [MALListAnime]()
    @Published var springItems = [MALListAnime]()
    @Published var summerItems = [MALListAnime]()
    @Published var fallItems = [MALListAnime]()
    @Published var isWinterLoading = false
    @Published var isSpringLoading = false
    @Published var isSummerLoading = false
    @Published var isFallLoading = false
    @Published var isLoadingError = false
    private var currentPage = 1
    private var canLoadMorePages = true
    let networker = NetworkManager.shared
    
    init(_ appState: AppState) {
        self.appState = appState
    }
    
    func changeSeason(_ season: String) async -> Void {
        appState.season = season
        return await refresh()
    }
    
    func changeYear(_ year: Int) async -> Void {
        appState.year = year
        return await refresh(true)
    }
    
    func currentSeasonLoading() -> Bool {
        return (appState.season == "winter" && isWinterLoading) || (appState.season == "spring" && isSpringLoading) || (appState.season == "summer" && isSummerLoading) || (appState.season == "fall" && isFallLoading)
    }
    
    private func toggleSeasonLoading(_ value: Bool) {
        if appState.season == "winter" {
            isWinterLoading = value
        } else if appState.season == "spring" {
            isSpringLoading = value
        } else if appState.season == "summer" {
            isSummerLoading = value
        } else if appState.season == "fall" {
            isFallLoading = value
        }
    }
    
    func refresh(_ clear: Bool = false) async -> Void {
        currentPage = 1
        canLoadMorePages = true
        toggleSeasonLoading(true)
        isLoadingError = false
        if clear {
            winterItems = []
            springItems = []
            summerItems = []
            fallItems = []
        }
        do {
            let animeList = try await networker.getSeasonAnimeList(season: appState.season, year: appState.year, page: currentPage)
            
            await withTaskGroup(of: Void.self) { taskGroup in
                for anime in animeList {
                    taskGroup.addTask {
                        await self.networker.downloadImage(id: "anime\(anime.id)", urlString: anime.node.mainPicture?.medium)
                    }
                }
            }
            
            currentPage = 2
            canLoadMorePages = !(animeList.isEmpty)
            if appState.season == "winter" {
                winterItems = animeList.filter { $0.node.startSeason?.season == appState.season && $0.node.startSeason?.year == appState.year }
            } else if appState.season == "spring" {
                springItems = animeList.filter { $0.node.startSeason?.season == appState.season && $0.node.startSeason?.year == appState.year }
            } else if appState.season == "summer" {
                summerItems = animeList.filter { $0.node.startSeason?.season == appState.season && $0.node.startSeason?.year == appState.year }
            } else if appState.season == "fall" {
                fallItems = animeList.filter { $0.node.startSeason?.season == appState.season && $0.node.startSeason?.year == appState.year }
            }
            toggleSeasonLoading(false)
        } catch let error as NetworkError {
            toggleSeasonLoading(false)
            
            // If 404 not found, usually means the season still has not been released yet
            if case NetworkError.notFound = error {
                canLoadMorePages = false
            } else {
                isLoadingError = true
            }
        } catch {
            toggleSeasonLoading(false)
            isLoadingError = true
        }
    }
    
    private func loadMore() async -> Void {
        // only load more when it is not loading and there are more pages to be loaded
        guard !currentSeasonLoading() && canLoadMorePages else {
            return
        }
        
        // only load more when there are already items on the page
        guard (appState.season == "winter" && winterItems.count > 0) || (appState.season == "spring" && springItems.count > 0) || (appState.season == "summer" && summerItems.count > 0) || (appState.season == "fall" && fallItems.count > 0) else {
            return
        }
        toggleSeasonLoading(true)
        isLoadingError = false
        do {
            let animeList = try await networker.getSeasonAnimeList(season: appState.season, year: appState.year, page: currentPage)
            
            await withTaskGroup(of: Void.self) { taskGroup in
                for anime in animeList {
                    taskGroup.addTask {
                        await self.networker.downloadImage(id: "anime\(anime.id)", urlString: anime.node.mainPicture?.medium)
                    }
                }
            }
            
            currentPage += 1
            canLoadMorePages = !(animeList.isEmpty)
            if appState.season == "winter" {
                winterItems.append(contentsOf: animeList.filter { $0.node.startSeason?.season == appState.season && $0.node.startSeason?.year == appState.year })
            } else if appState.season == "spring" {
                springItems.append(contentsOf: animeList.filter { $0.node.startSeason?.season == appState.season && $0.node.startSeason?.year == appState.year })
            } else if appState.season == "summer" {
                summerItems.append(contentsOf: animeList.filter { $0.node.startSeason?.season == appState.season && $0.node.startSeason?.year == appState.year })
            } else if appState.season == "fall" {
                fallItems.append(contentsOf: animeList.filter { $0.node.startSeason?.season == appState.season && $0.node.startSeason?.year == appState.year })
            }
            toggleSeasonLoading(false)
        } catch let error as NetworkError {
            toggleSeasonLoading(false)
            
            // If 404 not found, usually means the season still has not been released yet
            if case NetworkError.notFound = error {
                canLoadMorePages = false
            } else {
                isLoadingError = true
            }
        } catch {
            toggleSeasonLoading(false)
            isLoadingError = true
        }
    }
    
    func loadMoreIfNeeded(currentItem item: MALListAnime?) async -> Void {
        guard let item = item else {
            return await loadMore()
        }
        if appState.season == "winter" {
            let thresholdIndex = winterItems.index(winterItems.endIndex, offsetBy: -5)
            if winterItems.firstIndex(where: { $0.id == item.id }) == thresholdIndex {
                return await loadMore()
            }
        } else if appState.season == "spring" {
            let thresholdIndex = springItems.index(springItems.endIndex, offsetBy: -5)
            if springItems.firstIndex(where: { $0.id == item.id }) == thresholdIndex {
                return await loadMore()
            }
        } else if appState.season == "summer" {
            let thresholdIndex = summerItems.index(summerItems.endIndex, offsetBy: -5)
            if summerItems.firstIndex(where: { $0.id == item.id }) == thresholdIndex {
                return await loadMore()
            }
        } else if appState.season == "fall" {
            let thresholdIndex = fallItems.index(fallItems.endIndex, offsetBy: -5)
            if fallItems.firstIndex(where: { $0.id == item.id }) == thresholdIndex {
                return await loadMore()
            }
        }
    }
}
