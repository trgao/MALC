//
//  Characters.swift
//  MALC
//
//  Created by Gao Tianrun on 1/5/24.
//

import SwiftUI

struct Characters: View {
    private let characters: [ListCharacter]
    let networker = NetworkManager.shared
    
    init(_ characters: [ListCharacter]) {
        self.characters = characters
    }
    
    var body: some View {
        if !characters.isEmpty {
            VStack {
                NavigationLink {
                    CharactersListView(characters)
                } label: {
                    HStack {
                        Text("Characters")
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
                        ForEach(characters.prefix(10)) { character in
                            NavigationLink {
                                CharacterDetailsView(character.id, character.character.images?.jpg.imageUrl)
                            } label: {
                                VStack {
                                    ImageFrame("character\(character.id)", 100, 142)
                                    Text(character.character.name ?? "")
                                        .font(.system(size: 14))
                                        .fixedSize(horizontal: false, vertical: true)
                                }
                                .frame(width: 120)
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
