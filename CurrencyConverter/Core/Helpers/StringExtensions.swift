//
//  StringExtensions.swift
//  CurrencyConverter
//
//  Created by Robert Nersesyan on 24.03.24.
//

import Foundation

extension String {
    var isEmptyOrWhiteSpace: Bool {
        let whitespace = CharacterSet.whitespacesAndNewlines
        let trimmed = trimmingCharacters(in: whitespace)
        return isEmpty || trimmed.isEmpty
    }
}
