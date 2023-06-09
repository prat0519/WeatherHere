//
//  String + Ext.swift
//  WeatherHere
//
//  Created by Prashant Pandey on 6/9/23.
//

import Foundation
fileprivate let badChars = CharacterSet.alphanumerics.inverted

extension String {
    /// Retrieve strings from localized string file
    /// - Returns: localized string
    func localized() -> String {
        return NSLocalizedString(self, comment: "")
    }
    
    /// Get Day and Time of the week from string date
    func dayofWeek() -> String {
        // Convert to date first
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        dateFormatter.timeZone = TimeZone.current
        dateFormatter.locale = Locale.current
        
        guard let date = dateFormatter.date(from: self) else { return "" }
        
        let convertDateFormatter = DateFormatter()
        convertDateFormatter.dateFormat = "MMM dd yyyy h:mm a"
        
        return convertDateFormatter.string(from: date)
    }
}
