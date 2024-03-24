//
//  CurrencyConverterTests.swift
//  CurrencyConverterTests
//
//  Created by Robert Nersesyan on 24.03.24.
//

import XCTest
@testable import CurrencyConverter

class ApiServiceMock: ApiServiceProtocol {
    var responseStatusCode = 0
    
    func convertCurrency(from: CurrencyConverter.CurrencyCode, to: CurrencyConverter.CurrencyCode, sum: Double) -> Double {
        return 0.0
    }
    
    func getRates(_ completion: @escaping (Result<[CurrencyConverter.CurrencyPair], CurrencyConverter.ApiError>) -> Void) {
        guard let url = Endpoint.ratesURL else {
            completion(.failure(.unknown))
            return
        }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            guard data != nil else {
                completion(.failure(.unknown))
                return
            }
            guard let response = response as? HTTPURLResponse, 200 ... 299 ~= response.statusCode else {
                completion(.failure(.unknown))
                return
            }
            self.responseStatusCode = response.statusCode
            completion(.success([]))
        }.resume()
    }
}

class ApiServiceMockFailed: ApiServiceProtocol {
    var responseStatusCode = 0
    
    func convertCurrency(from: CurrencyConverter.CurrencyCode, to: CurrencyConverter.CurrencyCode, sum: Double) -> Double {
        return 0.0
    }
    
    func getRates(_ completion: @escaping (Result<[CurrencyConverter.CurrencyPair], CurrencyConverter.ApiError>) -> Void) {
        completion(.failure(.unknown))
    }
}

final class CurrencyConverterTests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testGetCurrencyRatesSuccess() {
        // Arrange
        let apiServiceMock = ApiServiceMock()
        let expectedStatusCode = 200
        let expectedError = ""
        let expectation = self.expectation(description: "network")
        
        // Act
        var errorMessage = ""
        apiServiceMock.getRates { result in
            if case .failure(let failure) = result {
                errorMessage = failure.localizedDescription
            }
            expectation.fulfill()
        }
        
        // Assert
        wait(for: [expectation], timeout: 3)
        XCTAssertEqual(errorMessage, expectedError)
        XCTAssertEqual(expectedStatusCode, apiServiceMock.responseStatusCode)
    }
    
    func testGetCurrencyRatesFailed() {
        // Arrange
        let apiServiceMock = ApiServiceMockFailed()
        let expectedError = ApiError.unknown
        let expectation = self.expectation(description: "network")
        
        // Act
        var errorMessage = ApiError.invalidData
        apiServiceMock.getRates { result in
            if case .failure(let failure) = result {
                errorMessage = failure
            }
            expectation.fulfill()
        }
        
        // Assert
        wait(for: [expectation], timeout: 3)
        XCTAssertEqual(errorMessage, expectedError)
    }
    
    func testStartRefreshRatesTimerSuccess() {
        // Arrange
        let apiServiceMock = ApiServiceMock()
        let vm = CurrencyConverterViewModel(apiServiceMock)
        let expectedStatusCode = 200
        let expectation = self.expectation(description: "network")
        
        // Act
        vm.startRefreshRatesTimer(timeInterval: 1.0) {
            expectation.fulfill()
        }
        
        // Assert
        wait(for: [expectation], timeout: 2)
        XCTAssertEqual(apiServiceMock.responseStatusCode, expectedStatusCode)
    }
}
