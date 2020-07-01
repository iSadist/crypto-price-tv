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
}
