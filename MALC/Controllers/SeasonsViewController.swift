//
//  SeasonsViewController.swift
//  MALC
//
//  Created by Gao Tianrun on 1/5/24.
//

import Foundation

@MainActor
class SeasonsViewController: ObservableObject {
    // Winter season variables
    @Published var winterItems = [MALListAnime]()
    @Published var isWinterLoading = false
    private var currentWinterPage = 1
    private var canLoadMoreWinterPages = true
    
    // Spring season variables
    @Published var springItems = [MALListAnime]()
    @Published var isSpringLoading = false
    private var currentSpringPage = 1
    private var canLoadMoreSpringPages = true
    
    // Summer season variables
    @Published var summerItems = [MALListAnime]()
    @Published var isSummerLoading = false
    private var currentSummerPage = 1
    private var canLoadMoreSummerPages = true
    
    // Fall season variables
    @Published var fallItems = [MALListAnime]()
    @Published var isFallLoading = false
    private var currentFallPage = 1
    private var canLoadMoreFallPages = true
    
    // Common variables
    @Published var season = ["winter", "spring", "summer", "fall"][((Calendar(identifier: .gregorian).dateComponents([.month], from: .now).month ?? 9) - 1) / 3] // map the current month to the current season
    @Published var year = Calendar(identifier: .gregorian).dateComponents([.year], from: .now).year ?? 2001
    @Published var isLoadingError = false
    let networker = NetworkManager.shared
    
    // Check if the anime list for the current season is empty
    func isSeasonEmpty() -> Bool {
        return (season == "winter" && winterItems.isEmpty) || (season == "spring" && springItems.isEmpty) || (season == "summer" && summerItems.isEmpty) || (season == "fall" && fallItems.isEmpty)
    }
    
    // Check if the anime list for the current season should be refreshed
    func shouldRefresh() -> Bool {
        return (season == "winter" && winterItems.isEmpty && canLoadMoreWinterPages) || (season == "spring" && springItems.isEmpty && canLoadMoreSpringPages) || (season == "summer" && summerItems.isEmpty && canLoadMoreSummerPages) || (season == "fall" && fallItems.isEmpty && canLoadMoreFallPages)
    }
    
    // Get current(Season)Page variable for the current season
    private func getCurrentSeasonPage() -> Int {
        if season == "winter" {
            return currentWinterPage
        } else if season == "spring" {
            return currentSpringPage
        } else if season == "summer" {
            return currentSummerPage
        } else if season == "fall" {
            return currentFallPage
        } else {
            // Should not reach here
            return 1
        }
    }
    
    // Get is(Season)Loading variable for the current season
    func getCurrentSeasonLoading() -> Bool {
        if season == "winter" {
            return isWinterLoading
        } else if season == "spring" {
            return isSpringLoading
        } else if season == "summer" {
            return isSummerLoading
        } else if season == "fall" {
            return isFallLoading
        } else {
            // Should not reach here
            return false
        }
    }
    
    // Get canLoadMore(Season)Pages variable for the current season
    private func getCurrentSeasonCanLoadMore() -> Bool {
        if season == "winter" {
            return canLoadMoreWinterPages
        } else if season == "spring" {
            return canLoadMoreSpringPages
        } else if season == "summer" {
            return canLoadMoreSummerPages
        } else if season == "fall" {
            return canLoadMoreFallPages
        } else {
            // Should not reach here
            return false
        }
    }
    
    // Update current(Season)Page variable for the current season
    private func updateCurrentSeasonPage(_ currentPage: Int) {
        if season == "winter" {
            currentWinterPage = currentPage
        } else if season == "spring" {
            currentSpringPage = currentPage
        } else if season == "summer" {
            currentSummerPage = currentPage
        } else if season == "fall" {
            currentFallPage = currentPage
        }
    }
    
    // Update is(Season)Loading variable for the current season
    private func updateCurrentSeasonLoading(_ isLoading: Bool) {
        if season == "winter" {
            isWinterLoading = isLoading
        } else if season == "spring" {
            isSpringLoading = isLoading
        } else if season == "summer" {
            isSummerLoading = isLoading
        } else if season == "fall" {
            isFallLoading = isLoading
        }
    }
    
    // Update canLoadMore(Season)Pages variable for the current season
    private func updateCurrentSeasonCanLoadMore(_ canLoadMorePages: Bool) {
        if season == "winter" {
            canLoadMoreWinterPages = canLoadMorePages
        } else if season == "spring" {
            canLoadMoreSpringPages = canLoadMorePages
        } else if season == "summer" {
            canLoadMoreSummerPages = canLoadMorePages
        } else if season == "fall" {
            canLoadMoreFallPages = canLoadMorePages
        }
    }
    
    // Refresh the current season list
    func refresh(_ clear: Bool = false) async -> Void {
        // Reset all lists if need to clear (to change year)
        if clear {
            winterItems = []
            springItems = []
            summerItems = []
            fallItems = []
        }
        
        updateCurrentSeasonPage(1)
        updateCurrentSeasonLoading(true)
        updateCurrentSeasonCanLoadMore(true)
        isLoadingError = false
        
        do {
            let animeList = try await networker.getSeasonAnimeList(season: season, year: year, page: getCurrentSeasonPage())
            
            await withTaskGroup(of: Void.self) { taskGroup in
                for anime in animeList {
                    taskGroup.addTask {
                        await self.networker.downloadImage(id: "anime\(anime.id)", urlString: anime.node.mainPicture?.medium)
                    }
                }
            }
            
            updateCurrentSeasonPage(2)
            updateCurrentSeasonCanLoadMore(!(animeList.isEmpty))
            if season == "winter" {
                winterItems = animeList.filter { $0.node.startSeason?.season == season && $0.node.startSeason?.year == year }
            } else if season == "spring" {
                springItems = animeList.filter { $0.node.startSeason?.season == season && $0.node.startSeason?.year == year }
            } else if season == "summer" {
                summerItems = animeList.filter { $0.node.startSeason?.season == season && $0.node.startSeason?.year == year }
            } else if season == "fall" {
                fallItems = animeList.filter { $0.node.startSeason?.season == season && $0.node.startSeason?.year == year }
            }
            updateCurrentSeasonLoading(false)
        } catch let error as NetworkError {
            updateCurrentSeasonLoading(false)
            
            // If 404 not found, usually means the season still has not been released yet
            if case NetworkError.notFound = error {
                updateCurrentSeasonCanLoadMore(false)
            } else {
                isLoadingError = true
            }
        } catch {
            updateCurrentSeasonLoading(false)
            isLoadingError = true
        }
    }
    
    // Load more of the current season
    private func loadMore() async -> Void {
        // only load more when it is not loading and there are more pages to be loaded
        guard !getCurrentSeasonLoading() && getCurrentSeasonCanLoadMore() else {
            return
        }
        
        // only load more when there are already items on the page
        guard !isSeasonEmpty() else {
            return
        }
        
        updateCurrentSeasonLoading(true)
        isLoadingError = false
        do {
            let animeList = try await networker.getSeasonAnimeList(season: season, year: year, page: getCurrentSeasonPage())
            
            await withTaskGroup(of: Void.self) { taskGroup in
                for anime in animeList {
                    taskGroup.addTask {
                        await self.networker.downloadImage(id: "anime\(anime.id)", urlString: anime.node.mainPicture?.medium)
                    }
                }
            }
            
            updateCurrentSeasonPage(getCurrentSeasonPage() + 1)
            updateCurrentSeasonCanLoadMore(!(animeList.isEmpty))
            if season == "winter" {
                winterItems.append(contentsOf: animeList.filter { $0.node.startSeason?.season == season && $0.node.startSeason?.year == year })
            } else if season == "spring" {
                springItems.append(contentsOf: animeList.filter { $0.node.startSeason?.season == season && $0.node.startSeason?.year == year })
            } else if season == "summer" {
                summerItems.append(contentsOf: animeList.filter { $0.node.startSeason?.season == season && $0.node.startSeason?.year == year })
            } else if season == "fall" {
                fallItems.append(contentsOf: animeList.filter { $0.node.startSeason?.season == season && $0.node.startSeason?.year == year })
            }
            updateCurrentSeasonLoading(false)
        } catch let error as NetworkError {
            updateCurrentSeasonLoading(false)
            
            // If 404 not found, usually means the season still has not been released yet
            if case NetworkError.notFound = error {
                updateCurrentSeasonCanLoadMore(false)
            } else {
                isLoadingError = true
            }
        } catch {
            updateCurrentSeasonLoading(false)
            isLoadingError = true
        }
    }
    
    // Load more items from current season when reaching the 5th last anime in list
    func loadMoreIfNeeded(currentItem item: MALListAnime?) async -> Void {
        guard let item = item else {
            return await loadMore()
        }
        if season == "winter" {
            let thresholdIndex = winterItems.index(winterItems.endIndex, offsetBy: -5)
            if winterItems.firstIndex(where: { $0.id == item.id }) == thresholdIndex {
                return await loadMore()
            }
        } else if season == "spring" {
            let thresholdIndex = springItems.index(springItems.endIndex, offsetBy: -5)
            if springItems.firstIndex(where: { $0.id == item.id }) == thresholdIndex {
                return await loadMore()
            }
        } else if season == "summer" {
            let thresholdIndex = summerItems.index(summerItems.endIndex, offsetBy: -5)
            if summerItems.firstIndex(where: { $0.id == item.id }) == thresholdIndex {
                return await loadMore()
            }
        } else if season == "fall" {
            let thresholdIndex = fallItems.index(fallItems.endIndex, offsetBy: -5)
            if fallItems.firstIndex(where: { $0.id == item.id }) == thresholdIndex {
                return await loadMore()
            }
        }
    }
}
