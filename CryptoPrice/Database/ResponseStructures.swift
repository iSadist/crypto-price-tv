//
//  ResponseStructures.swift
//  CryptoPrice
//
//  Created by Jan Svensson on 2020-05-23.
//  Copyright © 2020 Jan Svensson. All rights reserved.
//

import Foundation

struct Historical: Codable {
    var data: [Price]
    var timestamp: Int
}

struct Price: Codable {
    var priceUsd: String?
    var time: Double?
    var circulatingSupply: String?
    var date: String?
}

struct Assets: Codable {
    var data: [CryptoCurrency]
    var timestamp: Int
}

struct Asset: Codable {
    var data: CryptoCurrency
    var timestamp: Int
}

struct CryptoCurrency: Codable {
    var id: String?
    var rank: String?
    var symbol: String?
    var name: String?
    var supply: String?
    var maxSupply: String?
    var marketCapUsd: String?
    var volumeUsd24Hr: String?
    var priceUsd: String?
    var changePercent24Hr: String?
    var vwap24Hr: String?
}
