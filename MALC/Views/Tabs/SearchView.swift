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
    @StateObject private var networker = NetworkManager.shared
    @State private var isPresented = false
    @DebouncedState private var searchText = ""
    
    var body: some View {
        NavigationStack {
            ZStack {
                if isPresented {
                    ZStack {
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
                            .disabled(controller.isPageLoading)
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
                        if controller.isSearchLoading {
                            LoadingView()
                        }
                    }
                } else {
                    if controller.isPageLoading {
                        LoadingView()
                    } else {
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
                        .onChange(of: networker.isSignedIn) { isSignedIn in
                            if isSignedIn {
                                controller.loadSuggestions()
                            }
                        }
                    }
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
