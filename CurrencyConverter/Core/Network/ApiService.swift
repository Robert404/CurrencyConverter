//
//  ApiService.swift
//  CurrencyConverter
//
//  Created by Robert Nersesyan on 22.03.24.
//

import Foundation

enum ApiError: Error {
    case invalidData
    case invalidResponse
    case unknown
    case error(_ message: String)
}

protocol ApiServiceProtocol {
    func getCurrencies(completion: @escaping (Result<[Currency], ApiError>) -> Void)
    func convertCurrency(from: String, to: String, completion: @escaping (Result<Double, ApiError>) -> Void)
}

final class ApiService: ApiServiceProtocol {
    private let apiKey = "fca_live_8gk3TfoCVG9RwunVEtguMeKCgm9TDBrkhIoxpCTN"

    private let testString = URL(string: "https://api.freecurrencyapi.com/v1/currencies?apikey=fca_live_8gk3TfoCVG9RwunVEtguMeKCgm9TDBrkhIoxpCTN&currencies=RUB%2CUSD%2CEUR%2CGBP%2CCHF%2CCNY")!
    
    func getCurrencies(completion: @escaping (Result<[Currency], ApiError>) -> Void) {
        URLSession.shared.dataTask(with: testString) { data, response, error in
            guard let data else {
                completion(.failure(.invalidData))
                return
            }
            guard let response = response as? HTTPURLResponse, 200 ... 299  ~= response.statusCode else {
                completion(.failure(.invalidResponse))
                return
            }
            
            do {
                let currencyData = try JSONDecoder().decode(CurrencyData.self, from: data)
                completion(.success(Array(currencyData.data.values)))
            }
            catch {
                completion(.failure(.error(error.localizedDescription)))
            }
        }.resume()
    }
    
    func convertCurrency(from: String, to: String, completion: @escaping (Result<Double, ApiError>) -> Void) {
        let url = URL(string: "https://api.freecurrencyapi.com/v1/latest?apikey=fca_live_8gk3TfoCVG9RwunVEtguMeKCgm9TDBrkhIoxpCTN&currencies=\(to)&base_currency=\(from)")!
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data else {
                completion(.failure(.invalidData))
                return
            }
            guard let response = response as? HTTPURLResponse, 200 ... 299  ~= response.statusCode else {
                completion(.failure(.invalidResponse))
                return
            }
            
            do {
                if let json = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String:[String:Any]],
                   let data = json["data"], let rate = data["RUB"] as? Double {
                    completion(.success(rate))
                }
            }
            catch {
                completion(.failure(.error(error.localizedDescription)))
            }
        }.resume()
    }
}
