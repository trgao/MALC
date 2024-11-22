//
//  SearchViewController.swift
//  MALC
//
//  Created by Gao Tianrun on 29/5/24.
//

import Foundation

@MainActor
class SearchViewController: ObservableObject {
    // Anime search list variables
    @Published var animeItems = [MALListAnime]()
    @Published var isAnimeSearchLoading = false
    private var currentAnimePage = 1
    private var canLoadMoreAnimePages = true
    
    // Manga search list variables
    @Published var mangaItems = [MALListManga]()
    @Published var isMangaSearchLoading = false
    private var currentMangaPage = 1
    private var canLoadMoreMangaPages = true
    
    // Non-search page list variables
    @Published var animeSuggestions = [MALListAnime]()
    @Published var topAiringAnime = [MALListAnime]()
    @Published var topUpcomingAnime = [MALListAnime]()
    @Published var topPopularAnime = [MALListAnime]()
    @Published var topPopularManga = [MALListManga]()
    
    // Common variables
    @Published var isPageLoading = false
    @Published var isLoadingError = false
    @Published var type: TypeEnum = .anime
    let networker = NetworkManager.shared
    
    // Check if the lists for the non-search page are empty
    func isPageEmpty() -> Bool {
        return (networker.isSignedIn && animeSuggestions.isEmpty) || topAiringAnime.isEmpty || topUpcomingAnime.isEmpty || topPopularAnime.isEmpty || topPopularManga.isEmpty
    }
    
    // Check if the current anime/manga search list is empty
    func isItemsEmpty() -> Bool {
        return (type == .anime && animeItems.isEmpty) || (type == .manga && mangaItems.isEmpty)
    }
    
    // Refresh the non-search page
    func refresh() async -> Void {
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
    
    // Search for the anime/manga with the title
    func search(_ title: String, _ clear: Bool = false) async -> Void {
        // Reset all lists if need to clear (for new searches)
        if clear {
            animeItems = []
            mangaItems = []
        }
        isLoadingError = false
        if type == .anime {
            do {
                currentAnimePage = 1
                canLoadMoreAnimePages = true
                isAnimeSearchLoading = true
                let animeList = try await networker.searchAnime(anime: title, page: currentAnimePage)
                await withTaskGroup(of: Void.self) { taskGroup in
                    for anime in animeList {
                        taskGroup.addTask {
                            await self.networker.downloadImage(id: "anime\(anime.id)", urlString: anime.node.mainPicture?.medium)
                        }
                    }
                }
                
                currentAnimePage = 2
                canLoadMoreAnimePages = !(animeList.isEmpty)
                animeItems = animeList
                isAnimeSearchLoading = false
            } catch {
                isAnimeSearchLoading = false
                isLoadingError = true
            }
        } else {
            do {
                currentMangaPage = 1
                canLoadMoreMangaPages = true
                isMangaSearchLoading = true
                let mangaList = try await networker.searchManga(manga: title, page: currentMangaPage)
                await withTaskGroup(of: Void.self) { taskGroup in
                    for manga in mangaList {
                        taskGroup.addTask {
                            await self.networker.downloadImage(id: "manga\(manga.id)", urlString: manga.node.mainPicture?.medium)
                        }
                    }
                }
                
                currentMangaPage = 2
                canLoadMoreMangaPages = !(mangaList.isEmpty)
                mangaItems = mangaList
                isMangaSearchLoading = false
            } catch {
                isMangaSearchLoading = false
                isLoadingError = true
            }
        }
    }
    
    // Load more anime/manga with the title
    private func loadMore(_ title: String) async -> Void {
        if type == .anime {
            // only load more when it is not loading and there are more pages to be loaded
            guard !isAnimeSearchLoading && canLoadMoreAnimePages else {
                return
            }
            
            // only load more when there are already items on the page
            guard animeItems.count > 0 else {
                return
            }
            
            isAnimeSearchLoading = true
            isLoadingError = false
            do {
                let animeList = try await networker.searchAnime(anime: title, page: currentAnimePage)
                await withTaskGroup(of: Void.self) { taskGroup in
                    for anime in animeList {
                        taskGroup.addTask {
                            await self.networker.downloadImage(id: "anime\(anime.id)", urlString: anime.node.mainPicture?.medium)
                        }
                    }
                }
                
                currentAnimePage += 1
                canLoadMoreAnimePages = !(animeList.isEmpty)
                animeItems.append(contentsOf: animeList)
                isAnimeSearchLoading = false
            } catch {
                isAnimeSearchLoading = false
                isLoadingError = true
            }
        } else if type == .manga {
            // only load more when it is not loading and there are more pages to be loaded
            guard !isMangaSearchLoading && canLoadMoreMangaPages else {
                return
            }
            
            // only load more when there are already items on the page
            guard mangaItems.count > 0 else {
                return
            }
            
            isMangaSearchLoading = true
            isLoadingError = false
            do {
                let mangaList = try await networker.searchManga(manga: title, page: currentMangaPage)
                await withTaskGroup(of: Void.self) { taskGroup in
                    for manga in mangaList {
                        taskGroup.addTask {
                            await self.networker.downloadImage(id: "manga\(manga.id)", urlString: manga.node.mainPicture?.medium)
                        }
                    }
                }
                
                currentMangaPage += 1
                canLoadMoreMangaPages = !(mangaList.isEmpty)
                mangaItems.append(contentsOf: mangaList)
                isMangaSearchLoading = false
            } catch {
                isMangaSearchLoading = false
                isLoadingError = true
            }
        }
    }
    
    // Load more anime when reaching the 5th last anime in list
    func loadMoreIfNeeded(_ title: String, _ item: MALListAnime?) async -> Void {
        guard let item = item else {
            return await loadMore(title)
        }
        let thresholdIndex = animeItems.index(animeItems.endIndex, offsetBy: -5)
        if animeItems.firstIndex(where: { $0.node.id == item.node.id }) == thresholdIndex {
            return await loadMore(title)
        }
    }
    
    // Load more manga when reaching the 5th last manga in list
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

