//
//  WeatherForecastViewModel.swift
//  WeatherHere
//
//  Created by Prashant Pandey on 6/8/23.
//

import Combine

struct WeatherForecastViewModel {

    // MARK: - Properties
    var apiClient: WeatherAPIServiceable?

    // Current Weather endpoint
    let currentWeatherUrl = Services.currentWeatherData
    let weeklyWeatherUrl = Services.weeklyWeatherData

    // Observe UI changes
    let showCurrentWeatherLoader = PassthroughSubject<Bool, Never>()
    let showWeeklyWeatherLoader = PassthroughSubject<Bool, Never>()
    let showWeatherDataError = PassthroughSubject<String, Never>()

    // Weather data observables
    let dailyWeatherData = PassthroughSubject<WeatherResponse, Error>()
    let weeklyWeatherData = PassthroughSubject<WeeklyWeatherResponse, Error>()

    // FIXIT: - Should be stored securely in the KeyChain
    let apiKey: String = "d24157b1fdda25809558f37e50ab92d9"


    public func getCurrentWeatherData(at coordinates: Coordinates) {
        showCurrentWeatherLoader.send(true)

        let url = String(format: currentWeatherUrl, coordinates.description, apiKey)

        apiClient?.request(for: WeatherResponse.self, url: url, completionHandler: { result in
            showCurrentWeatherLoader.send(false)
            switch result {
            case .success(let weatherData):
                guard let decodedData = weatherData else {
                    showWeatherDataError.send(NetworkError.decodingError.localizedDescription)
                    return
                }
                self.dailyWeatherData.send(decodedData)
            case .failure(let error):
                showWeatherDataError.send(error.localizedDescription)
            }
        })
    }

    public func getWeeklyWeatherData(at coordinates: Coordinates) {
        showWeeklyWeatherLoader.send(true)

        let url = String(format: weeklyWeatherUrl, coordinates.description, apiKey)

        apiClient?.request(for: WeeklyWeatherResponse.self, url: url, completionHandler: { result in
            showWeeklyWeatherLoader.send(false)
            switch result {
            case .success(let weatherData):
                guard let decodedData = weatherData else {
                    showWeatherDataError.send(NetworkError.decodingError.localizedDescription)
                    return
                }
                self.weeklyWeatherData.send(decodedData)
            case .failure(let error):
                showWeatherDataError.send(error.localizedDescription)
            }
        })
    }
}
