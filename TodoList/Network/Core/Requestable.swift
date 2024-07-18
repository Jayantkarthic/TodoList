//
//  Requestable.swift
//  TodoList
//
//  Created by Jayant Karthic on 18/07/24.
//

import Foundation


protocol Requestable: EndPoint, Request {
    func asURLRequest() throws -> URLRequest
}

extension Requestable {
    func asURLRequest() throws -> URLRequest {
        guard let url = urlComponents?.url else {
            throw WebServiceError.badRequest
        }
        
        var mutableURLRequest = URLRequest(url: url)
        mutableURLRequest.httpMethod = method.rawValue
        for field in headers {
            mutableURLRequest.setValue(field.value, forHTTPHeaderField: field.key)
        }
        
        if let payload = payload {
            do {
                let jsonData = try JSONSerialization.data(withJSONObject: payload, options: .prettyPrinted)
                mutableURLRequest.httpBody = jsonData
            } catch {
                throw error
            }
        }
        
        return mutableURLRequest
    }
    
    private var urlComponents: URLComponents? {
        var components = URLComponents(string: baseURL)
        if let path = path {
            components?.path = path
        }
        if let query = query {
            components?.queryItems = query
        }
        return components
    }
}
