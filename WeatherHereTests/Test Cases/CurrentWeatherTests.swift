//
//  WeatherAPIServiceTests.swift
//  WeatherHereTests
//
//  Created by Prashant Pandey on 6/8/23.
//

import XCTest
import Combine
@testable import WeatherHere

class CurrentWeatherTests: XCTestCase {

    // MARK: - Properties
    var viewModel: WeatherForecastViewModel!
    var weatherResponse: WeatherResponse!
    var subscriptions = Set<AnyCancellable>()

    override func setUpWithError() throws {
        viewModel = WeatherForecastViewModel()
        try loadStubData()
    }

    override func tearDownWithError() throws {
        viewModel = nil
        weatherResponse = nil
        subscriptions = []
    }

    /// Load sample weather data for the current day
    func loadStubData() throws {
        // Load Stub
        let data = loadStub(name: "currentWeatherStub", extension: "json")

        // Create JSON Decoder
        let decoder = JSONDecoder()

        // Decode JSON
        do {
            let weatherData = try decoder.decode(WeatherResponse.self, from: data)
            // Set weather data
            weatherResponse = weatherData
        } catch let error {
            print(error)
        }
    }

    /// Test validity of current weather url
    func testCurrentWeatherUrl() {
        XCTAssertEqual(viewModel.currentWeatherUrl, Services.currentWeatherData, "Incorrent current weather url")
    }

    /// Test weather data decoded to expected format
    func testDataDecodedSuccessfully() {
        XCTAssertNotNil(weatherResponse, "Weather data decoded successfully")
        XCTAssertEqual(weatherResponse.name, "Long Island City")
    }

    /// Ensure all mandatory data to be displayed to user exists
    func testMandatoryDataNotEmpty() {
        XCTAssertNotNil(weatherResponse.main.temp, "Temperature not set")
        XCTAssertNotNil(weatherResponse.weather.first?.description, "Description not available")
        XCTAssertNotNil(weatherResponse.name, "Location name not set")
        XCTAssertNotNil(weatherResponse.sys.country, "Country name not set")
    }

    /// Ensure all mandatory data to be displayed to user is correct
    func testMandatoryDataValidity() {
        XCTAssertEqual(weatherResponse.main.temp, 295.08)
        XCTAssertEqual(weatherResponse.weather.first?.description, "haze")
        XCTAssertEqual(weatherResponse.name, "Long Island City")
        XCTAssertEqual(weatherResponse.sys.country, "US")
    }

    /// Ensure the weather icon is retrieved in the right format
    func testWeatherIconValidity() throws {
        let weatherIcon = try XCTUnwrap(weatherResponse.weather.first?.main)
        XCTAssertEqual(weatherIcon, .haze)
    }

    /// Ensure received coordinates are in correct and in the right format
    func testReceivedCoordinatesValidity() {
        XCTAssertEqual(weatherResponse.coord.lon, -73.9352)
        XCTAssertEqual(weatherResponse.coord.lat, 40.7306)
    }

    /// Ensure that the main temperature is converted to celsius correctly
    func testTemperatureConversionValidity() {
        XCTAssertEqual(weatherResponse.main.temp.convertTemp(to: .fahrenheit), "71°F")
    }

    /// Test that weather data stream is subscribed to and observed correctly.
    ///
    /// This also checks validity of data being streamed
    func testReceivedDataObservable() {
        let ex = XCTestExpectation()

        // create subscription first
        viewModel.dailyWeatherData.sink { completion in
            ex.fulfill()
        } receiveValue: { response in
            XCTAssertNotNil(response)
            ex.fulfill()
        }.store(in: &subscriptions)

        // send data to be observed to subscription
        viewModel.dailyWeatherData.send(weatherResponse)

        wait(for: [ex], timeout: 1)
    }

    /// Checks that the loader is displayed and dismissed to user correctly
    func testLoadingAnimationObservable() {
        let ex = XCTestExpectation()

        // create subscription first
        viewModel.showCurrentWeatherLoader.sink { completion in
            ex.fulfill()
        } receiveValue: { show in
            XCTAssertEqual(show, true)
            ex.fulfill()
        }.store(in: &subscriptions)

        // send data to be observed to subscription
        viewModel.showCurrentWeatherLoader.send(true)

        wait(for: [ex], timeout: 1)
    }

    /// Checks that errors are displayed to user correctly
    func testFetchDataErrorObservable() {
        let ex = XCTestExpectation()

        // create subscription first
        viewModel.showWeatherDataError.sink { completion in
            ex.fulfill()
        } receiveValue: { error in
            XCTAssertEqual(error, NetworkError.decodingError.localizedDescription)
            ex.fulfill()
        }.store(in: &subscriptions)

        // send data to be observed to subscription
        viewModel.showWeatherDataError.send(NetworkError.decodingError.localizedDescription)

        wait(for: [ex], timeout: 1)
    }

    /// Ensure data is decoded quick enough and displayed to user
    ///
    /// Current baseline is set to 0.000373 seconds
    func testDecodeDataPerformance() throws {
        // This is an example of a performance test case.
        self.measure {
            try! loadStubData()
        }
    }

}
