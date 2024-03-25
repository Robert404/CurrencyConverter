//
//  Convertion+CoreDataProperties.swift
//  CurrencyConverter
//
//  Created by Robert Nersesyan on 25.03.24.
//
//

import Foundation
import CoreData


extension Convertion {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Convertion> {
        return NSFetchRequest<Convertion>(entityName: "Convertion")
    }

    @NSManaged public var fromCurrency: String
    @NSManaged public var sum: Double
    @NSManaged public var toCurrency: String

}

extension Convertion : Identifiable {

}
