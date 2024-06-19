//
//  CharactersListView.swift
//  MALC
//
//  Created by Gao Tianrun on 1/5/24.
//

import SwiftUI

struct CharactersListView: View {
    @StateObject var controller: CharactersListViewController
    private let characters: [ListCharacter]
    
    init(_ characters: [ListCharacter]) {
        self.characters = characters
        self._controller = StateObject(wrappedValue: CharactersListViewController(characters))
    }
    
    var body: some View {
        ZStack {
            List {
                ForEach(characters) { character in
                    NavigationLink {
                        CharacterDetailsView(character.id, character.character.images?.jpg.imageUrl)
                    } label: {
                        HStack {
                            ImageFrame("character\(character.id)", 75, 106)
                                .padding([.trailing], 10)
                            Text(character.character.name ?? "")
                        }
                    }
                    .buttonStyle(.plain)
                }
            }
            .navigationTitle("Characters")
            .background(Color(.systemGray6))
            if controller.isLoading {
                LoadingView()
            }
        }
    }
}
