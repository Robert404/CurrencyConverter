//
//  CoreDataManager.swift
//  CurrencyConverter
//
//  Created by Robert Nersesyan on 24.03.24.
//

import Foundation
import CoreData

final class CoreDataManager {
    static let shared = CoreDataManager()
    
    private init() {}
    
    var context: NSManagedObjectContext {
        return container.viewContext
    }
    
    lazy var container: NSPersistentContainer = {
        let container = NSPersistentContainer(name: Consts.convertionEntity)
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                print("Core Data failed to load: \(error.localizedDescription)")
            }
        })
        return container
    }()
    
    func saveContext() throws {
        let context = container.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                throw ApiError.unknown
            }
        }
    }
}
