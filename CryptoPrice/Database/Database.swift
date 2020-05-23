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
    lazy private var decoder = JSONDecoder()
    let dateFormatter = DateFormatter()
    
    init(format: String) {
        dateFormatter.dateFormat = format
    }
    
    // https://api.coincap.io/v2/assets/ethereum/history?interval=h1
    internal func getHistorical(for crypto: String, in currency: String, interval: String, completionHandler: @escaping ((LineChartData?) -> ()) ) {
        var dataPoints: [ChartDataEntry] = []

        AF.request(historicalUrl(crypto: crypto, interval: interval)).response { [weak self] (response) in
            switch response.result {
            case .success(let data):
                
                if let data = data, let prices = try? self?.decoder.decode(Historical.self, from: data) {
                    for price in prices.data {
                        let nsPrice = price.priceUsd as NSString?
                        guard let time = price.time, let val = nsPrice?.doubleValue else { return }
                        let chartDataEntry = ChartDataEntry(x: Double(time), y: val)
                        dataPoints.append(chartDataEntry)
                    }
                }
                
                let line = LineChartDataSet(entries: dataPoints, label: "USD")
                line.drawCirclesEnabled = false
                line.mode = .cubicBezier
                line.drawValuesEnabled = true
                let data = LineChartData()
                data.addDataSet(line)
                completionHandler(data)
            case .failure(let error):
                print(error)
                completionHandler(nil)
            }
        }
    }

    internal func getAsset(for crypto: String, in currency: String, completionHandler: @escaping ((CryptoCurrency?) -> ())) {
        AF.request(priceUrl(crypto: crypto)).response { [weak self] (response) in
            switch response.result {
            case .success(let data):
                guard let data = data, let asset = try? self?.decoder.decode(Asset.self, from: data) else {
                    completionHandler(nil); return
                }
                completionHandler(asset.data)
            case .failure(let error):
                print(error)
                completionHandler(nil)
            }
        }
    }

    internal func getCryptocurrencies(completionHandler: @escaping (([CryptoCurrency]) -> ())) {
        var currencies = [CryptoCurrency]()

        AF.request(assetsUrl).response { [weak self] (response) in
            switch response.result {
            case .success(let data):
                if let data = data, let cryptocurrencies = try? self?.decoder.decode(Assets.self, from: data) {
                    currencies.append(contentsOf: cryptocurrencies.data)
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
