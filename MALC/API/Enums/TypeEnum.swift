//
//  TypeEnum.swift
//  MALC
//
//  Created by Gao Tianrun on 13/5/24.
//

import Foundation

enum TypeEnum: Codable {
    case anime, manga, none
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let status = try? container.decode(String.self)
        switch status {
            case "anime": self = .anime
            case "manga": self = .manga
            default:
                self = .none
        }
    }
}
