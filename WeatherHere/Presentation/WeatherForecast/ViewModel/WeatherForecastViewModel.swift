//
//  WeatherForecastViewModel.swift
//  WeatherHere
//
//  Created by Prashant Pandey on 6/8/23.
//

import Foundation
import Combine

class WeatherForecastViewModel {

    // MARK: - Properties
    @Published private var location = UserDefaults.standard.fetchLastCity()
    @Published private var searchResults = [City]()
    private var cancellables = Set<AnyCancellable>()

    // Observe UI changes
    let showCurrentWeatherLoader = PassthroughSubject<Bool, Never>()
    let showWeeklyWeatherLoader = PassthroughSubject<Bool, Never>()
    let showWeatherDataError = PassthroughSubject<String, Never>()
    
    private let addingNewLocationSubject = PassthroughSubject<City, Never>()
    let dailyWeatherData = PassthroughSubject<WeatherResponse, Error>()
    let weeklyWeatherData = PassthroughSubject<WeeklyWeatherResponse, Error>()

    // FIXIT: - Should be stored securely in the KeyChain
    let apiKey: String = "d24157b1fdda25809558f37e50ab92d9"

    var searchResultsUpdatingPublisher: AnyPublisher<[City], Never> {
        $searchResults.eraseToAnyPublisher()
    }
    
    var addingNewLocationPublisher: AnyPublisher<City?, Never> {
        $location.eraseToAnyPublisher()
    }
    
    private let weatherService: WeatherAPIServiceable
    
    //MARK: - Initialization
    init(weatherService: WeatherAPIServiceable) {
        self.weatherService = weatherService
        self.setBindings()
    }
    
    func viewModelForLocationsSearchResultsController() -> SearchLocationsResultsViewModelable {
        return SearchLocationViewModel()
    }
    
    public func getCurrentWeatherData(at coordinates: Coordinates) throws {
        showCurrentWeatherLoader.send(true)
        do {
            let weatherPublisher = try weatherService.requestData(for: WeatherResponse.self, location: Coordinate(coordinates.lat, coordinates.lon), route: .weather)
            weatherPublisher
                .sink { [weak self] completion in
                    self?.showCurrentWeatherLoader.send(false)
                    if case .failure(let error) = completion {
                        print(error.localizedDescription)
                        self?.showWeatherDataError.send(error.localizedDescription)
                    }
                } receiveValue: { [weak self] weatherData in
                    self?.dailyWeatherData.send(weatherData)
                }
                .store(in: &cancellables)
        } catch {
            self.showWeatherDataError.send(error.localizedDescription)
        }
    }

    public func getWeeklyWeatherData(at coordinates: Coordinates) throws {
        showWeeklyWeatherLoader.send(true)
        do {
            let weatherPublisher = try weatherService.requestData(for: WeeklyWeatherResponse.self, location: Coordinate(coordinates.lat, coordinates.lon), route: .forecast)
            weatherPublisher
                .sink { [weak self] completion in
                    self?.showWeeklyWeatherLoader.send(false)
                    if case .failure(let error) = completion {
                        print(error.localizedDescription)
                        self?.showWeatherDataError.send(error.localizedDescription)
                    }
                } receiveValue: { [weak self] weeklyWeatherData in
                    self?.weeklyWeatherData.send(weeklyWeatherData)
                }
                .store(in: &cancellables)
        } catch {
            self.showWeatherDataError.send(error.localizedDescription)
        }
    }
    
    public func searchCity(query: String) {
        do {
            let citiesPublisher = try weatherService.searchCity(query: query)
            citiesPublisher
                .sink { completion in
                    if case .failure(let error) = completion {
                        print(error.localizedDescription)
                    }
                } receiveValue: { [weak self] cities in
                    self?.searchResults = cities
                }
                .store(in: &cancellables)
        } catch {
            self.showWeatherDataError.send(error.localizedDescription)
        }
    }
}

private extension WeatherForecastViewModel {
    func setBindings() {
        $location
            .sink { city in
                guard let city = city else { return }
                UserDefaults.standard.saveLastCity(city)
            }
            .store(in: &cancellables)
        
        NotificationCenter.default.publisher(for: .updateCityInForecastView)
            .sink { [weak self] notification in
                guard
                    let self,
                    let city = notification.object as? City,
                    !(self.location == city)
                else { return }
                self.location = city
                self.addingNewLocationSubject.send(city)
            }
            .store(in: &cancellables)
    }
}
