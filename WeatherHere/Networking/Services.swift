//
//  Services.swift
//  WeatherHere
//
//  Created by Prashant Pandey on 6/8/23.
//

import Foundation

import Foundation

// MARK: - Fetch Weather Data services for current and weekly
struct Services {
    static let currentWeatherData = "https://api.openweathermap.org/data/2.5/weather?%@&appid=%@"
    static let weeklyWeatherData = "https://api.openweathermap.org/data/2.5/forecast?%@&appid=%@"
}
