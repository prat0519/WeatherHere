//
//  WeatherResponseModel.swift
//  WeatherHere
//
//  Created by Prashant Pandey on 6/8/23.
//

import Foundation

// MARK: - Weather Data Models
struct WeatherResponse : Decodable, Equatable {
    let coord: Coordinates
    let main: CurrentWeather
    let weather: [Weather]
    let sys: CountryDetails
    let name: String

    /// This is to help in testing the response model
    static func == (lhs: WeatherResponse, rhs: WeatherResponse) -> Bool {
        true
    }
}

struct CurrentWeather: Decodable {
    let temp: Double
    let temp_min: Double
    let temp_max: Double
    let humidity: Int
}

struct CountryDetails: Decodable {
    let country: String
}

struct Wind: Decodable {
    let speed: Double
}

struct Weather: Decodable {
    let description: String
    let icon: String
    let id: Int
    let main: MainEnum
}

struct DailyWeatherResponse: Decodable {
    let main: CurrentWeather
    let weather : [Weather]
    let wind: Wind
    let visibility: Int
    let dt_txt: String
}

struct WeeklyWeatherResponse: Decodable {
    let list: [DailyWeatherResponse]
}

enum MainEnum: String, Decodable {
    case clear = "Clear"
    case clouds = "Clouds"
    case rain = "Rain"
    case haze = "Haze"
}

struct City: Codable, Equatable {
    let id: Int?
    let name: String?
    let region: String?
    let country: String?
    let lat: Double?
    let lon: Double?
    let url: String?
}
