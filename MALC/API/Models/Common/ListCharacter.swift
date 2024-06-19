//
//  ListCharacter.swift
//  MALC
//
//  Created by Gao Tianrun on 13/5/24.
//

import Foundation

struct ListCharacter: Codable, Identifiable {
    var id: Int { character.id }
    let character: JikanListItem
    let role: String
}
