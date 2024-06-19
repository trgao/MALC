//
//  RelatedItemsListView.swift
//  MALC
//
//  Created by Gao Tianrun on 11/5/24.
//

import SwiftUI

struct RelatedItemsListView: View {
    private let relations: [Related]
    
    init(_ relations: [Related]) {
        self.relations = relations
    }
    
    var body: some View {
        ZStack {
            List {
                ForEach(relations, id: \.relation) { category in
                    ForEach(category.entry) { item in
                        NavigationLink {
                            if item.type == .anime {
                                AnimeDetailsView(item.id)
                            } else if item.type == .manga {
                                MangaDetailsView(item.id)
                            }
                        } label: {
                            HStack {
                                if item.type == .anime {
                                    ImageFrame("anime\(item.id)", 75, 106)
                                        .padding([.trailing], 10)
                                } else if item.type == .manga {
                                    ImageFrame("manga\(item.id)", 75, 106)
                                        .padding([.trailing], 10)
                                }
                                VStack(alignment: .leading) {
                                    Text(item.name ?? "")
                                    Text(category.relation ?? "")
                                        .foregroundStyle(Color(.systemGray))
                                        .font(.system(size: 13))
                                }
                            }
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
            .navigationTitle("Related")
            .background(Color(.systemGray6))
        }
    }
}
