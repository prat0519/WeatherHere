//
//  WeatherAPIServiceMock.swift
//  WeatherHereTests
//
//  Created by Prashant Pandey on 6/8/23.
//

import XCTest
import Combine
@testable import WeatherHere

class WeatherAPIServiceMock: WeatherAPIServiceable {
    static let sampleCityResponse = City(id: 10, name: "Newark", region: "", country: "US", lat: 40.735657, lon: -74.1723667, url: nil)
    
    func searchCity(query: String) throws -> AnyPublisher<[WeatherHere.City], WeatherHere.HTTPError> {
        Just([WeatherAPIServiceMock.sampleCityResponse])
            .setFailureType(to: HTTPError.self)
            .eraseToAnyPublisher()
    }
    
    
    static let sampleResponse = WeatherResponse(coord: Coordinates(lat: 40.730610, lon: -73.935242),
                                            main: CurrentWeather(temp: 123.5, temp_min: 123.1, temp_max: 123.8, humidity: 19),
                                            weather: [Weather(description: "Mostly sunny", icon: "1sg", id: 3, main: MainEnum(rawValue: "Clear")!)],
                                            sys: CountryDetails(country: "US"), name: "Long Island City")
    
    func requestData<T>(for: T.Type, location: WeatherHere.Coordinate, route: WeatherHere.WeatherAPIRoute) throws -> AnyPublisher<T, WeatherHere.HTTPError> where T : Decodable {
        Just(WeatherAPIServiceMock.sampleResponse as! T)
            .setFailureType(to: HTTPError.self)
            .eraseToAnyPublisher()
    }
}

class URLServiceMock: URLServiceable {
    func createURL(scheme: String, host: String, path: String, queryParameters: [String : String]?) -> URL? {
        var components = URLComponents()
        components.scheme = scheme
        components.host = host
        components.path = "/" + path
        components.queryItems = queryParameters?.map { URLQueryItem(name: $0, value: $1) }
        guard let url = components.url else {
            return nil
        }
        return url
    }
}
