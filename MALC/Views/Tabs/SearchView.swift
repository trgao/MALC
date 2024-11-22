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
    @StateObject var networker = NetworkManager.shared
    @State private var isPresented = false
    @State private var isRefresh = false
    @DebouncedState private var searchText = ""
    @State private var previousSearch = ""
    
    var body: some View {
        // Weird animation bug with list when reaching end and loading more
        NavigationStack {
            ZStack {
                if isPresented {
                    VStack {
                        Picker(selection: $controller.type, label: EmptyView()) {
                            Image(systemName: "tv.fill").tag(TypeEnum.anime)
                            Image(systemName: "book.fill").tag(TypeEnum.manga)
                        }
                        .onChange(of: controller.type) { _ in
                            if searchText.count > 2 && controller.isItemsEmpty() {
                                Task {
                                    await controller.search(searchText)
                                }
                            }
                        }
                        .pickerStyle(.segmented)
                        .padding(.horizontal, 10)
                        .disabled(controller.isPageLoading)
                        if controller.type == .anime {
                            ZStack {
                                List {
                                    ForEach(controller.animeItems, id: \.forEachId) { item in
                                        AnimeMangaListItem(item.id, item.node.title, .anime)
                                            .onAppear {
                                                Task {
                                                    await controller.loadMoreIfNeeded(searchText, item)
                                                }
                                            }
                                    }
                                }
                                if controller.isAnimeSearchLoading {
                                    LoadingView()
                                }
                            }
                        } else if controller.type == .manga {
                            ZStack {
                                List {
                                    ForEach(controller.mangaItems, id: \.forEachId) { item in
                                        AnimeMangaListItem(item.id, item.node.title, .manga)
                                            .onAppear {
                                                Task {
                                                    await controller.loadMoreIfNeeded(searchText, item)
                                                }
                                            }
                                    }
                                }
                                if controller.isMangaSearchLoading {
                                    LoadingView()
                                }
                            }
                        }
                    }
                } else {
                    if controller.isPageLoading && !isRefresh {
                        LoadingView()
                    } else {
                        ZStack {
                            ScrollView {
                                if networker.isSignedIn {
                                    VStack {
                                        Text("For You")
                                            .bold()
                                            .frame(maxWidth: .infinity, alignment: .leading)
                                            .padding(.horizontal, 15)
                                            .font(.system(size: 17))
                                        ScrollView(.horizontal, showsIndicators: false) {
                                            HStack(alignment: .top) {
                                                Rectangle()
                                                    .frame(width: 10)
                                                    .foregroundColor(.clear)
                                                ForEach(controller.animeSuggestions) { item in
                                                    NavigationLink {
                                                        AnimeDetailsView(item.id)
                                                    } label: {
                                                        AnimeMangaGridItem(item.id, item.node.title, .anime)
                                                    }
                                                    .buttonStyle(.plain)
                                                }
                                                Rectangle()
                                                    .frame(width: 10)
                                                    .foregroundColor(.clear)
                                            }
                                            .padding(2)
                                        }
                                    }
                                }
                                VStack {
                                    Text("Top Airing")
                                        .bold()
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                        .padding(.horizontal, 15)
                                        .font(.system(size: 17))
                                    ScrollView(.horizontal, showsIndicators: false) {
                                        HStack(alignment: .top) {
                                            Rectangle()
                                                .frame(width: 10)
                                                .foregroundColor(.clear)
                                            ForEach(controller.topAiringAnime) { item in
                                                NavigationLink {
                                                    AnimeDetailsView(item.id)
                                                } label: {
                                                    AnimeMangaGridItem(item.id, item.node.title, .anime)
                                                }
                                                .buttonStyle(.plain)
                                            }
                                            Rectangle()
                                                .frame(width: 10)
                                                .foregroundColor(.clear)
                                        }
                                        .padding(2)
                                    }
                                }
                                VStack {
                                    Text("Top Upcoming")
                                        .bold()
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                        .padding(.horizontal, 15)
                                        .font(.system(size: 17))
                                    ScrollView(.horizontal, showsIndicators: false) {
                                        HStack(alignment: .top) {
                                            Rectangle()
                                                .frame(width: 10)
                                                .foregroundColor(.clear)
                                            ForEach(controller.topUpcomingAnime) { item in
                                                NavigationLink {
                                                    AnimeDetailsView(item.id)
                                                } label: {
                                                    AnimeMangaGridItem(item.id, item.node.title, .anime)
                                                }
                                                .buttonStyle(.plain)
                                            }
                                            Rectangle()
                                                .frame(width: 10)
                                                .foregroundColor(.clear)
                                        }
                                        .padding(2)
                                    }
                                }
                                VStack {
                                    Text("Most Popular Anime")
                                        .bold()
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                        .padding(.horizontal, 15)
                                        .font(.system(size: 17))
                                    ScrollView(.horizontal, showsIndicators: false) {
                                        HStack(alignment: .top) {
                                            Rectangle()
                                                .frame(width: 10)
                                                .foregroundColor(.clear)
                                            ForEach(controller.topPopularAnime) { item in
                                                NavigationLink {
                                                    AnimeDetailsView(item.id)
                                                } label: {
                                                    AnimeMangaGridItem(item.id, item.node.title, .anime)
                                                }
                                                .buttonStyle(.plain)
                                            }
                                            Rectangle()
                                                .frame(width: 10)
                                                .foregroundColor(.clear)
                                        }
                                        .padding(2)
                                    }
                                }
                                VStack {
                                    Text("Most Popular Manga")
                                        .bold()
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                        .padding(.horizontal, 15)
                                        .font(.system(size: 17))
                                    ScrollView(.horizontal, showsIndicators: false) {
                                        HStack(alignment: .top) {
                                            Rectangle()
                                                .frame(width: 10)
                                                .foregroundColor(.clear)
                                            ForEach(controller.topPopularManga) { item in
                                                NavigationLink {
                                                    MangaDetailsView(item.id)
                                                } label: {
                                                    AnimeMangaGridItem(item.id, item.node.title, .manga)
                                                }
                                                .buttonStyle(.plain)
                                            }
                                            Rectangle()
                                                .frame(width: 10)
                                                .foregroundColor(.clear)
                                        }
                                        .padding(2)
                                    }
                                }
                            }
                            if controller.isPageLoading && isRefresh {
                                LoadingView()
                            }
                        }
                    }
                }
            }
            .task(id: isRefresh) {
                if controller.isPageEmpty() || isRefresh {
                    await controller.refresh()
                    isRefresh = false
                }
            }
            .refreshable {
                isRefresh = true
            }
            .searchable_ios16(text: $searchText, isPresented: $isPresented, prompt: "Search MAL")
            .task(id: searchText) {
                if searchText.count > 2 {
                    if previousSearch != searchText {
                        await controller.search(searchText)
                        previousSearch = searchText
                    }
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
