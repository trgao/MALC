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
                if controller.season == "winter" {
                    ScrollView {
                        LazyVGrid(columns: columns) {
                            ForEach(controller.winterItems) { item in
                                AnimeMangaGridItem(item.id, item.node.title, .anime)
                                    .task {
                                        await controller.loadMoreIfNeeded(currentItem: item)
                                    }
                            }
                        }
                    }
                    .navigationTitle("Winter")
                } else if controller.season == "spring" {
                    ScrollView {
                        LazyVGrid(columns: columns) {
                            ForEach(controller.springItems) { item in
                                AnimeMangaGridItem(item.id, item.node.title, .anime)
                                    .task {
                                        await controller.loadMoreIfNeeded(currentItem: item)
                                    }
                            }
                        }
                    }
                    .navigationTitle("Spring")
                } else if controller.season == "summer" {
                    ScrollView {
                        LazyVGrid(columns: columns) {
                            ForEach(controller.summerItems) { item in
                                AnimeMangaGridItem(item.id, item.node.title, .anime)
                                    .task {
                                        await controller.loadMoreIfNeeded(currentItem: item)
                                    }
                            }
                        }
                    }
                    .navigationTitle("Summer")
                } else if controller.season == "fall" {
                    ScrollView {
                        LazyVGrid(columns: columns) {
                            ForEach(controller.fallItems) { item in
                                AnimeMangaGridItem(item.id, item.node.title, .anime)
                                    .task {
                                        await controller.loadMoreIfNeeded(currentItem: item)
                                    }
                            }
                        }
                    }
                    .navigationTitle("Fall")
                }
                SeasonPicker(controller)
                    .disabled(controller.getCurrentSeasonLoading())
                if controller.getCurrentSeasonLoading() {
                    LoadingView()
                }
                if controller.isSeasonEmpty() && !controller.getCurrentSeasonLoading()  {
                    VStack {
                        Image(systemName: "calendar")
                            .resizable()
                            .frame(width: 40, height: 40)
                        Text("Nothing found. ")
                            .bold()
                    }
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
            .toolbar {
                YearPicker(controller)
                    .disabled(controller.getCurrentSeasonLoading())
            }
        }
    }
}
