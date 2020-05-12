//
//  Database.swift
//  CryptoPrice
//
//  Created by Jan Svensson on 2020-05-12.
//  Copyright © 2020 Jan Svensson. All rights reserved.
//

import Foundation
import Alamofire
import Charts

class Database {
    let dateFormatter = DateFormatter()
    
    init(format: String) {
        dateFormatter.dateFormat = format
    }
    
    // https://api.coincap.io/v2/assets/ethereum/history?interval=h1
    internal func getHistorical(for crypto: String, in currency: String, interval: String, completionHandler: @escaping ((LineChartData?) -> ()) ) {
        var dataPoints: [ChartDataEntry] = []

        AF.request("https://api.coincap.io/v2/assets/\(crypto)/history?interval=\(interval)").responseJSON { (response) in
            switch response.result {
            case .success(let data):
                if let json = data as? [String: Any] {
                    if let prices = json["data"] as? [Any] {
                        for priceObj in prices {
                            if let dict = priceObj as? [String: Any] {
                                let time = dict["time"] as! Double
                                let price = dict["priceUsd"] as! NSString
                                let chartDataEntry = ChartDataEntry(x: time, y: price.doubleValue)
                                dataPoints.append(chartDataEntry)
                            }
                            
                        }
                    }
                }
                
                let line = LineChartDataSet(entries: dataPoints, label: "USD")
                let data = LineChartData()
                data.addDataSet(line)
                completionHandler(data)
            case .failure(let error):
                print(error)
                completionHandler(nil)
            }
        }
    }

    internal func getCurrentPrice(for crypto: String, in currency: String, completionHandler: @escaping ((String?) -> ())) {
        AF.request("https://api.coincap.io/v2/assets/\(crypto)").responseJSON { (response) in
            var rate: String?
            
            switch response.result {
            case .success(let data):
                if let json = data as? [String: Any] {
                    if let asset = json["data"] as? [String: Any] {
                        rate = asset["priceUsd"] as? String
                    }
                }
                
                completionHandler(rate)
            case .failure(let error):
                print(error)
                completionHandler(nil)
            }
        }
    }

    internal func getCryptocurrencies(completionHandler: @escaping (([(String, String)]) -> ())) {
        var currencies = [(code: String, country: String)]()
        
        let url = URL(string: "https://api.coincap.io/v2/assets")!
        
        AF.request(url).responseJSON { (response) in
            switch response.result {
            case .success(let data):
                if let json = data as? [String: Any] {
                    if let cryptos = json["data"] as? [Any] {
                        for crypto in cryptos {
                            if let currency = crypto as? [String: Any] {
                                let code = currency["symbol"] as! String
                                let name = currency["name"] as! String
                                let tuple = (code, name)
                                currencies.append(tuple)
                            }
                        }
                    }
                }
            case .failure(let error):
                print(error)
            }
            
            completionHandler(currencies)
        }
    }
    
    // https://api.coincap.io/v2/rates
    internal func getRates(completionHandler: @escaping (([(String, String)]) -> ())) {
        var currencies = [(code: String, country: String)]()
        
        AF.request(supportedCurrenciesURL).responseJSON { (response) in
            switch response.result {
            case .success(let data):
                if let array = data as? [Any] {
                    
                    for entry in array {
                        if let currency = entry as? [String: String] {
                            let code = currency["currency"]!
                            let country = currency["country"]!
                            let tuple = (code, country)
                            currencies.append(tuple)
                        }
                    }
                }
                
            case .failure(let error):
                print(error)
            }
            
            completionHandler(currencies)
        }
    }
}
