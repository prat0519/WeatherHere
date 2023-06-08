//
//  CoordinatesModel.swift
//  WeatherHere
//
//  Created by Prashant Pandey on 6/8/23.
//

import Foundation

// MARK: - Coordinates to be passed to fetch weather data
struct Coordinates: Decodable {
    let lat: Double
    let lon: Double
}

// MARK: - Simplify coordinate value parameters
extension Coordinates: CustomStringConvertible {
    var description: String {
        return "lat=\(lat)&lon=\(lon)"
    }
}
