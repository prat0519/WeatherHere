//
//  Publisher + Ext.swift
//  WeatherHere
//
//  Created by Prashant Pandey on 6/8/23.
//

import UIKit
import Combine

extension Publisher {
    func assumeHTTP() -> AnyPublisher<(data: Data, httpResponse: HTTPURLResponse), Error> where Output == (data: Data, response: URLResponse), Failure == URLError {
        tryMap { data, response in
            guard let httpResponse = response as? HTTPURLResponse else {
                throw HTTPError.nonHTTPRequest
            }
            
            let statusCode = httpResponse.statusCode
            
            if case (400..<500) = statusCode {
                throw HTTPError.requestFailed(statusCode: statusCode)
            } else if case (500..<600) = statusCode {
                throw HTTPError.serverError(statusCode: statusCode)
            }
            
            return (data, httpResponse)
        }
        .eraseToAnyPublisher()
    }
    
    func mapHTTPError() -> Publishers.MapError<Self, HTTPError> {
        mapError { error in
            switch error {
            case is HTTPError:
                return error as! HTTPError
            case is DecodingError:
                return HTTPError.decodingError(error as! DecodingError)
            default:
                return HTTPError.networkError(error)
            }
        }
    }
}

