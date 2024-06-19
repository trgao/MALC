//
//  SeasonsView.swift
//  MALC
//
//  Created by Gao Tianrun on 19/4/24.
//

import SwiftUI

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
                    LazyVGrid(columns: columns) {
                        ForEach(controller.items) { item in
                            AnimeMangaGridItem(item.id, item.node.title, .anime)
                                .onAppear {
                                    controller.loadMoreIfNeeded(currentItem: item)
                                }
                        }
                    }
                    Rectangle()
                        .frame(height: 40)
                        .foregroundColor(.clear)
                }
                .navigationTitle("Seasons")
                .refreshable {
                    controller.refresh()
                }
                .alert("Unable to load", isPresented: $controller.isLoadingError) {
                    Button("Ok") {}
                }
                .toolbar {
                    YearPicker(controller)
                        .disabled(controller.isLoading)
                }
                SeasonPicker(controller)
                    .disabled(controller.isLoading)
                if controller.isLoading {
                    LoadingView()
                }
                if controller.items.isEmpty && !controller.isLoading {
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
