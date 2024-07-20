//
//  WeatherForecastWebRequestFactory.swift
//  TodoList
//
//  Created by Jayant Karthic on 18/07/24.
//


import Foundation
final class WeatherForecastWebRequestFactory {
    

    func getWeatherForecastRequest(Payload: WeatherRequest) -> WeatherForecastRequest {
        let WeatherForecastRequest = WeatherForecastRequest()

     
        WeatherForecastRequest.query = [URLQueryItem(name: "key", value: "6f50f2192be14e3eb76171618241001"),
                                        URLQueryItem(name: "q", value: "\(Payload.q)"),
                                        URLQueryItem(name: "aqi", value: "no")]
        
        return WeatherForecastRequest
    }
    
}
