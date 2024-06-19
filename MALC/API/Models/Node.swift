//
//  Node.swift
//  MALC
//
//  Created by Gao Tianrun on 6/5/24.
//

import Foundation

struct Node: Codable {
    let id: Int
    let title: String
    let mainPicture: MainPicture?
    let startSeason: Season?
    let numEpisodes: Int?
    let numVolumes: Int?
    let numChapters: Int?
}

struct Ranking: Codable {
    let rank: Int
}
