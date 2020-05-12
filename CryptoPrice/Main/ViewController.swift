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

class ViewController: UIViewController, Storyboarded {
    var timer: Timer?
    var selectedCrypto: String = "bitcoin" {
        didSet {
            topTitle.text = selectedCrypto.capitalizingFirstLetter()
            updatePrice()
        }
    }
    var selectedInterval: String = "h1" {
        didSet {
            updatePrice()
        }
    }
    private var coordinator: MainScreenCoordinator?
    let dateFormatter = DateFormatter()
    var database: Database?

    @IBOutlet weak var topTitle: UILabel!
    @IBOutlet weak var chart: LineChartView!
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        coordinator = MainScreenCoordinator(navigationController: navigationController ?? UINavigationController())
        dateFormatter.dateFormat = "yyyy'-'MM'-'dd"
        database = Database(format: "yyyy'-'MM'-'dd")
        
        chart.xAxis.valueFormatter = self
        
        tableView.delegate = self
        tableView.dataSource = self
        
        topTitle.text = selectedCrypto
    }
    
    override func viewDidAppear(_ animated: Bool) {
        timer = Timer.scheduledTimer(timeInterval: 5, target: self, selector: #selector(updatePrice), userInfo: nil, repeats: true)
        timer?.fire()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        timer?.invalidate()
    }

    @IBAction func onMoreButtonPressed(_ sender: UIButton) {
        coordinator?.more()
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
        database?.getHistorical(for: selectedCrypto, in: "USD", interval: selectedInterval) { (data) in
            self.chart.data = data
        }
        
        for currency in CustomCurrency.shared.currencies {
            if let customCode = currency.currency {
                database?.getCurrentPrice(for: customCode.lowercased().replacingOccurrences(of: " ", with: "-"), in: "USD") { (rate) in
                    currency.price = rate
                    self.tableView.reloadData()
                }
            }
        }
    }
}

extension ViewController: IAxisValueFormatter {
    func stringForValue(_ value: Double, axis: AxisBase?) -> String {
        dateFormatter.string(from: Date(timeIntervalSince1970: value))
    }
}

extension ViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let currency = CustomCurrency.shared.currencies[indexPath.row]

        selectedCrypto = currency.currency!.lowercased().replacingOccurrences(of: " ", with: "-")
    }
}

extension ViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return CustomCurrency.shared.currencies.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "currencyCell", for: indexPath) as? CurrencyTableViewCell {
            
            let currency = CustomCurrency.shared.currencies[indexPath.row]
            cell.codeLabel.text = currency.code
            cell.priceLabel.text = currency.price
            return cell
        }

        return tableView.dequeueReusableCell(withIdentifier: "currencyCell", for: indexPath)
    }
}
