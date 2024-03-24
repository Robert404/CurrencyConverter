//
//  ApiService.swift
//  CurrencyConverter
//
//  Created by Robert Nersesyan on 22.03.24.
//

import Foundation
import Combine
import CoreData

enum ApiError: Error {
    case wrongUrl
    case invalidData
    case unknown
}

protocol ApiServiceProtocol {
    func convertCurrency(from: CurrencyCode, to: CurrencyCode, sum: Double) -> Double
    func getRates(_ completion: @escaping (Result<[CurrencyPair], ApiError>) -> Void)
}

final class ApiService: ApiServiceProtocol, ObservableObject {
    
    private var timer: Timer?
    private var pairs = [CurrencyPair]()
    
    deinit {
        self.timer?.invalidate()
        self.timer = nil
    }
    
    func getRates(_ completion: @escaping (Result<[CurrencyPair], ApiError>) -> Void) {
        guard let url = Endpoint.ratesURL else {
            completion(.failure(.wrongUrl))
            return
        }
        
        URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
            guard let self, let data else {
                self?.getRatesFromDB()
                completion(.failure(.invalidData))
                return
            }
            guard let response = response as? HTTPURLResponse, 200 ... 299 ~= response.statusCode else {
                self.getRatesFromDB()
                completion(.failure(.invalidData))
                return
            }
            
            do {
                guard let data = try JSONSerialization.jsonObject(with: data, options: .fragmentsAllowed) as? [String: [String: Double]],
                let model = data["data"] else {
                    self.getRatesFromDB()
                    return
                }
                deleteRatesFromDB()
                self.pairs = model.map { (key, value) in
                    let toCurrency = CurrencyCode(rawValue: key) ?? .EUR
                    let pair = CurrencyPair(from: .USD, to: toCurrency, rate: value)
                    self.addRateToDB(pair)
                    return pair
                }
            }
            catch {
                self.getRatesFromDB()
                completion(.failure(.unknown))
            }
        }.resume()
    }
    
    func convertCurrency(from: CurrencyCode, to: CurrencyCode, sum: Double) -> Double {
        let rate = getRate(from: from, to: to)
        let result = sum * rate
        return result
    }
    
    private func getRate(from: CurrencyCode, to: CurrencyCode) -> Double {
        let fromRate = 1 / getRate(for: from)
        let toRate = getRate(for: to)
        return fromRate * toRate
    }
    
    private func getRate(for currency: CurrencyCode) -> Double {
        guard !pairs.isEmpty else { return 0 }
        return pairs.filter { $0.to == currency }.first?.rate ?? 0
    }
    
    private func deleteRatesFromDB() {
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = CurrencyRate.fetchRequest()
        let batchDeleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        _ = try? CoreDataManager.shared.context.execute(batchDeleteRequest)
    }
    
    private func addRateToDB(_ pair: CurrencyPair) {
        let currencyRate = CurrencyRate(context: CoreDataManager.shared.context)
        currencyRate.from = pair.from.rawValue
        currencyRate.to = pair.to.rawValue
        currencyRate.rate = pair.rate
        do {
            try? CoreDataManager.shared.saveContext()
        } catch(let error) {
            print("CoreData failed to add: \(error.localizedDescription)")
        }
    }
    
    private func getRatesFromDB() {
        let request = NSFetchRequest<CurrencyRate>(entityName: Consts.currencyRateEntity)
        
        do {
            let rates = try CoreDataManager.shared.context.fetch(request)
            self.pairs = rates.map { rate in
                return CurrencyPair(
                    from: CurrencyCode(rawValue: rate.from!) ?? .USD,
                    to: CurrencyCode(rawValue: rate.to!) ?? .RUB,
                    rate: rate.rate
                )
            }
        }
        catch(let error) {
            print("CoreData failed to fetch: \(error.localizedDescription)")
        }
    }
}
