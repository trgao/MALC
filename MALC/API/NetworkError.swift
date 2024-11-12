//
//  NetworkError.swift
//  MALC
//
//  Created by Gao Tianrun on 11/11/24.
//

enum NetworkError: Error {
    case badResponse
    case notFound
    case badStatusCode(_ statusCode: Int)
    case badData
    case badLocalUrl
//    case noImage
    case invalidRefreshToken
    case jsonParseFailure
    case unknownError(_ error: Error)
    
    var description: String {
        switch self {
            case .badResponse: return "Bad http response"
            case .notFound: return "Request failed 404"
            case let .badStatusCode(statusCode): return "Request failed \(statusCode)"
            case .badData: return "Data is not of correct type"
            case .badLocalUrl: return "Bad local url of image"
    //        case .noImage
            
            case .invalidRefreshToken: return "Refresh token is no longer valid"
            case .jsonParseFailure: return "Error parsing json"
            case let .unknownError(error): return "Unknown error occurred: \(error.localizedDescription)"
        }
    }
}
