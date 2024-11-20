//
//  TopViewController.swift
//  MALC
//
//  Created by Gao Tianrun on 1/5/24.
//

import Foundation

@MainActor
class TopViewController: ObservableObject {
    @Published var animeItems = [MALListAnime]()
    @Published var mangaItems = [MALListManga]()
    @Published var isLoading = true
    @Published var isLoadingError = false
    @Published var type: TypeEnum = .anime
    private var currentPage = 1
    private var canLoadMorePages = true
    let networker = NetworkManager.shared
    
    func refresh() async -> Void {
        let task = Task {
            currentPage = 1
            canLoadMorePages = true
            isLoading = true
            isLoadingError = false
            do {
                if type == .anime {
                    let animeList = try await networker.getTopAnimeList(page: currentPage)
                    
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
                    isLoading = false
                } else {
                    let mangaList = try await networker.getTopMangaList(page: currentPage)
                    
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
                    isLoading = false
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
        guard (type == .anime && animeItems.count > 0) || (type == .manga && mangaItems.count > 0) else {
            return
        }
        
        isLoading = true
        isLoadingError = false
        do {
            if type == .anime {
                let animeList = try await networker.getTopAnimeList(page: currentPage)
                
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
                isLoading = false
            } else {
                let mangaList = try await networker.getTopMangaList(page: currentPage)
                
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
                isLoading = false
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
        let thresholdIndex = animeItems.index(animeItems.endIndex, offsetBy: -5)
        if animeItems.firstIndex(where: { $0.node.id == item.node.id }) == thresholdIndex {
            return await loadMore()
        }
    }
    
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
