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
    
    // MARK: Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        coordinator = MainScreenCoordinator(navigationController: navigationController ?? UINavigationController())
        dateFormatter.dateFormat = "yyyy'-'MM'-'dd"
        database = Database(format: "yyyy'-'MM'-'dd")
        
        setupChart()

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
    
    // MARK: Events

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
    
    private func setupChart() {
        chart.xAxis.valueFormatter = self
        chart.leftAxis.enabled = false
        chart.xAxis.labelPosition = .bottom
        chart.xAxis.forceLabelsEnabled = true
        chart.xAxis.labelTextColor = .label
        chart.xAxis.labelFont = .boldSystemFont(ofSize: 10)

        let yAxis = chart.rightAxis
        yAxis.setLabelCount(6, force: false)
        yAxis.labelFont = .boldSystemFont(ofSize: 12)
        yAxis.labelTextColor = .label
        yAxis.labelPosition = .outsideChart
        yAxis.forceLabelsEnabled = true
        
        chart.backgroundColor = .clear
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

// MARK: Chart Axis formatter
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
