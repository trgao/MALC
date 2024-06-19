//
//  Recommendations.swift
//  MALC
//
//  Created by Gao Tianrun on 14/5/24.
//

import SwiftUI

struct Recommendations: View {
    @State private var animeRecommendations = [MALListAnime]()
    @State private var mangaRecommendations = [MALListManga]()
    private let type: TypeEnum
    
    init(_ animeRecommendations: [MALListAnime]) {
        self.animeRecommendations = animeRecommendations
        type = .anime
    }
    
    init(_ mangaRecommendations: [MALListManga]) {
        self.mangaRecommendations = mangaRecommendations
        type = .manga
    }
    
    var body: some View {
        if type == .anime {
            if !animeRecommendations.isEmpty {
                VStack {
                    NavigationLink {
                        RecommendationsListView(animeRecommendations)
                    } label: {
                        HStack {
                            Text("Recommendations")
                                .bold()
                            Image(systemName: "chevron.right")
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal, 15)
                        .font(.system(size: 17))
                    }
                    .buttonStyle(.plain)
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(alignment: .top) {
                            Rectangle()
                                .frame(width: 10)
                                .foregroundColor(.clear)
                            ForEach(animeRecommendations) { item in
                                NavigationLink {
                                    if type == .anime {
                                        AnimeDetailsView(item.id)
                                    } else {
                                        MangaDetailsView(item.id)
                                    }
                                } label: {
                                    AnimeMangaGridItem(item.id, item.node.title, type)
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
        } else {
            if !mangaRecommendations.isEmpty {
                VStack {
                    NavigationLink {
                        RecommendationsListView(mangaRecommendations)
                    } label: {
                        HStack {
                            Text("Recommendations")
                                .bold()
                            Image(systemName: "chevron.right")
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal, 15)
                        .font(.system(size: 17))
                    }
                    .buttonStyle(.plain)
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(alignment: .top) {
                            Rectangle()
                                .frame(width: 10)
                                .foregroundColor(.clear)
                            ForEach(mangaRecommendations) { item in
                                NavigationLink {
                                    if type == .anime {
                                        AnimeDetailsView(item.id)
                                    } else {
                                        MangaDetailsView(item.id)
                                    }
                                } label: {
                                    AnimeMangaGridItem(item.id, item.node.title, type)
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
        }
    }
}
