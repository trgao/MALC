//
//  SeasonsView.swift
//  MALC
//
//  Created by Gao Tianrun on 19/4/24.
//

import SwiftUI
import SimpleToast

struct SeasonsView: View {
    @EnvironmentObject var appState: AppState
    @StateObject private var controller: SeasonsViewController
    @State private var viewId = UUID()
    private let columns: [GridItem] = [
        GridItem(.adaptive(minimum: 150), alignment: .top),
    ]
    let networker = NetworkManager.shared
    
    init(_ controller: SeasonsViewController) {
        self._controller = StateObject(wrappedValue: controller)
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                ScrollView {
                    if appState.season == "winter" {
                        LazyVGrid(columns: columns) {
                            ForEach(controller.winterItems) { item in
                                AnimeMangaGridItem(item.id, item.node.title, .anime)
                                    .task {
                                        await controller.loadMoreIfNeeded(currentItem: item)
                                    }
                            }
                        }
                    } else if appState.season == "spring" {
                        LazyVGrid(columns: columns) {
                            ForEach(controller.springItems) { item in
                                AnimeMangaGridItem(item.id, item.node.title, .anime)
                                    .task {
                                        await controller.loadMoreIfNeeded(currentItem: item)
                                    }
                            }
                        }
                    } else if appState.season == "summer" {
                        LazyVGrid(columns: columns) {
                            ForEach(controller.summerItems) { item in
                                AnimeMangaGridItem(item.id, item.node.title, .anime)
                                    .task {
                                        await controller.loadMoreIfNeeded(currentItem: item)
                                    }
                            }
                        }
                    } else {
                        LazyVGrid(columns: columns) {
                            ForEach(controller.fallItems) { item in
                                AnimeMangaGridItem(item.id, item.node.title, .anime)
                                    .task {
                                        await controller.loadMoreIfNeeded(currentItem: item)
                                    }
                            }
                        }
                    }
                    Rectangle()
                        .frame(height: 40)
                        .foregroundColor(.clear)
                }
                .navigationTitle("Seasons")
                .task(id: viewId) {
                    if appState.isSeasonsViewFirstLoad || appState.isSeasonsViewRefresh {
                        await controller.refresh()
                        appState.isSeasonsViewFirstLoad = false
                        appState.isSearchViewRefresh = false
                    }
                }
                .refreshable {
                    viewId = .init()
                    appState.isSeasonsViewRefresh = true
                }
                .simpleToast(isPresented: $controller.isLoadingError, options: alertToastOptions) {
                    Text("Unable to load")
                        .padding(20)
                        .background(.red)
                        .foregroundStyle(.white)
                        .cornerRadius(10)
                }
                .toolbar {
                    YearPicker(controller)
                        .disabled(controller.currentSeasonLoading())
                }
                SeasonPicker(controller)
                if controller.currentSeasonLoading() {
                    LoadingView()
                }
                if (appState.season == "winter" && controller.winterItems.isEmpty && !controller.isWinterLoading) || (appState.season == "spring" && controller.springItems.isEmpty && !controller.isSpringLoading) || (appState.season == "summer" && controller.summerItems.isEmpty && !controller.isSummerLoading) || (appState.season == "fall" && controller.fallItems.isEmpty && !controller.isFallLoading)  {
                    VStack {
                        Image(systemName: "calendar")
                            .resizable()
                            .frame(width: 40, height: 40)
                        Text("Nothing found. ")
                            .bold()
                    }
                }
            }
        }
    }
}
