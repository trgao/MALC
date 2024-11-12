//
//  AnimeMangaToggle.swift
//  MALC
//
//  Created by Gao Tianrun on 6/5/24.
//

import SwiftUI

struct AnimeMangaToggle: View {
    @Environment(\.isEnabled) private var isEnabled
    @Binding var type: TypeEnum
    @State private var offset: CGFloat = -17
    private let refresh: () async -> Void
    
    init(_ type: Binding<TypeEnum>, _ refresh: @escaping () async -> Void) {
        self._type = type
        self.refresh = refresh
    }
    
    var body: some View {
        ZStack {
            Capsule()
                .frame(width: 70, height: 35)
                .foregroundColor(Color(.systemGray5))
            ZStack{
                Circle()
                    .frame(width: 33, height: 33)
                    .foregroundColor(.white)
                
            }
            .shadow(color: .black.opacity(0.14), radius: 4, x: 0, y: 2)
            .offset(x: offset)
            .padding(24)
            HStack {
                Image(systemName: "tv.fill")
                    .resizable()
                    .frame(width: 18, height: 15)
                    .foregroundStyle(type == .anime && isEnabled ? Color(.systemBlue) : Color(.systemGray))
                    .padding(3)
                Image(systemName: "book.fill")
                    .resizable()
                    .frame(width: 18, height: 15)
                    .foregroundStyle(type == .manga && isEnabled ? Color(.systemBlue) : Color(.systemGray))
                    .padding(3)
            }
        }
        .onTapGesture {
            DispatchQueue.main.async {
                if type == .anime {
                    type = .manga
                } else if type == .manga {
                    type = .anime
                }
                withAnimation {
                    if type == .anime {
                        offset -= 34
                    } else if type == .manga {
                        offset += 34
                    }
                }
            }
            Task {
                await refresh()
            }
        }
    }
}
