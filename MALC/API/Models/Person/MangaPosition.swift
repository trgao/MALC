//
//  MangaPosition.swift
//  MALC
//
//  Created by Gao Tianrun on 21/5/24.
//

import Foundation

struct MangaPosition: Codable, Identifiable {
    var id: Int { manga.id }
    let manga: JikanListItem
    let position: String
}
