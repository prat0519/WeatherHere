//
//  NotificationName + Ext.swift
//  WeatherHere
//
//  Created by Prashant Pandey on 6/8/23.
//

import Foundation

extension Notification.Name {
    static var updateCityInForecastView: Notification.Name {
        return .init("updateCityInForecastView")
    }
}
