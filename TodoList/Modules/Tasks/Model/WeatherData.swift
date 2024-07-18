//
//  WeatherData.swift
//  TodoList
//
//  Created by Jayant Karthic on 18/07/24.
//

import CoreLocation
import Foundation

struct WeatherData: Codable {
    let location: Location
    let current: Current
    
    struct Location: Codable {
        let name: String
        let region: String
        let country: String
    }
    
    struct Current: Codable {
        let temp_c: Double
        let condition: Condition
        
        struct Condition: Codable {
            let text: String
            let icon: String
        }
    }
    
    
}

struct WeatherRequest: Codable {
    let key: String
    let q: String
    let aqi: String
    
    init(key: String, coordinate: CLLocationCoordinate2D, aqi: String = "no") {
        self.key = key
        self.q = "\(coordinate.latitude),\(coordinate.longitude)"
        self.aqi = aqi
    }
    
    enum CodingKeys: String, CodingKey {
        case key
        case q
        case aqi
    }
}

struct WeatherResponse: Codable {
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

