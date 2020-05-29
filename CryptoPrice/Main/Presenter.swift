//
//  Presenter.swift
//  CryptoPrice
//
//  Created by Jan Svensson on 2020-05-29.
//  Copyright © 2020 Jan Svensson. All rights reserved.
//

import Foundation

protocol MainPresentable: class {
    func onSelectedInterval(_ selectedIndex: Int)
    func onSelectedCurrency(on row: Int)
    func onMore()
    func refreshPrice()
    
    var coordinator: MainScreenCoordinator? { get set }
    var database: Database? { get set }
    var controller: MainViewController? { get set }
    var currencies: [CryptoCurrency] { get set }
    var selectedCrypto: CryptoCurrency { get }
    var selectedInterval: String { get }
}

class MainPresenter: MainPresentable {
    var coordinator: MainScreenCoordinator?
    var database: Database?
    weak var controller: MainViewController?
    
    var currencies: [CryptoCurrency]
    var selectedCrypto: CryptoCurrency {
        didSet {
            controller?.topTitle.text = selectedCrypto.name
            controller?.loadingSpinner.startAnimating()
            refreshPrice()
        }
    }
    var selectedInterval: String = "h1" {
        didSet {
            controller?.loadingSpinner.startAnimating()
            refreshPrice()
        }
    }
    
    init(_ currencies: [CryptoCurrency], controller: MainViewController) {
        self.currencies = currencies
        selectedCrypto = currencies.first ?? CryptoCurrency()
        self.controller = controller
        
        controller.topTitle.text = selectedCrypto.name
        
    }
    
    func onSelectedInterval(_ selectedIndex: Int) {
        var interval: String

        switch selectedIndex {
        case 0: interval = "m15"
        case 1: interval = "h1"
        case 2: interval = "h6"
        case 3: interval = "h12"
        case 4: interval = "d1"
        default:
            interval = "h1"
        }

        selectedInterval = interval
    }

    func onSelectedCurrency(on row: Int) {
        selectedCrypto = currencies[row]
    }
    
    func refreshPrice() {
        refreshHistoricalData()
        populatePriceTable()
    }
    
    func onMore() {
        coordinator?.more(currencies)
    }
    
    private func refreshHistoricalData() {
        database?.getHistorical(for: selectedCrypto.id!, in: "USD", interval: selectedInterval) { [weak self] (data) in
            self?.controller?.chart.data = data
            self?.controller?.loadingSpinner.stopAnimating()
        }
    }
    
    private func populatePriceTable() {
        for currency in currencies {
            if let id = currency.id {
                database?.getAsset(for: id, in: "USD") { (asset) in
                    guard let asset = asset else { return }
                    self.currencies.replaceFirst(element: currency, with: asset)
                }
            }
        }
        self.controller?.tableView.reloadData()
    }
}

protocol MainInteractable {
    // Implement
}

class MainInteractor: MainInteractable {
    // Implement
}
