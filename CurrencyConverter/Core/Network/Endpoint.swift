//
//  Endpoint.swift
//  CurrencyConverter
//
//  Created by Robert Nersesyan on 24.03.24.
//

import Foundation

public struct Endpoint {
    static let apiKey = "fca_live_8gk3TfoCVG9RwunVEtguMeKCgm9TDBrkhIoxpCTN"
    static let baseURL = "https://api.freecurrencyapi.com/v1/"
    static let ratesURL = URL(string: "\(baseURL)latest?apikey=\(apiKey)&currencies=\(CurrencyCode.allCases.map { $0.rawValue }.joined(separator: "%2C"))")
}
