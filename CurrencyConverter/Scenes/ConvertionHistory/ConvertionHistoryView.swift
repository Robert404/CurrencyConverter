//
//  ConvertionHistoryView.swift
//  CurrencyConverter
//
//  Created by Robert Nersesyan on 23.03.24.
//

import SwiftUI

struct ConvertionHistoryView: View {
    @StateObject var viewModel = ConvertionHistoryViewModel()
    @Environment(\.managedObjectContext) private var viewContext
    
    var body: some View {
        NavigationView {
            VStack {
                if viewModel.filteredConvertions.isEmpty {
                    Text("No conversions found")
                        .font(.title2)
                        .foregroundColor(.secondary)
                        .padding()
                } else {
                    List {
                        ForEach(viewModel.filteredConvertions, id: \.self) { conversion in
                            HStack {
                                Text("\(conversion.fromCurrency) / \(conversion.toCurrency)")
                                Spacer()
                                Text("\(conversion.toCurrency) \(String(format: "%.2f", conversion.sum))")
                            }
                        }
                    }
                }
            }
            .navigationTitle("Conversions History")
            .searchable(text: $viewModel.searchText, placement: .navigationBarDrawer(displayMode: .always))
            .onAppear {
                viewModel.getHistory(viewContext)
            }
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

#Preview {
    ConvertionHistoryView()
}
