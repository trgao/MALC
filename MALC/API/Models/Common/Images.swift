//
//  Images.swift
//  MALC
//
//  Created by Gao Tianrun on 19/4/24.
//

import Foundation

struct Images: Codable {
    struct Image: Codable {
        let imageUrl: String?
        let smallImageUrl: String?
        let bigImageUrl: String?
    }
    let jpg: Image
}
