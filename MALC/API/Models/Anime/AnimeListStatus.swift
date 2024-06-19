//
//  AnimeListStatus.swift
//  MALC
//
//  Created by Gao Tianrun on 11/5/24.
//

import Foundation

struct AnimeListStatus: Codable {
    var status: StatusEnum?
    var score: Int
    var numEpisodesWatched: Int
    var startDate: Date?
    var finishDate: Date?
}
