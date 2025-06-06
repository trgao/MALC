//
//  User.swift
//  Hako
//
//  Created by Gao Tianrun on 15/5/24.
//

import Foundation

struct User: Codable {
    let name: String?
    let joinedAt: String?
    let picture: String?
    
    init(name: String?, joinedAt: String?, picture: String?) {
        self.name = name
        self.joinedAt = joinedAt
        self.picture = picture
    }
}
