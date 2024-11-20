//
//  SeasonsView.swift
//  MALC
//
//  Created by Gao Tianrun on 19/4/24.
//

import SwiftUI
import SimpleToast

struct SeasonsView: View {
    @StateObject private var controller = SeasonsViewController()
    @State private var isRefresh = false
    private let columns: [GridItem] = [
        GridItem(.adaptive(minimum: 150), alignment: .top),
    ]
    let networker = NetworkManager.shared
    
    var body: some View {
        NavigationStack {
            ZStack {
                ScrollView {
                    if controller.season == "winter" {
                        LazyVGrid(columns: columns) {
                            ForEach(controller.winterItems) { item in
                                AnimeMangaGridItem(item.id, item.node.title, .anime)
                                    .task {
                                        await controller.loadMoreIfNeeded(currentItem: item)
                                    }
                            }
                        }
                    } else if controller.season == "spring" {
                        LazyVGrid(columns: columns) {
                            ForEach(controller.springItems) { item in
                                AnimeMangaGridItem(item.id, item.node.title, .anime)
                                    .task {
                                        await controller.loadMoreIfNeeded(currentItem: item)
                                    }
                            }
                        }
                    } else if controller.season == "summer" {
                        LazyVGrid(columns: columns) {
                            ForEach(controller.summerItems) { item in
                                AnimeMangaGridItem(item.id, item.node.title, .anime)
                                    .task {
                                        await controller.loadMoreIfNeeded(currentItem: item)
                                    }
                            }
                        }
                    } else if controller.season == "fall" {
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
                .task(id: isRefresh) {
                    if controller.isSeasonEmpty() || isRefresh {
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
                .toolbar {
                    YearPicker(controller)
                        .disabled(controller.isLoading)
                }
                SeasonPicker(controller)
                if controller.isLoading {
                    LoadingView()
                }
                if controller.isSeasonEmpty() && !controller.isLoading  {
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
