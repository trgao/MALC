//
//  TopViewController.swift
//  MALC
//
//  Created by Gao Tianrun on 1/5/24.
//

import Foundation

@MainActor
class TopViewController: ObservableObject {
    // Anime list variables
    @Published var animeItems = [MALListAnime]()
    @Published var isAnimeLoading = false
    private var currentAnimePage = 1
    private var canLoadMoreAnimePages = true
    
    // Manga list variables
    @Published var mangaItems = [MALListManga]()
    @Published var isMangaLoading = false
    private var currentMangaPage = 1
    private var canLoadMoreMangaPages = true
    
    // Common variables
    @Published var isLoadingError = false
    @Published var type: TypeEnum = .anime
    let networker = NetworkManager.shared
    
    // Check if the current anime/manga list is empty
    func isItemsEmpty() -> Bool {
        return (type == .anime && animeItems.isEmpty) || (type == .manga && mangaItems.isEmpty)
    }
    
    // Check if the current anime/manga list should be refreshed
    func shouldRefresh() -> Bool {
        return (type == .anime && animeItems.isEmpty && canLoadMoreAnimePages) || (type == .manga && mangaItems.isEmpty && canLoadMoreMangaPages)
    }
    
    // Refresh the current anime/manga list
    func refresh() async -> Void {
        isLoadingError = false
        if type == .anime {
            do {
                currentAnimePage = 1
                canLoadMoreAnimePages = true
                isAnimeLoading = true
                let animeList = try await networker.getTopAnimeList(page: currentAnimePage)
                
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
                isAnimeLoading = false
            } catch {
                isAnimeLoading = false
                isLoadingError = true
            }
        } else {
            do {
                currentMangaPage = 1
                canLoadMoreMangaPages = true
                isMangaLoading = true
                let mangaList = try await networker.getTopMangaList(page: currentMangaPage)
                
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
                isMangaLoading = false
            } catch {
                isMangaLoading = false
                isLoadingError = true
            }
        }
    }
    
    // Load more of the current anime/manga list
    private func loadMore() async -> Void {
        if type == .anime {
            // only load more when it is not loading and there are more pages to be loaded
            guard !isAnimeLoading && canLoadMoreAnimePages else {
                return
            }
            
            // only load more when there are already items on the page
            guard animeItems.count > 0 else {
                return
            }
            
            isAnimeLoading = true
            isLoadingError = false
            do {
                let animeList = try await networker.getTopAnimeList(page: currentAnimePage)
                
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
                isAnimeLoading = false
            } catch {
                isAnimeLoading = false
                isLoadingError = true
            }
        } else if type == .manga {
            // only load more when it is not loading and there are more pages to be loaded
            guard !isMangaLoading && canLoadMoreMangaPages else {
                return
            }
            
            // only load more when there are already items on the page
            guard mangaItems.count > 0 else {
                return
            }
            
            isMangaLoading = true
            isLoadingError = false
            do {
                let mangaList = try await networker.getTopMangaList(page: currentMangaPage)
                
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
                isMangaLoading = false
            } catch {
                isMangaLoading = false
                isLoadingError = true
            }
        }
    }
    
    // Load more anime when reaching the 5th last anime in list
    func loadMoreIfNeeded(currentItem item: MALListAnime?) async -> Void {
        guard let item = item else {
            return await loadMore()
        }
        let thresholdIndex = animeItems.index(animeItems.endIndex, offsetBy: -5)
        if animeItems.firstIndex(where: { $0.node.id == item.node.id }) == thresholdIndex {
            return await loadMore()
        }
    }
    
    // Load more manga when reaching the 5th last manga in list
    func loadMoreIfNeeded(currentItem item: MALListManga?) async -> Void {
        guard let item = item else {
            return await loadMore()
        }
        let thresholdIndex = mangaItems.index(mangaItems.endIndex, offsetBy: -5)
        if mangaItems.firstIndex(where: { $0.node.id == item.node.id }) == thresholdIndex {
            return await loadMore()
        }
    }
}
