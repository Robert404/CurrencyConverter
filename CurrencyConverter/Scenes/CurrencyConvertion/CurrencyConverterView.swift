//
//  ContentView.swift
//  CurrencyConverter
//
//  Created by Robert Nersesyan on 22.03.24.
//

import SwiftUI

struct CurrencyConverterView: View {
    @State private var showError: Bool = false
    @State private var enteredSum: String = ""
    @State private var showHistory = false
    
    @StateObject var viewModel = CurrencyConverterViewModel()
    
    var body: some View {
        VStack {
            Text("Currency Converter 💪")
                .font(.system(size: 26, weight: .semibold))
                .padding(.top, 20)
            
            Button(action: {
                showHistory.toggle()
            }, label: {
                Text("Convertions History")
                    .font(.headline)
                    .foregroundStyle(.blue)
                    .frame(height: 25)
            })
            .sheet(isPresented: $showHistory, content: {
                ConvertionHistoryView()
                    .environment(\.managedObjectContext, CoreDataManager.shared.context)
            })
            
            Form {
                Section {
                    TextField("Enter the sum", text: $enteredSum)
                        .keyboardType(.decimalPad)
                
                    Picker(selection: $viewModel.firstSelected, label: Text("From")) {
                        ForEach(CurrencyCode.allCases, id: \.self) { currency in
                            Text(currency.rawValue).tag(currency)
                        }
                    }
                    .onChange(of: viewModel.firstSelected) { _, _ in
                        DispatchQueue.main.async {
                            viewModel.convertedSum = 0.0
                        }
                    }
                
                    Picker(selection: $viewModel.secondSelected, label: Text("To")) {
                        ForEach(CurrencyCode.allCases, id: \.self) { currency in
                            Text(currency.rawValue).tag(currency)
                        }
                    }
                    .onChange(of: viewModel.secondSelected) { _, _ in
                        DispatchQueue.main.async {
                            viewModel.convertedSum = 0.0
                        }
                    }
                }
                
                Section(header: Text("Converted")) {
                    Text("\(viewModel.convertedSum.formatted(.currency(code: viewModel.secondSelected.rawValue)))")
                        .font(.headline)
                }
            }
            .frame(height: 300)
            .scrollContentBackground(.hidden)
            .gesture(DragGesture().onChanged{_ in UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)})

            
            Button(action: {
                viewModel.convertCurrency(sum: Double(enteredSum) ?? 0)
            }, label: {
                Text("Convert")
                    .font(.headline)
                    .foregroundStyle(.white)
                    .frame(height: 55)
                    .frame(maxWidth: .infinity)
                    .background(Color.blue)
                    .cornerRadius(10)
            })
            .buttonStyle(PlainButtonStyle())
            .padding(30)
            .disabled(!isSumValid)
        }
        .task {
            viewModel.getRates()
            viewModel.getLatestCurrencyPair()
            viewModel.startRefreshRatesTimer(timeInterval: 180)
        }
        .onReceive(viewModel.$errorMessage, perform: { _ in
            showError = !viewModel.errorMessage.isEmpty
        })
        .alert("\(viewModel.errorMessage)", isPresented: $showError) {
            VStack {
                Button("Close", role: .cancel) {}
            }
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .background {
            Color.gray.opacity(0.1)
                .ignoresSafeArea()
        }
    }
    
    private var isSumValid: Bool {
        !enteredSum.isEmptyOrWhiteSpace && Double(enteredSum) != 0
    }
}

#Preview {
    CurrencyConverterView()
}
