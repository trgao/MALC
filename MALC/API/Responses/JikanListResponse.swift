//
//  JikanListResponse.swift
//  MALC
//
//  Created by Gao Tianrun on 19/4/24.
//

import Foundation

struct JikanListResponse: Codable {
    let data: [JikanListItem]
    let pagination: Pagination
}
