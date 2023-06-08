//
//  WeatherAPIService.swift
//  WeatherHere
//
//  Created by Prashant Pandey on 6/8/23.
//

import Foundation

enum NetworkError: Error {
    case badURL
    case noData
    case decodingError
}

protocol WeatherAPIServiceable {
    func request<T: Decodable>(for: T.Type,
                                      url: String,
                                      completionHandler completion: @escaping (Result<T?, NetworkError>) -> Void)
}

class WeatherAPIService: WeatherAPIServiceable {

    func request<T>(for: T.Type = T.self, url: String, completionHandler completion: @escaping (Result<T?, NetworkError>) -> Void) where T : Decodable {

        guard let url = URL(string: url) else { return completion(.failure(.badURL)) }

        URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data, error == nil else {
                return completion(.failure(.noData))
            }

            let weatherResponse = try? JSONDecoder().decode(T.self, from: data)

            if let weatherResponse = weatherResponse {
                completion(.success(weatherResponse))
            } else {
                completion(.failure(.decodingError))
            }

        }.resume()

    }
}
