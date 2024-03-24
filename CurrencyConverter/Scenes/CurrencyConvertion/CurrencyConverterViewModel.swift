//
//  CurrencyConverterViewModel.swift
//  CurrencyConverter
//
//  Created by Robert Nersesyan on 22.03.24.
//

import Foundation
import Combine
import CoreData

final class CurrencyConverterViewModel: ObservableObject {
    
    @Published var convertedSum = 0.0
    @Published var errorMessage: String = ""
    @Published var firstSelected: CurrencyCode = .USD
    @Published var secondSelected: CurrencyCode = .RUB
    
    private let apiService: ApiServiceProtocol
    private var disposables = Set<AnyCancellable>()
    
    private var timer: Timer?
        
    init(_ apiService: ApiServiceProtocol = ApiService()) {
        self.apiService = apiService
    }
    
    deinit {
        self.timer?.invalidate()
        self.timer = nil
    }
    
    func startRefreshRatesTimer(timeInterval: TimeInterval, repeats: Bool = true, completion: (() -> Void)? = nil) {
        timer = Timer.scheduledTimer(withTimeInterval: timeInterval, repeats: repeats, block: { [weak self] _ in
            guard let self = self else { return }
            
            self.apiService.getRates { result in
                switch result {
                case .success:
                    break
                case .failure(let failure):
                    self.showError(failure)
                }
                completion?()
            }
        })
    }
    
    func getRates() {
        apiService.getRates { result in
            switch result {
            case .success:
                break
            case .failure(let failure):
                self.showError(failure)
            }
        }
    }
    
    func convertCurrency(sum: Double) {
        let sum = apiService.convertCurrency(from: firstSelected, to: secondSelected, sum: sum)
        self.convertedSum = sum
        self.addToHistory()
    }
    
    func getLatestCurrencyPair() {
        let request = NSFetchRequest<Convertion>(entityName: Consts.convertionEntity)
        
        do {
            let convertions = try CoreDataManager.shared.context.fetch(request)
            guard let last = convertions.last else { return }
            self.firstSelected = CurrencyCode(rawValue: last.fromCurrency ?? "USD") ?? .USD
            self.secondSelected = CurrencyCode(rawValue: last.toCurrency ?? "EUR") ?? .EUR
        }
        catch(let error) {
            print("CoreData failed to fetch: \(error.localizedDescription)")
        }
    }
    
    private func addToHistory() {
        let convertion = Convertion(context: CoreDataManager.shared.context)
        convertion.fromCurrency = self.firstSelected.rawValue
        convertion.toCurrency = self.secondSelected.rawValue
        convertion.sum = self.convertedSum
        do {
            try? CoreDataManager.shared.saveContext()
        } catch(let error) {
            print("Core data failed to add: \(error.localizedDescription)")
        }
    }
    
    private func showError(_ type: ApiError) {
        switch type {
        case .wrongUrl:
            self.errorMessage = "Error appeared, plese try again later"
        case .invalidData:
            self.errorMessage = "Something wrong with data, plese try again later"
        case .unknown:
            self.errorMessage = "Unknown error appeared, plese try again later"
        }
    }
}
