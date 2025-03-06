//
//  UserDefaults+extensions.swift
//  CryptoPrice
//
//  Created by Jan Svensson on 2020-07-01.
//  Copyright © 2020 Jan Svensson. All rights reserved.
//

import Foundation

extension UserDefaults {
    var unlimitedCurrencies: Bool {
        get {
            bool(forKey: "unlimited_currencies")
        }
        set {
            set(newValue, forKey: "unlimited_currencies")
        }
    }

    var selectedCurrencies: StoredCryptoCurrencies {
        get {
            let decoder = JSONDecoder()
            if let storedData = data(forKey: "selectedCurrencies") {
                let result = try? decoder.decode(StoredCryptoCurrencies.self, from: storedData)
                return result ?? StoredCryptoCurrencies(values: [])
            }

            return StoredCryptoCurrencies(values: [])
        }
        set {
            let encoder = JSONEncoder()
            let data = try? encoder.encode(newValue)
            set(data, forKey: "selectedCurrencies")
        }
    }
}
