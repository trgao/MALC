//
//  MangaListStatus.swift
//  MALC
//
//  Created by Gao Tianrun on 13/5/24.
//

import Foundation

struct MangaListStatus: Codable {
    var status: StatusEnum?
    var score: Int
    var numVolumesRead: Int
    var numChaptersRead: Int
    var startDate: Date?
    var finishDate: Date?
}
