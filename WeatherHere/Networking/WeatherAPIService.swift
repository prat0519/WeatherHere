//
//  WeatherAPIService.swift
//  WeatherHere
//
//  Created by Prashant Pandey on 6/8/23.
//

import Foundation
import Combine
import CoreLocation

enum NetworkError: Error {
    case badURL
    case noData
    case decodingError
}

typealias Coordinate = (latitude: CLLocationDegrees, longitude: CLLocationDegrees)

protocol WeatherAPIServiceable {
    func requestData<T>(for: T.Type, location: Coordinate, route: WeatherAPIRoute) throws -> AnyPublisher<T, HTTPError> where T : Decodable
    func searchCity(query: String) throws -> AnyPublisher<[City], HTTPError>
}

final class WeatherAPIService: WeatherAPIServiceable {
    enum URLError: LocalizedError {
        case invalidURL
        
        var errorDescription: String? {
            switch self {
            case .invalidURL:
                return "Invalid address of the requested resource"
            }
        }
    }
    //MARK: Properties
    
    private let session = URLSession.shared
    private let decoder: JSONDecoder
    private let service: URLService
    private var accessKey: String
    
    //MARK: - Initialization
    
    init(decoder: JSONDecoder, service: URLService, accessKeysHelper: AccessKeysHelper) {
        guard let key = accessKeysHelper.getKey(type: .weatherApiKey) else {
            fatalError("You must have an API key to access the data")
        }
        self.accessKey = key
        self.decoder = decoder
        self.service = service
    }
    
    func requestData<T>(for: T.Type, location: Coordinate, route: WeatherAPIRoute) throws -> AnyPublisher<T, HTTPError> where T : Decodable {
        guard let url = service.createURL(
            scheme: WeatherHTTPBase.scheme,
            host: WeatherHTTPBase.host,
            path: route.path,
            queryParameters: prepareForecastQueryParameters(coordinate: location)
        ) else {
            throw URLError.invalidURL
        }
        return createNetworkCallPublisher(withOutputType: T.self, url: url)
    }
    
    func searchCity(query: String) throws -> AnyPublisher<[City], HTTPError> {
        guard let url = service.createURL(
            scheme: WeatherHTTPBase.scheme,
            host: WeatherHTTPBase.host,
            path: WeatherAPIRoute.search.path,
            queryParameters: prepareSearchQueryParameters(query: query, limit: "25")
        ) else {
            throw URLError.invalidURL
        }
        
        return createNetworkCallPublisher(withOutputType: [City].self, url: url)
    }
}

//MARK: - Private methods

extension WeatherAPIService {
    
    func createNetworkCallPublisher<T: Decodable>(withOutputType outputType: T.Type, url: URL) -> AnyPublisher<T, HTTPError> {
        session.dataTaskPublisher(for: url)
            .assumeHTTP()
            .map { $0.data }
            .decode(type: outputType.self, decoder: decoder)
            .mapHTTPError()
            .eraseToAnyPublisher()
    }
    
    func prepareSearchQueryParameters(query: String, limit: String) -> [String: String] {
        return [
            "q": "\(query)",
            "limit": "\(limit)",
            "appid": "d24157b1fdda25809558f37e50ab92d9",
        ]
    }
    func prepareForecastQueryParameters(coordinate: Coordinate) -> [String: String] {
        return [
            "lat": "\(coordinate.latitude)",
            "lon": "\(coordinate.longitude)",
            "appid": "d24157b1fdda25809558f37e50ab92d9",
        ]
    }
}
    
