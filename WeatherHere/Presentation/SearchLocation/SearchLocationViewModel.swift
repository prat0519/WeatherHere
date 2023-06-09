//
//  SearchLocationViewModel.swift
//  WeatherHere
//
//  Created by Prashant Pandey on 6/8/23.
//

import Foundation
import Combine

final class SearchLocationViewModel: SearchLocationsResultsViewModelable {
    
    //MARK: Properties
    var numberOfResults: Int {
        cities.count
    }
    
    var updateResultsPublisher: AnyPublisher<Void, Never> {
        updateResultsSubject.eraseToAnyPublisher()
    }
    private var updateResultsSubject = PassthroughSubject<Void, Never>()

    var locationSelectionSubject: PassthroughSubject<IndexPath, Never> = PassthroughSubject()
    var clearResultsSubject: PassthroughSubject<Void, Never> = PassthroughSubject()
    
    private var cancellables = Set<AnyCancellable>()
    private var cities = [City]()
    
    //MARK: - Initialization
    init(coordinator: WeatherCoordinator? = nil) {
        self.setBindings()
    }
    
    //MARK: - Methods
    
    func titleForLocation(at indexPath: IndexPath) -> String {
        let city = cities[indexPath.row]
        
        guard
            let cityName = city.name,
            let countryName = city.country
        else { return "" }
        
        return "\(cityName), \(countryName)"
    }
    
    func updateResults(with cities: [City]) {
        self.cities = cities
        updateResultsSubject.send()
    }
}

//MARK: - Private methods

private extension SearchLocationViewModel {
    func setBindings() {
        clearResultsSubject
            .sink { [weak self] in
                self?.updateResults(with: [])
            }
            .store(in: &cancellables)
        
        locationSelectionSubject
            .compactMap { [weak self] indexPath in
                self?.cities[indexPath.row]
            }
            .sink { city in
                NotificationCenter.default.post(name: .updateCityInForecastView, object: city)
            }
            .store(in: &cancellables)
    }
}

