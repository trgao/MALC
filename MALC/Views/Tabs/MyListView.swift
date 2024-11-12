//
//  MyListView.swift
//  MALC
//
//  Created by Gao Tianrun on 19/4/24.
//

import SwiftUI
import SimpleToast

struct MyListView: View {
    @EnvironmentObject var appState: AppState
    @ObservedObject private var controller = MyListViewController()
    @StateObject private var networker = NetworkManager.shared
    @State private var viewId = UUID()
    
    var body: some View {
        NavigationStack {
            if networker.isSignedIn {
                ZStack {
                    List {
                        if controller.type == .anime {
                            Section(controller.animeStatus.toString()) {
                                ForEach(controller.animeItems, id: \.forEachId) { item in
                                    AnimeMangaListItem(item.id, item.node.title, controller.type, controller.animeStatus, item.node.numEpisodes, item.listStatus, { await controller.refresh() })
                                        .task {
                                            await controller.loadMoreIfNeeded(currentItem: item)
                                        }
                                }
                                if !controller.isLoading && controller.animeItems.isEmpty {
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
                        } else if controller.type == .manga {
                            Section(controller.mangaStatus.toString()) {
                                ForEach(controller.mangaItems, id: \.forEachId) { item in
                                    AnimeMangaListItem(item.id, item.node.title, controller.type, controller.mangaStatus, item.node.numVolumes, item.node.numChapters, item.listStatus, { await controller.refresh() })
                                        .task {
                                            await controller.loadMoreIfNeeded(currentItem: item)
                                        }
                                }
                                if !controller.isLoading && controller.mangaItems.isEmpty {
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
                    }
                    .simpleToast(isPresented: $controller.isLoadingError, options: alertToastOptions) {
                        Text("Unable to load")
                            .padding(20)
                            .background(.red)
                            .foregroundStyle(.white)
                            .cornerRadius(10)
                    }
                    .refreshable {
                        await controller.refresh()
                    }
                    .task {
                        controller.objectWillChange.send()
                        await controller.refresh()
                    }
                    if controller.isLoading {
                        LoadingView()
                    }
                }
                .toolbar {
                    ToolbarItem(placement: .topBarLeading) {
                        ListFilter(controller)
                    }
                    ToolbarItem(placement: .topBarTrailing) {
                        AnimeMangaToggle($controller.type, { await controller.refresh() })
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
