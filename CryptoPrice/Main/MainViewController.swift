//
//  ViewController.swift
//  CryptoPrice
//
//  Created by Jan Svensson on 2020-05-10.
//  Copyright © 2020 Jan Svensson. All rights reserved.
//

import UIKit
import Alamofire
import Charts

class MainViewController: UIViewController, Storyboarded {
    var timer: Timer?
    var currencies: [CryptoCurrency]?
    private var selectedCrypto: CryptoCurrency! {
        didSet {
            topTitle.text = selectedCrypto.name
            
            loadingSpinner.startAnimating()
            updatePrice()
        }
    }
    var selectedInterval: String = "h1" {
        didSet {
            loadingSpinner.startAnimating()
            updatePrice()
        }
    }
    private var coordinator: MainScreenCoordinator?
    let dateFormatter = DateFormatter()
    var database: Database?

    @IBOutlet weak var topTitle: UILabel!
    @IBOutlet weak var chart: LineChartView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var loadingSpinner: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        coordinator = MainScreenCoordinator(navigationController: navigationController ?? UINavigationController())
        dateFormatter.dateFormat = "yyyy'-'MM'-'dd"
        database = Database(format: "yyyy'-'MM'-'dd")
        
        chart.xAxis.valueFormatter = self
        
        tableView.delegate = self
        tableView.dataSource = self
        
        selectedCrypto = currencies?.first
        topTitle.text = selectedCrypto.name
        
        updatePrice()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        timer = Timer.scheduledTimer(timeInterval: 2, target: self, selector: #selector(updatePrice), userInfo: nil, repeats: true)
        timer?.fire()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        timer?.invalidate()
    }

    @IBAction func onMoreButtonPressed(_ sender: UIButton) {
        coordinator?.more(currencies ?? [])
    }

    @IBAction func onSelectedInterval(_ sender: UISegmentedControl) {
        let selectedIndex = sender.selectedSegmentIndex
        var interval = "h1"

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
    
    @objc private func updatePrice() {
        updateHistorical()
        updateSidebar()
    }
    
    private func updateHistorical() {
        database?.getHistorical(for: selectedCrypto.id!, in: "USD", interval: selectedInterval) { [weak self] (data) in
            self?.chart.data = data
            self?.loadingSpinner.stopAnimating()
        }
    }
    
    private func updateSidebar() {
        guard let currencies = currencies else { return }
        for currency in currencies {
            if let id = currency.id {
                database?.getAsset(for: id, in: "USD") { (asset) in
                    guard let asset = asset else { return }
                    self.currencies?.replaceFirst(element: currency, with: asset)
                }
            }
        }
        self.tableView.reloadData()
    }
}

extension MainViewController: IAxisValueFormatter {
    func stringForValue(_ value: Double, axis: AxisBase?) -> String {
        dateFormatter.string(from: Date(timeIntervalSince1970: value/1000))
    }
}

extension MainViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let currency = currencies?[indexPath.row] {
            selectedCrypto = currency
        }
    }
}

extension MainViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return currencies?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "currencyCell", for: indexPath)
        
        if let currencyCell = cell as? CurrencyTableViewCell {
            if let currency = currencies?[indexPath.row] {
                currencyCell.codeLabel.text = currency.name
                
                if let changePercent = currency.changePercent24Hr {
                    let change = (changePercent as NSString).doubleValue
                    let changeFormattedText = String(format: "%.2f", change)
                    currencyCell.percentageChangeLabel.text = "\(changeFormattedText)%"
                    currencyCell.percentageChangeLabel.textColor = change > 0 ? .systemGreen : .systemRed
                }
                
                if let priceUsd = currency.priceUsd {
                    let price = (priceUsd as NSString).doubleValue
                    let priceText = String(format: "%.4f", price)
                    currencyCell.priceLabel.text = "$\(priceText)"
                }

                return currencyCell
            }
        }

        return cell
    }
}
