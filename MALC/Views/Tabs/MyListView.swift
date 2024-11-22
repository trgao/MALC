//
//  MyListView.swift
//  MALC
//
//  Created by Gao Tianrun on 19/4/24.
//

import SwiftUI
import SimpleToast

struct MyListView: View {
    @ObservedObject private var controller = MyListViewController()
    @StateObject private var networker = NetworkManager.shared
    @State private var isRefresh = false
    @State private var isBack = false
    
    var body: some View {
        // Weird animation bug with list when reaching end and loading more
        NavigationStack {
            if networker.isSignedIn {
                VStack {
                    if controller.type == .anime {
                        ZStack {
                            List {
                                Section(controller.animeStatus.toString()) {
                                    ForEach(controller.animeItems, id: \.forEachId) { item in
                                        AnimeMangaListItem(item.id, item.node.title, controller.type, controller.animeStatus, item.node.numEpisodes, item.listStatus, { await controller.refresh() }, $isBack)
                                            .onAppear {
                                                Task {
                                                    await controller.loadMoreIfNeeded(currentItem: item)
                                                }
                                            }
                                    }
                                    if !controller.isAnimeLoading && controller.isItemsEmpty() {
                                        VStack {
                                            Image(systemName: "tv.fill")
                                                .resizable()
                                                .frame(width: 45, height: 40)
                                            Text("Nothing found. ")
                                                .bold()
                                        }
                                        .frame(maxWidth: .infinity)
                                        .padding(.vertical, 50)
                                    }
                                }
                            }
                            if controller.isAnimeLoading {
                                LoadingView()
                            }
                        }
                    } else if controller.type == .manga {
                        ZStack {
                            List {
                                Section(controller.mangaStatus.toString()) {
                                    ForEach(controller.mangaItems, id: \.forEachId) { item in
                                        AnimeMangaListItem(item.id, item.node.title, controller.type, controller.mangaStatus, item.node.numVolumes, item.node.numChapters, item.listStatus, { await controller.refresh() }, $isBack)
                                            .onAppear {
                                                Task {
                                                    await controller.loadMoreIfNeeded(currentItem: item)
                                                }
                                            }
                                    }
                                    if !controller.isMangaLoading && controller.isItemsEmpty() {
                                        VStack {
                                            Image(systemName: "book.fill")
                                                .resizable()
                                                .frame(width: 45, height: 40)
                                            Text("Nothing found. ")
                                                .bold()
                                        }
                                        .frame(maxWidth: .infinity)
                                        .padding(.vertical, 50)
                                    }
                                }
                            }
                            if controller.isMangaLoading {
                                LoadingView()
                            }
                        }
                    }
                }
                .simpleToast(isPresented: $controller.isLoadingError, options: alertToastOptions) {
                    Text("Unable to load")
                        .padding(20)
                        .background(.red)
                        .foregroundStyle(.white)
                        .cornerRadius(10)
                }
                .refreshable {
                    isRefresh = true
                }
                .task(id: isRefresh) {
                    if controller.shouldRefresh() || isRefresh {
                        await controller.refresh()
                        isRefresh = false
                    }
                }
                .task(id: isBack) {
                    if isBack {
                        await controller.refresh()
                        isBack = false
                    }
                }
                .toolbar {
                    ToolbarItem(placement: .topBarLeading) {
                        ListFilter(controller)
                    }
                    ToolbarItem(placement: .topBarTrailing) {
                        AnimeMangaToggle($controller.type, {
                            if controller.shouldRefresh() {
                                await controller.refresh()
                            }
                        })
                    }
                }
                .navigationTitle(controller.type == .anime ? "My Anime List" : "My Manga List")
            } else {
                VStack {
                    Image(systemName: "gear")
                        .resizable()
                        .frame(width: 40, height: 40)
                    Text("You have to sign in under Settings to view or edit your lists")
                        .bold()
                        .multilineTextAlignment(.center)
                }
                .frame(maxHeight: .infinity)
                .padding(30)
                .background(Color(.systemGray6))
            }
        }
    }
}
