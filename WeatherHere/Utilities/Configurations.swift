//
//  Configurations.swift
//  WeatherHere
//
//  Created by Prashant Pandey on 6/8/23.
//

import UIKit

// MARK: - Alert Types
enum AlertType {
    case locationRequestFailed
    case weatherDataNotAvailable
}

// MARK: - Set Default Location
struct DefaultLocation {
    /// Default location set to NYC
    static let latitude: Double = 40.730610
    static let longitude: Double = -73.935242
}
