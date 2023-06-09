//
//  HTTPError.swift
//  WeatherHere
//
//  Created by Prashant Pandey on 6/8/23.
//

import Foundation

enum HTTPError: LocalizedError {
    case nonHTTPRequest
    case requestFailed(statusCode: Int)
    case serverError(statusCode: Int)
    case networkError(Error)
    case decodingError(DecodingError)
    
    var isRetriable: Bool {
        switch self {
        case .decodingError:
            return false
        case .requestFailed(let statusCode):
            return [408, 429].contains(statusCode)
        case .serverError, .networkError, .nonHTTPRequest:
            return true
        }
    }
    
    var errorDescription: String? {
        switch self {
        case .nonHTTPRequest:
            return "Non HTTP URL Request"
        case .requestFailed(let statusCode):
            return "Request failed with status code: \(statusCode)"
        case .serverError(let statusCode):
            return "Server error, status code: \(statusCode)"
        case .networkError(let error):
            return "\(error.localizedDescription)"
        case .decodingError(let decodingError):
            return "\(decodingError.localizedDescription)"
        }
    }
}
