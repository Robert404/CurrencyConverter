//
//  ConvertionHistoryViewModel.swift
//  CurrencyConverter
//
//  Created by Robert Nersesyan on 23.03.24.
//

import Foundation
import CoreData
import Combine

final class ConvertionHistoryViewModel: ObservableObject {
    @Published var convertions = [Convertion]()
    @Published var filteredConvertions = [Convertion]()
    @Published var searchText: String = ""
    
    private var disposables = Set<AnyCancellable>()
    
    init() {
        setupBindings()
    }
    
    func setupBindings() {
        $searchText
            .sink { [weak self] text in
                guard let self = self else { return }
                if text.isEmpty {
                    self.filteredConvertions = self.convertions
                } else {
                    self.filteredConvertions = self.convertions.filter {
                        $0.fromCurrency.localizedCaseInsensitiveContains(text) ||
                        $0.toCurrency.localizedCaseInsensitiveContains(text) ||
                        String($0.sum).contains(text)
                    }
                }
            }.store(in: &disposables)
    }
    
    func getHistory(_ context: NSManagedObjectContext) {
        let request = NSFetchRequest<Convertion>(entityName: Consts.convertionEntity)
        
        do {
            convertions = try context.fetch(request)
            filteredConvertions = convertions
        }
        catch(let error) {
            print("CoreData failed to fetch: \(error.localizedDescription)")
        }
    }
}
