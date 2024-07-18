//
//  Endpoint.swift
//  TodoList
//
//  Created by Jayant Karthic on 18/07/24.
//

import Foundation
protocol EndPoint {
    var baseURL: String { get }
    var path: String? { get }
    var query: URLQueryItem? { get }
}

extension EndPoint {
    var baseURL: String {
        "http://api.weatherapi.com"
    }

    var path: String? {
        nil
    }

    var query: URLQueryItem? {
        nil
    }
}
