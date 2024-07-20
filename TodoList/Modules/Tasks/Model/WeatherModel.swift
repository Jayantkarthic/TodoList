//
//  WeatherData.swift
//  TodoList
//
//  Created by Jayant Karthic on 18/07/24.
//

import CoreLocation
import Foundation

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



