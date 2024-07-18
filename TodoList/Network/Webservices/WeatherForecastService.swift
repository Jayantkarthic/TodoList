//
//  WeatherForecastService.swift
//  TodoList
//
//  Created by Jayant Karthic on 18/07/24.
//

import Foundation
import Combine

final class WeatherForecastService {

    private var factory: WeatherForecastWebRequestFactory
    
    init(factory: WeatherForecastWebRequestFactory = .init()) {
        self.factory = factory
    }
}

extension WeatherForecastService {

    func getWeatherForecastData(_ WeatherForecast: WeatherRequest) -> AnyPublisher<NetworkResponse, Error> {
        let getWeatherForecastRequest = factory.getWeatherForecastRequest(Payload: WeatherForecast)
        return WebClient().send(request: getWeatherForecastRequest)
    }
  
}
