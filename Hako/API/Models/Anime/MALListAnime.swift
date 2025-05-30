//
//  MALListAnime.swift
//  Hako
//
//  Created by Gao Tianrun on 28/4/24.
//

import Foundation

struct MALListAnime: Codable, Identifiable {
    var id: Int { node.id }
    let node: Node
    let ranking: Ranking?
    var listStatus: AnimeListStatus?
}
