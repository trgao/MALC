//
//  AnimeVoice.swift
//  MALC
//
//  Created by Gao Tianrun on 21/5/24.
//

import Foundation

struct AnimeVoice: Codable, Identifiable {
    var id: String { "anime\(anime.id)character\(character.id)" }
    let anime: JikanListItem
    let character: JikanListItem
    let role: String
}
