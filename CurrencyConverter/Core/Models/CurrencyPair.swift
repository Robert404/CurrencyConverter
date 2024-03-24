//
//  CurrencyPair.swift
//  CurrencyConverter
//
//  Created by Robert Nersesyan on 24.03.24.
//

import Foundation

final class CurrencyPair {
    let from: CurrencyCode
    let to: CurrencyCode
    let rate: Double
    
    init(from: CurrencyCode, to: CurrencyCode, rate: Double) {
        self.from = from
        self.to = to
        self.rate = rate
    }
}
