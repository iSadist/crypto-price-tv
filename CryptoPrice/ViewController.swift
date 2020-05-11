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
    private var coordinator: MainScreenCoordinator?

    @IBOutlet weak var customCodeLabel: UILabel!
    @IBOutlet weak var customPriceLabel: UILabel!
    @IBOutlet weak var chart: LineChartView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        coordinator = MainScreenCoordinator(navigationController: navigationController ?? UINavigationController())
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
    
    @objc private func updatePrice() {
        var dataPoints: [ChartDataEntry] = []
        
        AF.request("https://api.coindesk.com/v1/bpi/historical/close.json").responseJSON { [weak self] (response) in
            switch response.result {
            case .success(let data):
                if let json = data as? [String: Any] {
                    if let bpi = json["bpi"] as? [String: Double] {
                        let sortedBPI = bpi.sorted { (previous, current) -> Bool in
                            let dateFormatter = DateFormatter()
                            dateFormatter.dateFormat = "yyyy'-'MM'-'dd"
                            let previousDate = dateFormatter.date(from: previous.key)!
                            let currentDate = dateFormatter.date(from: current.key)!
                            return previousDate < currentDate
                        }
                        
                        for (index, price) in sortedBPI.enumerated() {
                            print(index, price.key)
                            let chartDataEntry = ChartDataEntry(x: Double(index), y: price.value)
                            dataPoints.append(chartDataEntry)
                        }
                    }
                }
                
                let line = LineChartDataSet(entries: dataPoints, label: "Price")
                let data = LineChartData()
                data.addDataSet(line)
                self?.chart.data = data
            case .failure(let error):
                print(error)
            }
        }

        if let customCode = CustomCurrency.shared.code {
            customPriceLabel.isHidden = false
            customCodeLabel.isHidden = false
            customCodeLabel.text = CustomCurrency.shared.currency

            AF.request("https://api.coindesk.com/v1/bpi/currentprice/\(customCode).json").responseJSON { (response) in
                switch response.result {
                case .success(let data):
                    if let json = data as? [String: Any] {
                        if let bpi = json["bpi"] as? [String: Any] {
                            if let currencyInfo = bpi[customCode] as? [String: Any] {
                                let rate = currencyInfo["rate"] as! String
                                self.customPriceLabel.text = rate
                            }
                        }
                    }
                case .failure(let error):
                    print(error)
                }
            }
        } else {
            customPriceLabel.isHidden = true
            customCodeLabel.isHidden = true
        }
    }
}

