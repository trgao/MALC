//
//  MALAuthenticationResponse.swift
//  MALC
//
//  Created by Gao Tianrun on 14/5/24.
//

import Foundation

struct MALAuthenticationResponse: Codable {
    let tokenType: String
    let expiresIn: Int
    let accessToken: String
    let refreshToken: String
}
