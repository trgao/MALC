//
//  SeasonsViewController.swift
//  MALC
//
//  Created by Gao Tianrun on 1/5/24.
//

import Foundation

@MainActor
class SeasonsViewController: ObservableObject {
    @Published var winterItems = [MALListAnime]()
    @Published var springItems = [MALListAnime]()
    @Published var summerItems = [MALListAnime]()
    @Published var fallItems = [MALListAnime]()
    @Published var season = ["winter", "spring", "summer", "fall"][((Calendar(identifier: .gregorian).dateComponents([.month], from: .now).month ?? 9) - 1) / 3]
    @Published var year = Calendar(identifier: .gregorian).dateComponents([.year], from: .now).year ?? 2001
    @Published var isLoading = true
    @Published var isLoadingError = false
    private var currentPage = 1
    private var canLoadMorePages = true
    let networker = NetworkManager.shared
    
    func isSeasonEmpty() -> Bool {
        return (season == "winter" && winterItems.isEmpty) || (season == "spring" && springItems.isEmpty) || (season == "summer" && summerItems.isEmpty) || (season == "fall" && fallItems.isEmpty)
    }
    
    func refresh(_ clear: Bool = false) async -> Void {
        let task = Task {
            currentPage = 1
            canLoadMorePages = true
            isLoading = true
            isLoadingError = false
            if clear {
                winterItems = []
                springItems = []
                summerItems = []
                fallItems = []
            }
            do {
                let animeList = try await networker.getSeasonAnimeList(season: season, year: year, page: currentPage)
                
                await withTaskGroup(of: Void.self) { taskGroup in
                    for anime in animeList {
                        taskGroup.addTask {
                            await self.networker.downloadImage(id: "anime\(anime.id)", urlString: anime.node.mainPicture?.medium)
                        }
                    }
                }
                
                currentPage = 2
                canLoadMorePages = !(animeList.isEmpty)
                if season == "winter" {
                    winterItems = animeList.filter { $0.node.startSeason?.season == season && $0.node.startSeason?.year == year }
                } else if season == "spring" {
                    springItems = animeList.filter { $0.node.startSeason?.season == season && $0.node.startSeason?.year == year }
                } else if season == "summer" {
                    summerItems = animeList.filter { $0.node.startSeason?.season == season && $0.node.startSeason?.year == year }
                } else if season == "fall" {
                    fallItems = animeList.filter { $0.node.startSeason?.season == season && $0.node.startSeason?.year == year }
                }
                isLoading = false
            } catch let error as NetworkError {
                isLoading = false
                
                // If 404 not found, usually means the season still has not been released yet
                if case NetworkError.notFound = error {
                    canLoadMorePages = false
                } else {
                    isLoadingError = true
                }
            } catch {
                isLoading = false
                isLoadingError = true
            }
        }
        await task.value
    }
    
    private func loadMore() async -> Void {
        // only load more when it is not loading and there are more pages to be loaded
        guard !isLoading && canLoadMorePages else {
            return
        }
        
        // only load more when there are already items on the page
        guard !isSeasonEmpty() else {
            return
        }
        isLoading = true
        isLoadingError = false
        do {
            let animeList = try await networker.getSeasonAnimeList(season: season, year: year, page: currentPage)
            
            await withTaskGroup(of: Void.self) { taskGroup in
                for anime in animeList {
                    taskGroup.addTask {
                        await self.networker.downloadImage(id: "anime\(anime.id)", urlString: anime.node.mainPicture?.medium)
                    }
                }
            }
            
            currentPage += 1
            canLoadMorePages = !(animeList.isEmpty)
            if season == "winter" {
                winterItems.append(contentsOf: animeList.filter { $0.node.startSeason?.season == season && $0.node.startSeason?.year == year })
            } else if season == "spring" {
                springItems.append(contentsOf: animeList.filter { $0.node.startSeason?.season == season && $0.node.startSeason?.year == year })
            } else if season == "summer" {
                summerItems.append(contentsOf: animeList.filter { $0.node.startSeason?.season == season && $0.node.startSeason?.year == year })
            } else if season == "fall" {
                fallItems.append(contentsOf: animeList.filter { $0.node.startSeason?.season == season && $0.node.startSeason?.year == year })
            }
            isLoading = false
        } catch let error as NetworkError {
            isLoading = false
            
            // If 404 not found, usually means the season still has not been released yet
            if case NetworkError.notFound = error {
                canLoadMorePages = false
            } else {
                isLoadingError = true
            }
        } catch {
            isLoading = false
            isLoadingError = true
        }
    }
    
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
