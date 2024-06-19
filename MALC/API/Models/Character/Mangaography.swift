//
//  Mangaography.swift
//  MALC
//
//  Created by Gao Tianrun on 2/5/24.
//

import Foundation

struct Mangaography: Codable, Identifiable {
    var id: Int { manga.id }
    let manga: JikanListItem
    let role: String
}
