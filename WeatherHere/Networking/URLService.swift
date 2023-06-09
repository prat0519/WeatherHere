//
//  URLService.swift
//  WeatherHere
//
//  Created by Prashant Pandey on 6/8/23.
//

import Foundation

protocol URLServiceable {
    func createURL(scheme: String, host: String, path: String, queryParameters: [String: String]?) -> URL?
}

struct URLService: URLServiceable {
    func createURL(scheme: String, host: String, path: String, queryParameters: [String : String]?) -> URL? {
        var urlComponents = URLComponents()
        urlComponents.scheme = scheme
        urlComponents.host = host
        urlComponents.path = path
        urlComponents.queryItems = queryParameters?.map { URLQueryItem(name: $0, value: $1) }
        return urlComponents.url
    }
}
