//
//  JikanGridInfiniteScrollViewController.swift
//  MALC
//
//  Created by Gao Tianrun on 1/5/24.
//

import Foundation

@MainActor
class JikanGridInfiniteScrollViewController: ObservableObject {
    @Published var items = [JikanListItem]()
    @Published var isLoading = false
    @Published var isLoadingError = false
    private var ids: Set<Int> = []
    private var currentPage = 1
    private var canLoadMorePages = true
    private let urlExtend: String
    private let type: TypeEnum
    let networker = NetworkManager.shared
    
    init(_ urlExtend: String, _ type: TypeEnum) {
        self.urlExtend = urlExtend
        self.type = type
        Task {
            await refresh()
        }
    }
    
    func refresh() async -> Void {
        currentPage = 1
        canLoadMorePages = true
        isLoading = true
        isLoadingError = false
        do {
            if type == .anime {
                let animeList = try await networker.getAnimeList(urlExtend: urlExtend, page: currentPage)
                
                await withTaskGroup(of: Void.self) { taskGroup in
                    for anime in animeList {
                        taskGroup.addTask {
                            await self.networker.downloadImage(id: "anime\(anime.id)", urlString: anime.images?.jpg.imageUrl)
                        }
                    }
                }
                
                currentPage = 2
                canLoadMorePages = !(animeList.isEmpty)
                for item in animeList {
                    if !ids.contains(item.id) {
                        ids.insert(item.id)
                        items.append(item)
                    }
                }
                isLoading = false
            } else if type == .manga {
                let mangaList = try await networker.getMangaList(urlExtend: urlExtend, page: currentPage)
                
                await withTaskGroup(of: Void.self) { taskGroup in
                    for manga in mangaList {
                        taskGroup.addTask {
                            await self.networker.downloadImage(id: "manga\(manga.id)", urlString: manga.images?.jpg.imageUrl)
                        }
                    }
                }
                
                currentPage = 2
                canLoadMorePages = !(mangaList.isEmpty)
                for item in mangaList {
                    if !ids.contains(item.id) {
                        ids.insert(item.id)
                        items.append(item)
                    }
                }
                isLoading = false
            }
        } catch {
            isLoading = false
            isLoadingError = true
        }
    }
    
    private func loadMore() async -> Void {
        // only load more when it is not loading and there are more pages to be loaded
        guard !isLoading && canLoadMorePages else {
            return
        }
        
        // only load more when there are already items on the page
        guard items.count > 0 else {
            return
        }
        
        isLoading = true
        isLoadingError = false
        do {
            if type == .anime {
                let animeList = try await networker.getAnimeList(urlExtend: urlExtend, page: currentPage)
                
                await withTaskGroup(of: Void.self) { taskGroup in
                    for anime in animeList {
                        taskGroup.addTask {
                            await self.networker.downloadImage(id: "anime\(anime.id)", urlString: anime.images?.jpg.imageUrl)
                        }
                    }
                }
                
                currentPage += 1
                canLoadMorePages = !(animeList.isEmpty)
                for item in animeList {
                    if !ids.contains(item.id) {
                        ids.insert(item.id)
                        items.append(item)
                    }
                }
                isLoading = false
            } else if type == .manga {
                let mangaList = try await networker.getMangaList(urlExtend: urlExtend, page: currentPage)
                
                await withTaskGroup(of: Void.self) { taskGroup in
                    for manga in mangaList {
                        taskGroup.addTask {
                            await self.networker.downloadImage(id: "manga\(manga.id)", urlString: manga.images?.jpg.imageUrl)
                        }
                    }
                }
                
                currentPage += 1
                canLoadMorePages = !(mangaList.isEmpty)
                for item in mangaList {
                    if !ids.contains(item.id) {
                        ids.insert(item.id)
                        items.append(item)
                    }
                }
                isLoading = false
            }
        } catch {
            isLoading = false
            isLoadingError = true
        }
    }
    
    func loadMoreIfNeeded(currentItem item: JikanListItem?) async -> Void {
        guard let item = item else {
            return await loadMore()
        }
        let thresholdIndex = items.index(items.endIndex, offsetBy: -5)
        if items.firstIndex(where: { $0.id == item.id }) == thresholdIndex {
            return await loadMore()
        }
    }
}
