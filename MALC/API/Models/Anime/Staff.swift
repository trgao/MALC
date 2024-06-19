//
//  Staff.swift
//  MALC
//
//  Created by Gao Tianrun on 19/5/24.
//

import Foundation

struct Staff: Codable, Identifiable {
    var id: Int { person.id }
    let person: JikanListItem
    let positions: [String]
}
