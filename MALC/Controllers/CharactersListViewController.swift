//
//  CharactersListViewController.swift
//  MALC
//
//  Created by Gao Tianrun on 2/5/24.
//

import Foundation

@MainActor
class CharactersListViewController: ObservableObject {
    @Published var isLoading = false
    private let characters: [ListCharacter]
    let networker = NetworkManager.shared
    
    init(_ characters: [ListCharacter]) {
        self.characters = characters
    }
    
    func loadImages() async -> Void {
        isLoading = true
        await withTaskGroup(of: Void.self) { taskGroup in
            for character in self.characters {
                taskGroup.addTask {
                    await self.networker.downloadImage(id: "character\(character.id)", urlString: character.character.images?.jpg.imageUrl)
                }
            }
        }
        
        isLoading = false
    }
}
