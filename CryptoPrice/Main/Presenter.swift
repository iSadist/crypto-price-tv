//
//  Presenter.swift
//  CryptoPrice
//
//  Created by Jan Svensson on 2020-05-29.
//  Copyright © 2020 Jan Svensson. All rights reserved.
//

import Foundation
import Charts
import class UIKit.UIColor

protocol MainPresentable: AnyObject {
    func onSelectedInterval(_ selectedIndex: Int)
    func onSelectedCurrency(on row: Int)
    func onMore()
    func onCurrency()
    func refreshPrice()
    
    var coordinator: MainScreenCoordinator? { get set }
    var database: Database? { get set }
    var controller: MainViewController? { get set }
    var currencies: [CryptoCurrency] { get set }
    var selectedCrypto: CryptoCurrency { get set }
    var selectedInterval: String { get }
    var selectedRate: Rate { get set }
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
            refreshHistoricalData()
        }
    }
    var selectedInterval: String = "h1" {
        didSet {
            controller?.loadingSpinner.startAnimating()
            refreshPrice()
        }
    }
    var selectedRate: Rate = Rate(id: "american-dollar", symbol: "USD", currencySymbol: "$", type: "fiat", rateUsd: "1.0") {
        didSet {
            controller?.rateButton.setTitle(selectedRate.symbol, for: .normal) // Default rate is USD
        }
    }
    
    init(_ currencies: [CryptoCurrency], controller: MainViewController) {
        self.currencies = currencies
        selectedCrypto = currencies.first ?? CryptoCurrency()
        self.controller = controller
        
        controller.topTitle.text = selectedCrypto.name
        controller.rateButton.setTitle(selectedRate.symbol, for: .normal)
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
    
    func onCurrency() {
        coordinator?.currency()
    }
    
    private func refreshHistoricalData() {
        DispatchQueue.global(qos: .background).async { [weak self] in
            guard let `self` = self else { return }
            self.database?.getHistorical(for: self.selectedCrypto.id!, in: "USD", interval: self.selectedInterval) { [weak self] (data) in
                guard let dataPoints = data?.map({ [weak self] (point) -> ChartDataEntry in
                    let rate = self?.selectedRate.rateUsd as NSString?
                    let doubleValue = rate?.doubleValue
                    return ChartDataEntry(x: point.x, y: point.y / (doubleValue ?? 1.0))
                }) else { self?.controller?.loadingSpinner.stopAnimating(); return }
                guard dataPoints.count > 100 else { self?.controller?.loadingSpinner.stopAnimating(); return }
                self?.updateChart(dataPoints: dataPoints)
            }
        }
    }

    private func updateChart(dataPoints: [ChartDataEntry]) {
        let nrbOfDataPoints = 200
        let nbrOfPointsToDrop = dataPoints.count > nrbOfDataPoints ? dataPoints.count - nrbOfDataPoints : 0
        
        let dataSlice = Array(dataPoints.dropFirst(nbrOfPointsToDrop))
        
        let line = LineChartDataSet(entries: dataSlice, label: "USD")
        line.drawCirclesEnabled = false
        line.mode = .linear

                line.fill = ColorFill(color: #colorLiteral(red: 0.1764705926, green: 0.4980392158, blue: 0.7568627596, alpha: 1))
        line.fillAlpha = 0.8
        line.drawFilledEnabled = true
        
        line.setColor(#colorLiteral(red: 0.2392156869, green: 0.6745098233, blue: 0.9686274529, alpha: 1))
        line.lineWidth = 2
        line.drawValuesEnabled = true

        let data = LineChartData(dataSets: [
            line,
            movingAverage(data: Array(dataPoints.dropFirst(nbrOfPointsToDrop - 51)), length: 50, color: .purple),
            movingAverage(data: Array(dataPoints.dropFirst(nbrOfPointsToDrop - 101)), length: 100, color: .orange)
        ])

        DispatchQueue.main.async {
            self.controller?.chart.data = data
            self.controller?.loadingSpinner.stopAnimating()
        }
    }
    
    private func movingAverage(data: [ChartDataEntry], length: Int, color: UIColor) -> LineChartDataSet {
        var movingAverageData = [ChartDataEntry]()
        
        for (index, dataPoint) in data.enumerated() {
            guard index > length else { continue }
            
            let slice = data[index - length...index - 1]
            let sum = slice.reduce(0) { (result, entry) -> Double in
                return entry.y + result
            }
            let average = sum / Double(length)
            movingAverageData.append(ChartDataEntry(x: dataPoint.x, y: average))
        }
        
        let line = LineChartDataSet(entries: movingAverageData, label: "MA \(length)")
        line.drawCirclesEnabled = false
        line.setColor(color)
        line.lineWidth = 1
        return line
    }
    
    private func populatePriceTable() {
        for currency in currencies {
            if let id = currency.id {
                DispatchQueue.global(qos: .background).async { [weak self] in
                    guard let `self` = self else { return }
                    self.database?.getAsset(for: id, in: "USD") { (asset) in
                        guard let asset = asset else { return }
                        self.currencies.replaceFirst(element: currency, with: asset)
                        
                        DispatchQueue.main.async {
                            self.controller?.tableView.reloadData()
                        }
                    }
                }
            }
        }
    }
}

protocol MainInteractable {
    // Implement
}

class MainInteractor: MainInteractable {
    // Implement
}
