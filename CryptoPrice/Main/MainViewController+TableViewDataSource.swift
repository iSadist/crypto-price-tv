//
//  MainViewController+TableViewDataSource.swift
//  CryptoPrice
//
//  Created by Jan Svensson on 2020-05-29.
//  Copyright © 2020 Jan Svensson. All rights reserved.
//

import UIKit

extension MainViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return presenter?.currencies.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "currencyCell", for: indexPath)
        
        if let currencyCell = cell as? CurrencyTableViewCell {
            if let currency = presenter?.currencies[indexPath.row] {
                currencyCell.codeLabel.text = currency.name
                
                if let changePercent = currency.changePercent24Hr {
                    let change = (changePercent as NSString).doubleValue
                    let changeFormattedText = String(format: "%.2f", change)
                    currencyCell.percentageChangeLabel.text = "\(changeFormattedText)%"
                    currencyCell.percentageChangeLabel.textColor = change > 0 ? .systemGreen : .systemRed
                }
                
                if let priceUsd = currency.priceUsd {
                    let rate = presenter?.selectedRate.rateUsd as? NSString
                    let price = (priceUsd as NSString).doubleValue / (rate?.doubleValue ?? 1.0)
                    let priceText = String(format: "%.4f", price)
                    currencyCell.priceLabel.text = "\(presenter?.selectedRate.currencySymbol ?? "$")\(priceText)"
                }
            }
        }

        return cell
    }
}
