//
//  TopView.swift
//  MALC
//
//  Created by Gao Tianrun on 19/4/24.
//

import SwiftUI
import SimpleToast

struct TopView: View {
    @StateObject private var controller = TopViewController()
    private let columns: [GridItem] = [
        GridItem(.adaptive(minimum: 150), alignment: .top),
    ]
    @State private var offset: CGFloat = -18
    @State private var isRefresh = false
    let networker = NetworkManager.shared
    
    // Display medals instead of numbers for the first 3 ranks
    private func rankToString(_ rank: Int?) -> String {
        if rank == nil {
            return ""
        }
        let ranks = ["🥇", "🥈", "🥉"]
        if rank! <= 3 {
            return ranks[rank! - 1]
        } else {
            return String(rank!)
        }
    }
    
    var body: some View {
        NavigationStack {
            VStack {
                if controller.type == .anime {
                    ZStack {
                        ScrollView {
                            LazyVGrid(columns: columns) {
                                ForEach(controller.animeItems, id: \.node.id) { item in
                                    AnimeMangaGridItem(item.node.id, item.node.title, .anime, rankToString(item.ranking?.rank))
                                        .task {
                                            await controller.loadMoreIfNeeded(currentItem: item)
                                        }
                                }
                            }
                        }
                        .navigationTitle("Top Anime")
                        if controller.isAnimeLoading {
                            LoadingView()
                        }
                        if controller.isItemsEmpty() && !controller.isAnimeLoading {
                            VStack {
                                Image(systemName: "medal")
                                    .resizable()
                                    .frame(width: 40, height: 50)
                                Text("Nothing found. ")
                                    .bold()
                            }
                        }
                    }
                } else if controller.type == .manga {
                    ZStack {
                        ScrollView {
                            LazyVGrid(columns: columns) {
                                ForEach(controller.mangaItems, id: \.node.id) { item in
                                    AnimeMangaGridItem(item.node.id, item.node.title, .manga, rankToString(item.ranking?.rank))
                                        .task {
                                            await controller.loadMoreIfNeeded(currentItem: item)
                                        }
                                }
                            }
                        }
                        .navigationTitle("Top Manga")
                        if controller.isMangaLoading {
                            LoadingView()
                        }
                        if controller.isItemsEmpty() && !controller.isMangaLoading {
                            VStack {
                                Image(systemName: "medal")
                                    .resizable()
                                    .frame(width: 40, height: 50)
                                Text("Nothing found. ")
                                    .bold()
                            }
                        }
                    }
                }
            }
            .toolbar {
                AnimeMangaToggle($controller.type, {
                    if controller.isItemsEmpty() {
                        await controller.refresh()
                    }
                })
            }
        }
        .task(id: isRefresh) {
            if controller.shouldRefresh() || isRefresh {
                await controller.refresh()
                isRefresh = false
            }
        }
        .refreshable {
            isRefresh = true
        }
        .simpleToast(isPresented: $controller.isLoadingError, options: alertToastOptions) {
            Text("Unable to load")
                .padding(20)
                .background(.red)
                .foregroundStyle(.white)
                .cornerRadius(10)
        }
    }
}
