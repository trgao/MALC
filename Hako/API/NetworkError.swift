//
//  NetworkError.swift
//  Hako
//
//  Created by Gao Tianrun on 11/11/24.
//

enum NetworkError: Error {
    case badResponse
    case notFound
    case badStatusCode(_ statusCode: Int)
    case badData
    case badLocalUrl
    case invalidRefreshToken
    case outOfRetries
    case jsonParseFailure
    case unknownError(_ error: Error)
    
    var description: String {
        switch self {
            case .badResponse: return "Bad http response"
            case .notFound: return "Request failed 404"
            case let .badStatusCode(statusCode): return "Request failed \(statusCode)"
            case .badData: return "Data is not of correct type"
            case .badLocalUrl: return "Bad local url of image"
            case .invalidRefreshToken: return "Refresh token is no longer valid"
            case .outOfRetries: return "Retried same api call too many times"
            case .jsonParseFailure: return "Error parsing json"
            case let .unknownError(error): return "Unknown error occurred: \(error.localizedDescription)"
        }
    }
}
