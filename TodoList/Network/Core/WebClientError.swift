//
//  WebClientError.swift
//  TodoList
//
//  Created by Jayant Karthic on 18/07/24.
//

import Foundation

enum WebServiceError: Error, LocalizedError {
    case badRequest
    case unAuthorised
    case invalidResponse
    case unknown
    case notFound
    case serverError
    
    var errorDescription: String? {
        switch self {
        case .badRequest:
            return "Invalid URL"
        case .unAuthorised:
            return "Unauthorised User"
        case .invalidResponse:
            return "Invalid Server Response"
        case .unknown:
            return "Unknown error"
        case .notFound:
            return "File Not Found"
        case .serverError:
            return "Server Error"
        }
    }
}

extension WebServiceError {
    static func errorFor(statusCode: Int) -> WebServiceError {
        switch statusCode {
        case 400:
            return WebServiceError.badRequest
        case 401:
            return WebServiceError.unAuthorised
        case 404:
            return WebServiceError.notFound
        case 400...499:
            return WebServiceError.serverError
        default:
            return WebServiceError.unknown
        }
    }
}

enum ParseError: Error, LocalizedError {
    case parseError(reason: String)
    
    var errorDescription: String? {
        switch self {
        case .parseError(let reason):
            return reason
        }
    }
}
