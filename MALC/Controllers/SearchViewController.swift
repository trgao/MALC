//
//  SearchViewController.swift
//  MALC
//
//  Created by Gao Tianrun on 29/5/24.
//

import Foundation

@MainActor
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
    
    func isPageEmpty() -> Bool {
        return (networker.isSignedIn && animeSuggestions.isEmpty) || topAiringAnime.isEmpty || topUpcomingAnime.isEmpty || topPopularAnime.isEmpty || topPopularManga.isEmpty
    }
    
    func refresh() async -> Void {
        let task = Task {
            isPageLoading = true
            isLoadingError = false
            do {
                var animeSuggestions: [MALListAnime] = []
                if networker.isSignedIn {
                    animeSuggestions = try await networker.getUserAnimeSuggestionList()
                }
                let topAiringAnime = try await networker.getAnimeTopAiringList()
                let topUpcomingAnime = try await networker.getAnimeTopUpcomingList()
                let topPopularAnime = try await networker.getAnimeTopPopularList()
                let topPopularManga = try await networker.getMangaTopPopularList()
                self.animeSuggestions = animeSuggestions
                self.topAiringAnime = topAiringAnime
                self.topUpcomingAnime = topUpcomingAnime
                self.topPopularAnime = topPopularAnime
                self.topPopularManga = topPopularManga
                
                await withTaskGroup(of: Void.self) { taskGroup in
                    for anime in animeSuggestions {
                        taskGroup.addTask {
                            await self.networker.downloadImage(id: "anime\(anime.id)", urlString: anime.node.mainPicture?.medium)
                        }
                    }
                    
                    for anime in topAiringAnime {
                        taskGroup.addTask {
                            await self.networker.downloadImage(id: "anime\(anime.id)", urlString: anime.node.mainPicture?.medium)
                        }
                    }
                    
                    for anime in topUpcomingAnime {
                        taskGroup.addTask {
                            await self.networker.downloadImage(id: "anime\(anime.id)", urlString: anime.node.mainPicture?.medium)
                        }
                    }
                    
                    for anime in topPopularAnime {
                        taskGroup.addTask {
                            await self.networker.downloadImage(id: "anime\(anime.id)", urlString: anime.node.mainPicture?.medium)
                        }
                    }
                    
                    for manga in topPopularManga {
                        taskGroup.addTask {
                            await self.networker.downloadImage(id: "manga\(manga.id)", urlString: manga.node.mainPicture?.medium)
                        }
                    }
                }
                
                isPageLoading = false
            } catch {
                isPageLoading = false
                isLoadingError = true
            }
        }
        await task.value
    }
    
    func search(_ title: String) async -> Void {
        currentPage = 1
        canLoadMorePages = true
        isSearchLoading = true
        isLoadingError = false
        animeItems = []
        mangaItems = []
        do {
            if type == .anime {
                let animeList = try await networker.searchAnime(anime: title, page: currentPage)
                print(animeList.map{ $0.node.title })
                await withTaskGroup(of: Void.self) { taskGroup in
                    for anime in animeList {
                        taskGroup.addTask {
                            await self.networker.downloadImage(id: "anime\(anime.id)", urlString: anime.node.mainPicture?.medium)
                        }
                    }
                }
                
                currentPage = 2
                canLoadMorePages = !(animeList.isEmpty)
                animeItems = animeList
                isSearchLoading = false
            } else {
                let mangaList = try await networker.searchManga(manga: title, page: currentPage)
                await withTaskGroup(of: Void.self) { taskGroup in
                    for manga in mangaList {
                        taskGroup.addTask {
                            await self.networker.downloadImage(id: "manga\(manga.id)", urlString: manga.node.mainPicture?.medium)
                        }
                    }
                }
                
                currentPage = 2
                canLoadMorePages = !(mangaList.isEmpty)
                mangaItems = mangaList
                isSearchLoading = false
            }
        } catch {
            isSearchLoading = false
            isLoadingError = true
        }
    }
    
    private func loadMore(_ title: String) async -> Void {
        // only load more when it is not loading and there are more pages to be loaded
        guard !isSearchLoading && canLoadMorePages else {
            return
        }
        
        isSearchLoading = true
        isLoadingError = false
        do {
            if type == .anime {
                let animeList = try await networker.searchAnime(anime: title, page: currentPage)
                print(animeList.map{ $0.node.title })
                await withTaskGroup(of: Void.self) { taskGroup in
                    for anime in animeList {
                        taskGroup.addTask {
                            await self.networker.downloadImage(id: "anime\(anime.id)", urlString: anime.node.mainPicture?.medium)
                        }
                    }
                }
                
                currentPage += 1
                canLoadMorePages = !(animeList.isEmpty)
                animeItems.append(contentsOf: animeList)
                isSearchLoading = false
            } else {
                let mangaList = try await networker.searchManga(manga: title, page: currentPage)
                await withTaskGroup(of: Void.self) { taskGroup in
                    for manga in mangaList {
                        taskGroup.addTask {
                            await self.networker.downloadImage(id: "manga\(manga.id)", urlString: manga.node.mainPicture?.medium)
                        }
                    }
                }
                
                currentPage += 1
                canLoadMorePages = !(mangaList.isEmpty)
                mangaItems.append(contentsOf: mangaList)
                isSearchLoading = false
            }
        } catch let error {
            print(error)
            isSearchLoading = false
            isLoadingError = true
        }
    }
    
    func loadMoreIfNeeded(_ title: String, _ item: MALListAnime?) async -> Void {
        guard let item = item else {
            return await loadMore(title)
        }
        let thresholdIndex = animeItems.index(animeItems.endIndex, offsetBy: -5)
        if animeItems.firstIndex(where: { $0.node.id == item.node.id }) == thresholdIndex {
            return await loadMore(title)
        }
    }
    
    func loadMoreIfNeeded(_ title: String, _ item: MALListManga?) async -> Void {
        guard let item = item else {
            return await loadMore(title)
        }
        let thresholdIndex = mangaItems.index(mangaItems.endIndex, offsetBy: -5)
        if mangaItems.firstIndex(where: { $0.node.id == item.node.id }) == thresholdIndex {
            return await loadMore(title)
        }
    }
}

