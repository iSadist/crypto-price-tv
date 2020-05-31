//
//  Urls.swift
//  CryptoPrice
//
//  Created by Jan Svensson on 2020-05-23.
//  Copyright © 2020 Jan Svensson. All rights reserved.
//

import Foundation

let currentPriceURL = URL(string: "https://api.coindesk.com/v1/bpi/currentprice.json")!
let supportedCurrenciesURL = URL(string: "https://api.coincap.io/v2/rates")!
let assetsUrl = URL(string: "https://api.coincap.io/v2/assets")!

func priceUrl(crypto: String) -> URL {
    return URL(string: "https://api.coincap.io/v2/assets/\(crypto)")!
}

func historicalUrl(crypto: String, interval: String) -> URL {
    return URL(string: "https://api.coincap.io/v2/assets/\(crypto)/history?interval=\(interval)")!
}

enum HistoricalInterval: String {
    case m15, h1, h6, h12, d1
}
