//
//  WeatherForecastRequest.swift
//  TodoList
//
//  Created by Jayant Karthic on 18/07/24.
//


import Foundation
import Combine

final class WeatherForecastRequest : Requestable {
    typealias Response = NetworkResponse
    var path: String? = "/v1/current.json"
    var headers: HTTPHeaders = ["Content-Type" : "application/json", "Authorization" : ""]
    var method = HTTPMethod.get
    var payload: HTTPBody? = nil
    var query  : [URLQueryItem]?
}

struct NetworkResponse: Codable {
    let location: Location
    let current: Current
}

struct Location: Codable {
    let name: String
}

struct Current: Codable {
    let temp_c: Double
    let condition: Condition
}

struct Condition: Codable {
    let text: String
}

