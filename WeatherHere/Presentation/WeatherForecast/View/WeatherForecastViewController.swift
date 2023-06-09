//
//  WeatherForecastViewController.swift
//  WeatherHere
//
//  Created by Prashant Pandey on 6/8/23.
//

import UIKit
import Combine
import CoreLocation

class WeatherForecastViewController: UIViewController {
    
    // MARK: - Properties
    var viewModel: WeatherForecastViewModel! {
        didSet {
            setupSearchResultsController()
            setBindings()
        }
    }
    
    private var storage: Set<AnyCancellable> = []

    // MARK: - Weather Views
    private lazy var currentWeatherView = DayWeatherView(frame: .zero)
    private lazy var weeklyWeatherView = WeeklyWeatherView(frame: .zero)

    // MARK: - Location Properties
    private var currentLocation: CLLocation? {
        didSet {
            fetchWeatherData()
        }
    }

    private lazy var locationManager: CLLocationManager = {
        // Initialize Location Manager
        let locationManager = CLLocationManager()
        return locationManager
    }()

    private lazy var locationsSearchController: UISearchController = {
        let searchController = UISearchController(searchResultsController: SearchLocationResultViewController())
        searchController.searchBar.tintColor = .red
        searchController.hidesNavigationBarDuringPresentation = false
        return searchController
    }()
    
    // MARK: - View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()

        self.setupObservables()
        self.requestCurrentLocation()
        self.setupNavigationBar()
        self.setLocalBindings()
        addKeyboardHideTapGesture()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.setupViews()
    }

    func setBindings() {
        viewModel.searchResultsUpdatingPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] cities in
                guard
                    let locationSearchResultsController = self?.locationsSearchController.searchResultsController as? SearchLocationResultViewController,
                    let rearchResultsViewModel = locationSearchResultsController.viewModel
                else { return }
                rearchResultsViewModel.updateResults(with: cities)
            }
            .store(in: &storage)
        
        viewModel.addingNewLocationPublisher
            .sink { [weak self] city in
                guard let city = city, let lat = city.lat, let lon = city.lon else { return }
                self?.currentLocation = CLLocation(latitude: lat, longitude: lon)
            }
            .store(in: &storage)
    }
    
    func setLocalBindings() {
        NotificationCenter.default.publisher(for: UISearchTextField.textDidChangeNotification, object: locationsSearchController.searchBar.searchTextField)
            .compactMap { ($0.object as? UISearchTextField)?.text }
            .compactMap { $0.isEmpty ? nil : $0 }
            .debounce(for: .seconds(0.5), scheduler: DispatchQueue.main)
            .removeDuplicates()
            .sink { [weak self] searchText in
                self?.viewModel.searchCity(query: searchText)
            }
            .store(in: &storage)
    }
    
    func setupSearchResultsController() {
        guard let locationsSearchResultsController = locationsSearchController.searchResultsController as? SearchLocationResultViewController else { return }
        locationsSearchResultsController.viewModel = viewModel.viewModelForLocationsSearchResultsController()
    }
    
    func addKeyboardHideTapGesture() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    private func setupNavigationBar() {
        navigationItem.searchController = locationsSearchController
    }
}

// MARK: - UI Configurations
extension WeatherForecastViewController {

    private func setupViews() {
        view.backgroundColor = .systemBackground
        [currentWeatherView, weeklyWeatherView].forEach { view.addSubview($0) }

        setupConstraints()
    }

    private func setupConstraints() {
        NSLayoutConstraint.activate([
            currentWeatherView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            currentWeatherView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            currentWeatherView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            currentWeatherView.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.25),

            weeklyWeatherView.topAnchor.constraint(equalTo: currentWeatherView.bottomAnchor),
            weeklyWeatherView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            weeklyWeatherView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            weeklyWeatherView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }

    private func showAlert(of type: AlertType, isCancellable: Bool = true) {
        let title, message: String

        switch type {
        case .locationRequestFailed:
            title = "location_request_error_title".localized()
            message = "location_request_error_message".localized()
        case .weatherDataNotAvailable:
            title = "location_data_error_title".localized()
            message = "location_data_error_message".localized()
        }

        // Initialize Alert Controller
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)

        if isCancellable {
            // Add Cancel Action
            let cancelAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
            alertController.addAction(cancelAction)
        }

        // Present Alert Controller
        DispatchQueue.main.async {
            self.present(alertController, animated: true)
        }
    }
}

// MARK: - Data Configurations
extension WeatherForecastViewController {
    private func setupObservables() {
        guard let viewModel = viewModel else { return }

        viewModel.showCurrentWeatherLoader.sink(receiveValue: {
            self.currentWeatherView.startWeatherIndicator(start: $0)
        }).store(in: &storage)

        viewModel.showWeeklyWeatherLoader.sink(receiveValue: {
            self.weeklyWeatherView.startWeatherIndicator(start: $0)
        }).store(in: &storage)

        viewModel.showWeatherDataError.sink { [weak self] _ in
            self?.showAlert(of: .weatherDataNotAvailable)
        }.store(in: &storage)

        viewModel.dailyWeatherData.sink { [weak self] completion in
            switch completion {
            case .failure:
                self?.showAlert(of: .weatherDataNotAvailable)
            default: return
            }
        } receiveValue: { [weak self] dailyData in
            self?.setupDailyWeather(with: dailyData)
        }.store(in: &storage)

        viewModel.weeklyWeatherData.sink { [weak self] completion in
            switch completion {
            case .failure:
                self?.showAlert(of: .weatherDataNotAvailable)
            default: return
            }
        } receiveValue: { [weak self] weeklyData in
            self?.weeklyWeatherView.dataSource = weeklyData.list
        }.store(in: &storage)
    }

    private func setupDailyWeather(with data: WeatherResponse) {
        let largeFont = UIFont.systemFont(ofSize: 50)
        let configuration = UIImage.SymbolConfiguration(font: largeFont)

        DispatchQueue.main.async {
            self.currentWeatherView.locationLabel.text = "\(data.name), \(data.sys.country)"
            self.currentWeatherView.temperatureLabel.text = data.main.temp.convertTemp(to: .fahrenheit)
            self.currentWeatherView.weatherDescriptionLabel.text = data.weather.first?.description.capitalized

            switch data.weather.first?.main {
            case .clear:
                self.currentWeatherView.weatherIcon.image = UIImage(systemName: "sun.max.fill", withConfiguration: configuration)
            case .clouds:
                self.currentWeatherView.weatherIcon.image = UIImage(systemName: "cloud.fill", withConfiguration: configuration)
            case .rain:
                self.currentWeatherView.weatherIcon.image = UIImage(systemName: "cloud.drizzle.fill", withConfiguration: configuration)
            case .haze:
                self.currentWeatherView.weatherIcon.image = UIImage(systemName: "sun.haze.circle.fill", withConfiguration: configuration)
            default:
                self.currentWeatherView.weatherIcon.image = UIImage(systemName: "sun.max.fill", withConfiguration: configuration)
            }
        }
    }
}

// MARK: - Location Configurations
extension WeatherForecastViewController {

    private func requestCurrentLocation() {
        // Configure Location Manager
        locationManager.requestWhenInUseAuthorization()
        DispatchQueue.global().async { [weak self] in
            if CLLocationManager.locationServicesEnabled() {
                self?.locationManager.delegate = self
                self?.locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
                self?.locationManager.startUpdatingLocation()
            }
        }
    }

    private func fetchWeatherData() {
        guard
            let viewModel = self.viewModel,
            let location = currentLocation
        else { return }

        // Get Coordinates
        let coordinates = Coordinates(lat: location.coordinate.latitude, lon: location.coordinate.longitude)

        // Retrieve weather data
        try? viewModel.getCurrentWeatherData(at: coordinates)
        try? viewModel.getWeeklyWeatherData(at: coordinates)
    }
}

// MARK: - Location Delegate
extension WeatherForecastViewController: CLLocationManagerDelegate {

    // MARK: - Authorization
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        case .authorizedAlways, .authorizedWhenInUse:
            // Request Location
            locationManager.requestLocation()
        default:
            guard let cityStored = UserDefaults.standard.fetchLastCity(),
            let lat = cityStored.lat,
            let long = cityStored.lon else {
                // Alert User
                showAlert(of: .locationRequestFailed)
                return
            }
            currentLocation = CLLocation(latitude: lat, longitude: long)
        }
    }

    // MARK: - Location Updated
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.first {
            // Update Current Location
            currentLocation = location
        } else {
            guard let cityStored = UserDefaults.standard.fetchLastCity(),
            let lat = cityStored.lat,
            let long = cityStored.lon else {
                // Alert User
                showAlert(of: .locationRequestFailed)
                return
            }
            currentLocation = CLLocation(latitude: lat, longitude: long)
        }
    }

    // MARK: - Location Fetch Failed
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        
        guard let cityStored = UserDefaults.standard.fetchLastCity(),
        let lat = cityStored.lat,
        let long = cityStored.lon else {
            // Alert User
            showAlert(of: .locationRequestFailed)
            return
        }
        currentLocation = CLLocation(latitude: lat, longitude: long)
    }
}

@objc private extension WeatherForecastViewController {
    func dismissKeyboard() {
        locationsSearchController.searchBar.searchTextField.resignFirstResponder()
    }
}
