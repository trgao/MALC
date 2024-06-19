//
//  Video.swift
//  MALC
//
//  Created by Gao Tianrun on 19/4/24.
//

import Foundation

struct Video: Codable, Identifiable {
    let id: Int
    let title: String?
    let url: String?
}
