//
//  Character.swift
//  MALC
//
//  Created by Gao Tianrun on 2/5/24.
//

import Foundation

struct Character: Codable, Identifiable {
    var id: Int { malId }
    let malId: Int
    let url: String?
    let images: Images
    let name: String?
    let nameKanji: String?
    let nicknames: [String]
    let favorites: Int?
    let about: String?
    let anime: [Animeography]
    let manga: [Mangaography]
    let voices: [Voice]
}
