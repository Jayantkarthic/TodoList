//
//  Request.swift
//  TodoList
//
//  Created by Jayant Karthic on 18/07/24.
//

import Foundation

typealias HTTPHeaders = [String: String]
typealias HTTPBody = [String: Any]
typealias HTTPURLQueryItem = [URLQueryItem]

enum HTTPMethod: String {
    case get        = "GET"
    case post       = "POST"
    case put        = "PUT"
    case patch      = "PATCH"
    case delete     = "DELETE"
    case copy       = "COPY"
    case head       = "HEAD"
    case options    = "OPTIONS"
    case link       = "LINK"
    case unlink     = "UNLINK"
    case purge      = "PURGE"
    case lock       = "LOCK"
    case unlock     = "UNLOCK"
    case propfind   = "PROFIND"
    case view       = "VIEW"
}

protocol Request<Response> {
    associatedtype Response: Decodable
    
    var method: HTTPMethod { get }
    var headers: HTTPHeaders { get set }
    var payload: HTTPBody? { get set }
    var query : HTTPURLQueryItem? { get set}
}

extension Request {
    var method: HTTPMethod {
        .get
    }
    
    var headers: HTTPHeaders {
        ["Content-Type" : "application/json"]
    }
    
    var payload: HTTPBody? {
        nil
    }
    var urlQueryItem : HTTPURLQueryItem?{
        nil
    }
}
