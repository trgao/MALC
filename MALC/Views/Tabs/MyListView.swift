//
//  MyListView.swift
//  MALC
//
//  Created by Gao Tianrun on 19/4/24.
//

import SwiftUI
import SimpleToast

struct MyListView: View {
    @ObservedObject var controller = MyListViewController()
    @StateObject var networker = NetworkManager.shared
    
    var body: some View {
        NavigationStack {
            if networker.isSignedIn {
                ZStack {
                    List {
                        if controller.type == .anime {
                            Section(controller.animeStatus.toString()) {
                                ForEach(controller.animeItems, id: \.forEachId) { item in
                                    AnimeMangaListItem(item.id, item.node.title, controller.type, controller.animeStatus, item.node.numEpisodes, item.listStatus)
                                        .onAppear {
                                            controller.loadMoreIfNeeded(currentItem: item)
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
                            .navigationTitle("My Anime List")
                        } else if controller.type == .manga {
                            Section(controller.mangaStatus.toString()) {
                                ForEach(controller.mangaItems, id: \.forEachId) { item in
                                    AnimeMangaListItem(item.id, item.node.title, controller.type, controller.mangaStatus, item.node.numVolumes, item.node.numChapters, item.listStatus)
                                        .onAppear {
                                            controller.loadMoreIfNeeded(currentItem: item)
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
                            .navigationTitle("My Manga List")
                        }
                    }
                    .simpleToast(isPresented: $controller.isLoadingError, options: alertToastOptions) {
                        Text("Unable to load")
                            .padding(20)
                            .background(.red)
                            .foregroundStyle(.white)
                            .cornerRadius(10)
                    }
                    .refreshable{
                        controller.refresh()
                    }
                    .onChange(of: controller.animeStatus) { _ in
                        controller.refresh(true)
                    }
                    .onChange(of: controller.animeSort) { _ in
                        controller.refresh(true)
                    }
                    .onChange(of: controller.mangaStatus) { _ in
                        controller.refresh(true)
                    }
                    .onChange(of: controller.mangaSort) { _ in
                        controller.refresh(true)
                    }
                    .onChange(of: networker.isSignedIn) { _ in
                        controller.refresh(true)
                    }
                    .onAppear {
                        controller.objectWillChange.send()
                        controller.refresh()
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
                        AnimeMangaToggle($controller.type, { controller.refresh() })
                    }
                }
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
