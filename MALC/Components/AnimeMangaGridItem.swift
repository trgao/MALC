//
//  AnimeMangaGridItem.swift
//  MALC
//
//  Created by Gao Tianrun on 19/4/24.
//

import SwiftUI

struct AnimeMangaGridItem: View {
    private let id: Int
    private let title: String?
    private let type: TypeEnum
    private let subtitle: String?
    
    init(_ id: Int, _ title: String?, _ type: TypeEnum, _ subtitle: String? = nil) {
        self.id = id
        self.title = title
        self.type = type
        self.subtitle = subtitle
    }
    
    var body: some View {
        NavigationLink {
            if type == .anime {
                AnimeDetailsView(id)
            } else {
                MangaDetailsView(id)
            }
        } label: {
            VStack {
                ImageFrame("\(type)\(id)", 150, 212)
                    .overlay {
                        if let subtitle = subtitle {
                            Text(subtitle)
                                .bold()
                                .font(.system(size: 16))
                                .foregroundStyle(.white)
                                .padding(10)
                                .background {
                                    Color(hex: 0x000000, opacity: 0.6)
                                        .blur(radius: 8, opaque: false)
                                }
                                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomTrailing)
                        }
                    }
                Text(title ?? "")
                    .frame(width: 150, alignment: .leading)
                    .padding(5)
                    .font(.system(size: 16))
            }
        }
        .buttonStyle(.plain)
        .padding(5)
    }
}
