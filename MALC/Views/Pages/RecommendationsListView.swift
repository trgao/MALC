//
//  RecommendationsListView.swift
//  MALC
//
//  Created by Gao Tianrun on 14/5/24.
//

import SwiftUI

struct RecommendationsListView: View {
    private let animeRecommendations: [MALListAnime]
    private let mangaRecommendations: [MALListManga]
    
    init(_ animeRecommendations: [MALListAnime]) {
        self.animeRecommendations = animeRecommendations
        self.mangaRecommendations = []
    }
    
    init(_ mangaRecommendations: [MALListManga]) {
        self.animeRecommendations = []
        self.mangaRecommendations = mangaRecommendations
    }
    
    var body: some View {
        ZStack {
            List {
                ForEach(animeRecommendations) { item in
                    NavigationLink {
                        AnimeDetailsView(item.id)
                    } label: {
                        HStack {
                            ImageFrame("anime\(item.id)", 75, 106)
                                .padding([.trailing], 10)
                            VStack(alignment: .leading) {
                                Text(item.node.title)
                            }
                        }
                    }
                    .buttonStyle(.plain)
                }
                ForEach(mangaRecommendations) { item in
                    NavigationLink {
                        MangaDetailsView(item.id)
                    } label: {
                        HStack {
                            ImageFrame("manga\(item.id)", 75, 106)
                                .padding([.trailing], 10)
                            VStack(alignment: .leading) {
                                Text(item.node.title)
                            }
                        }
                    }
                    .buttonStyle(.plain)
                }
            }
            .navigationTitle("Recommendations")
            .background(Color(.systemGray6))
        }
    }
}
