//
//  TopView.swift
//  MALC
//
//  Created by Gao Tianrun on 19/4/24.
//

import SwiftUI
import SimpleToast

struct TopView: View {
    @StateObject var controller = TopViewController()
    private let columns: [GridItem] = [
        GridItem(.adaptive(minimum: 150), alignment: .top),
    ]
    @State private var offset: CGFloat = -18
    let networker = NetworkManager.shared
    
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
            ZStack {
                if controller.type == .anime {
                    ScrollView {
                        LazyVGrid(columns: columns) {
                            ForEach(controller.animeItems, id: \.node.id) { item in
                                AnimeMangaGridItem(item.node.id, item.node.title, .anime, rankToString(item.ranking?.rank))
                                    .onAppear {
                                        controller.loadMoreIfNeeded(currentItem: item)
                                    }
                            }
                        }
                    }
                    .navigationTitle("Top Anime")
                    .refreshable {
                        controller.refresh()
                    }
                    .simpleToast(isPresented: $controller.isLoadingError, options: alertToastOptions) {
                        Text("Unable to load")
                            .padding(20)
                            .background(.red)
                            .foregroundStyle(.white)
                            .cornerRadius(10)
                    }
                } else if controller.type == .manga {
                    ScrollView {
                        LazyVGrid(columns: columns) {
                            ForEach(controller.mangaItems, id: \.node.id) { item in
                                AnimeMangaGridItem(item.node.id, item.node.title, .manga, rankToString(item.ranking?.rank))
                                    .onAppear {
                                        controller.loadMoreIfNeeded(currentItem: item)
                                    }
                            }
                        }
                    }
                    .navigationTitle("Top Manga")
                    .refreshable {
                        controller.refresh()
                    }
                    .simpleToast(isPresented: $controller.isLoadingError, options: alertToastOptions) {
                        Text("Unable to load")
                            .padding(20)
                            .background(.red)
                            .foregroundStyle(.white)
                            .cornerRadius(10)
                    }
                }
                if controller.isLoading {
                    LoadingView()
                }
                if (controller.type == .anime && controller.animeItems.isEmpty && !controller.isLoading) || (controller.type == .manga && controller.mangaItems.isEmpty && !controller.isLoading) {
                    VStack {
                        Image(systemName: "medal")
                            .resizable()
                            .frame(width: 40, height: 50)
                        Text("Nothing found. ")
                            .bold()
                    }
                }
            }
            .toolbar {
                AnimeMangaToggle($controller.type, controller.refresh)
            }
        }
    }
}
