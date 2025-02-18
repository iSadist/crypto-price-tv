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
import RevenueCat

class MainViewController: UIViewController, Storyboarded {
    var timer: Timer?

    var presenter: MainPresentable?
    let dateFormatter = DateFormatter()

    @IBOutlet weak var topTitle: UILabel!
    @IBOutlet weak var chart: LineChartView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var loadingSpinner: UIActivityIndicatorView!
    @IBOutlet weak var rateButton: UIButton!
    
    // MARK: Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        // TODO: Should be set outside of this class
        let coordinator = MainScreenCoordinator(navigationController: navigationController ?? UINavigationController())
        let crypto = [CryptoCurrency(id: "bitcoin", symbol: "B", name: "Bitcoin")]
        presenter = MainPresenter(crypto, controller: self)
        presenter?.coordinator = coordinator
        presenter?.database = Database(format: "yyyy'-'MM'-'dd")
        
        dateFormatter.dateFormat = "yyyy'-'MM'-'dd"
        
        setupChart()

        tableView.delegate = self
        tableView.dataSource = self
        
        updatePrice()
        testRevenueCat()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        timer = Timer.scheduledTimer(timeInterval: 10, target: self, selector: #selector(updatePrice), userInfo: nil, repeats: true)
        timer?.fire()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        timer?.invalidate()
    }
    
    // MARK: Events

    @IBAction func onMoreButtonPressed(_ sender: UIButton) {
        presenter?.onMore()
    }

    @IBAction func onCurrencyButtonPressed(_ sender: UIButton) {
        presenter?.onCurrency()
    }
    
    @IBAction func onSelectedInterval(_ sender: UISegmentedControl) {
        let selectedIndex = sender.selectedSegmentIndex
        presenter?.onSelectedInterval(selectedIndex)
    }
    
    @objc private func updatePrice() {
        presenter?.refreshPrice()
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

    private func testRevenueCat() {
        // TODO: Check if the user has a valid subscription for Unlimited Currencies.
        // If not, remove all but the first three selected currencies.
        // Also, make sure to let users with the old purchases keep their functionality.

        Purchases.shared.getOfferings { offering, error in
            if let error = error {
                // TODO: Handle error
                print(error.localizedDescription)
            } else {
                print(offering?.current?.identifier ?? "No offering ID")
            }
        }

        Purchases.shared.getCustomerInfo { info, error in
            guard error == nil else {
                // TODO: Handle error
                return
            }

            guard let info = info else {
                print("No customer info")
                return
            }

            if info.entitlements[RevenueCat.entitlementID]?.isActive == true {
                print("User has valid subscription")
            } else {
                print("User has no valid subscription")
            }
        }
    }
}

// MARK: Chart Axis formatter
extension MainViewController: AxisValueFormatter {
    func stringForValue(_ value: Double, axis: AxisBase?) -> String {
        dateFormatter.string(from: Date(timeIntervalSince1970: value/1000))
    }
}

extension MainViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        presenter?.onSelectedCurrency(on: indexPath.row)
    }
}
