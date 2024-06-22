//
//  SearchView.swift
//  MALC
//
//  Created by Gao Tianrun on 19/4/24.
//

import SwiftUI
import SimpleToast

struct SearchView: View {
    @StateObject private var controller = SearchViewController()
    @State private var isPresented = false
    @DebouncedState private var searchText = ""
    let networker = NetworkManager.shared
    
    var body: some View {
        NavigationStack {
            ZStack {
                if isPresented {
                    VStack {
                        Picker(selection: $controller.type, label: EmptyView()) {
                            Image(systemName: "tv.fill").tag(TypeEnum.anime)
                            Image(systemName: "book.fill").tag(TypeEnum.manga)
                        }
                        .onChange(of: controller.type) { _ in
                            if searchText.count > 2 {
                                controller.search(searchText)
                            }
                        }
                        .pickerStyle(.segmented)
                        .padding(.horizontal, 10)
                        .disabled(controller.isLoading)
                        List {
                            if controller.type == .anime {
                                ForEach(controller.animeItems, id: \.forEachId) { item in
                                    AnimeMangaListItem(item.id, item.node.title, .anime)
                                        .onAppear {
                                            controller.loadMoreIfNeeded(currentItem: item)
                                        }
                                }
                            } else if controller.type == .manga {
                                ForEach(controller.mangaItems, id: \.forEachId) { item in
                                    AnimeMangaListItem(item.id, item.node.title, .manga)
                                        .onAppear {
                                            controller.loadMoreIfNeeded(currentItem: item)
                                        }
                                }
                            }
                        }
                    }
                } else {
                    VStack {
                        Text("Hello")
                    }
                }
                if controller.isLoading {
                    LoadingView()
                }
            }
            .searchable_ios16(text: $searchText, isPresented: $isPresented, prompt: "Search MAL")
            .onChange(of: searchText) { value in
                if value.count > 2 {
                    controller.search(value)
                } else {
                    controller.animeItems = []
                    controller.mangaItems = []
                }
            }
            .onChange(of: isPresented) { _ in
                controller.animeItems = []
                controller.mangaItems = []
                controller.type = .anime
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
}
