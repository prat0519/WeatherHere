//
//  URLComponentService.swift
//  WeatherHere
//
//  Created by Prashant Pandey on 6/8/23.
//

import Foundation

enum WeatherHTTPBase {
    static let scheme = "https"
    static let host = "api.openweathermap.org"
}

enum WeatherAPIRoute {
    case weather
    case forecast
    case search
    
    var path: String {
        switch self {
        case .weather:
            return "/data/2.5/weather"
        case .forecast:
            return "/data/2.5/forecast"
        case .search:
            return "/geo/1.0/direct"
        }
    }
}
