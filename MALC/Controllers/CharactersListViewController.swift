//
//  CharactersListViewController.swift
//  MALC
//
//  Created by Gao Tianrun on 2/5/24.
//

import Foundation

class CharactersListViewController: ObservableObject {
    @Published var isLoading = true
    private let characters: [ListCharacter]
    let networker = NetworkManager.shared
    
    init(_ characters: [ListCharacter]) {
        self.characters = characters
        DispatchQueue.global().async {
           let group = DispatchGroup()
           for character in self.characters {
               group.enter()
               self.networker.downloadImage(id: "character\(character.id)", urlString: character.character.images?.jpg.imageUrl) { data, error in
                   group.leave()
               }
           }
           group.notify(queue: .main, execute: {
               DispatchQueue.main.async {
                   self.isLoading = false
               }
           })
       }
    }
}
