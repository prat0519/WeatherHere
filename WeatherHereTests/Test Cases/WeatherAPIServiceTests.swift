//
//  WeatherAPIServiceTests.swift
//  WeatherHereTests
//
//  Created by Prashant Pandey on 6/8/23.
//

import XCTest
@testable import WeatherHere

class WeatherAPIServiceTests: XCTestCase {

    // MARK: - Properties
    var testURL: String?
    var weatherAPIServiceMock: WeatherAPIServiceMock?
    var urlServiceMock: URLServiceMock?
    var weatherResponse: WeatherResponse!

    override func setUpWithError() throws {
        weatherAPIServiceMock = WeatherAPIServiceMock()
        urlServiceMock = URLServiceMock()
        testURL = "test/api"

        // Do a mock fetch
        loadDataFromMockApi()
    }

    override func tearDownWithError() throws {
        testURL = nil
        weatherAPIServiceMock = nil
        weatherResponse = nil
    }

    func loadDataFromMockApi()  {
        guard self.testURL != nil else {
            XCTFail("URL not found")
            return
        }
        
        let publisher = try? weatherAPIServiceMock?.requestData(for: WeatherResponse.self, location: (latitude: 40.730610, longitude: -73.935242), route: .weather)
        _ = publisher?
            .sink(receiveCompletion: { completion in
            if case .failure(let error) = completion {
                XCTFail(error.localizedDescription)
            }
        }, receiveValue: { response in
            self.weatherResponse = response
        })
    }

    /// Test that data is received from the mock
    func testDataFetchedCorrectly() {
        XCTAssertNotNil(weatherResponse)
    }

    /// Test that data received is decoding correctly
    func testReceivedDataValidity() {
        XCTAssertEqual(weatherResponse.name, "Long Island City")
    }

    /// Test that the url supplied is not empty
    func testUrlValidity() {
        let url = urlServiceMock?.createURL(scheme: "https", host: "api.openweathermap.org", path: "data/2.5/weather", queryParameters: [
            "lat": "48.1371079",
            "lon": "11.5753822",
            "appid": "d24157b1fdda25809558f37e50ab92d9",
        ])
        XCTAssertEqual(url?.scheme, "https")
        XCTAssertEqual(url?.host, "api.openweathermap.org")
        XCTAssertEqual(url?.path, "/data/2.5/weather")
    }
}

