//
//  SeasonsView.swift
//  MALC
//
//  Created by Gao Tianrun on 19/4/24.
//

import SwiftUI
import SimpleToast

struct SeasonsView: View {
    @StateObject var controller = SeasonsViewController()
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
                                    .onAppear {
                                        controller.loadMoreIfNeeded(currentItem: item)
                                    }
                            }
                        }
                    } else if controller.season == "spring" {
                        LazyVGrid(columns: columns) {
                            ForEach(controller.springItems) { item in
                                AnimeMangaGridItem(item.id, item.node.title, .anime)
                                    .onAppear {
                                        controller.loadMoreIfNeeded(currentItem: item)
                                    }
                            }
                        }
                    } else if controller.season == "summer" {
                        LazyVGrid(columns: columns) {
                            ForEach(controller.summerItems) { item in
                                AnimeMangaGridItem(item.id, item.node.title, .anime)
                                    .onAppear {
                                        controller.loadMoreIfNeeded(currentItem: item)
                                    }
                            }
                        }
                    } else {
                        LazyVGrid(columns: columns) {
                            ForEach(controller.fallItems) { item in
                                AnimeMangaGridItem(item.id, item.node.title, .anime)
                                    .onAppear {
                                        controller.loadMoreIfNeeded(currentItem: item)
                                    }
                            }
                        }
                    }
                    Rectangle()
                        .frame(height: 40)
                        .foregroundColor(.clear)
                }
                .navigationTitle("Seasons")
                .refreshable {
                    controller.refresh(controller.season)
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
                if (controller.season == "winter" && controller.winterItems.isEmpty && !controller.isWinterLoading) || (controller.season == "spring" && controller.springItems.isEmpty && !controller.isSpringLoading) || (controller.season == "summer" && controller.summerItems.isEmpty && !controller.isSummerLoading) || (controller.season == "fall" && controller.fallItems.isEmpty && !controller.isFallLoading)  {
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
