//
//  ViewController.swift
//  CryptoPrice
//
//  Created by Jan Svensson on 2020-05-10.
//  Copyright © 2020 Jan Svensson. All rights reserved.
//

import UIKit
import Alamofire

class ViewController: UIViewController, Storyboarded {
    var timer: Timer?
    private var coordinator: MainScreenCoordinator?

    @IBOutlet weak var usdPriceLabel: UILabel!
    @IBOutlet weak var eurPriceLabel: UILabel!
    @IBOutlet weak var gbpPriceLabel: UILabel!
    @IBOutlet weak var customCodeLabel: UILabel!
    @IBOutlet weak var customPriceLabel: UILabel!
    
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
    
    private func getLabel(for code: String) -> UILabel {
        switch code {
        case "USD": return usdPriceLabel
        case "EUR": return eurPriceLabel
        case "GBP": return gbpPriceLabel
        default:
            return UILabel()
        }
    }
    
    @objc private func updatePrice() {
        AF.request(currentPriceURL, method: .get).responseJSON { response in
            switch response.result {
            case .success(let data):
                if let json = data as? [String: Any] {
                    if let bpi = json["bpi"] as? [String: Any] {
                        for currency in bpi {
                            if let currencyInfo = bpi[currency.key] as? [String: Any] {
                                let rate = currencyInfo["rate"] as! String
                                let currencyLabel = self.getLabel(for: currency.key)
                                currencyLabel.text = rate
                            }
                        }
                    }
                }
                
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

