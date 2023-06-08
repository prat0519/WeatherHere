//
//  WeatherAPIServiceMock.swift
//  WeatherHereTests
//
//  Created by Prashant Pandey on 6/8/23.
//

import XCTest
@testable import WeatherHere

class WeatherAPIServiceMock: WeatherAPIServiceable {
    func request<T>(for: T.Type, url: String, completionHandler completion: @escaping (Result<T?, WeatherHere.NetworkError>) -> Void) where T : Decodable {
        guard !url.isEmpty else { return completion(.failure(.badURL)) }
        let sampleResponse = WeatherResponse(coord: Coordinates(lat: 40.730610, lon: -73.935242),
                                             main: CurrentWeather(temp: 123.5, temp_min: 123.1, temp_max: 123.8, humidity: 19),
                                             weather: [Weather(description: "Mostly sunny", icon: "1sg", id: 3, main: MainEnum(rawValue: "Clear")!)],
                                             sys: CountryDetails(country: "US"), name: "Long Island City")

        completion(.success(sampleResponse as? T))
    }
}
