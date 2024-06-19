//
//  AnimePosition.swift
//  MALC
//
//  Created by Gao Tianrun on 21/5/24.
//

import Foundation

struct AnimePosition: Codable, Identifiable {
    var id: Int { anime.id }
    let anime: JikanListItem
    let position: String
}
