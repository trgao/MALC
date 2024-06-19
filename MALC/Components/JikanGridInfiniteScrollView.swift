//
//  JikanGridInfiniteScrollView.swift
//  MALC
//
//  Created by Gao Tianrun on 1/5/24.
//

import SwiftUI

struct JikanGridInfiniteScrollView: View {
    @StateObject var controller: JikanGridInfiniteScrollViewController
    private let columns: [GridItem] = [
        GridItem(.adaptive(minimum: 150), alignment: .top),
    ]
    private let title: String
    private let urlExtend: String
    private let type: TypeEnum
    
    init(_ title: String, _ urlExtend: String, _ type: TypeEnum) {
        self.title = title
        self.urlExtend = urlExtend
        self.type = type
        self._controller = StateObject(wrappedValue: JikanGridInfiniteScrollViewController(urlExtend, type))
    }
    
    var body: some View {
        ZStack {
            ScrollView {
                LazyVGrid(columns: columns) {
                    ForEach(controller.items) { item in
                        AnimeMangaGridItem(item.id, item.title, type)
                            .onAppear {
                                controller.loadMoreIfNeeded(currentItem: item)
                            }
                    }
                }
            }
            .navigationTitle(title)
            .alert("Unable to load", isPresented: $controller.isLoadingError) {
                Button("Ok") {}
            }
            if controller.isLoading {
                LoadingView()
            }
        }
    }
}
