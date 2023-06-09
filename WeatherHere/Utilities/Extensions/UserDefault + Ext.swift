//
//  UserDefault + Ext.swift
//  WeatherHere
//
//  Created by Prashant Pandey on 6/8/23.
//

import Foundation

extension UserDefaults {
    
    func saveLastCity(_ city: City) {
        do {
            let data = try JSONEncoder().encode(city)
            set(data, forKey: UserDefaultsKeys.city)
        } catch {
            print(error.localizedDescription)
        }
    }
    
    func fetchLastCity() -> City? {
        guard let data = self.data(forKey: UserDefaultsKeys.city) else {
            return nil
        }
        return try? JSONDecoder().decode(City.self, from: data)
    }
    
    func saveBackgroundModeEnteringTime(_ date: Date) {
        setValue(date, forKey: UserDefaultsKeys.timeInBackground)
    }
    
    func getBackgroundModeEnteringTime() -> Date? {
        object(forKey: UserDefaultsKeys.timeInBackground) as? Date
    }
}

enum UserDefaultsKeys {
    static let city = "city"
    static let timeInBackground = "timeInBackground"
}
