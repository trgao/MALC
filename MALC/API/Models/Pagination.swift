//
//  Pagination.swift
//  MALC
//
//  Created by Gao Tianrun on 19/4/24.
//

import Foundation

struct Pagination: Codable {
    struct Items: Codable {
        let count: Int
        let total: Int
        let perPage: Int
    }
    let lastVisiblePage: Int
    let hasNextPage: Bool
    let items: Items
    let currentPage: Int
}
