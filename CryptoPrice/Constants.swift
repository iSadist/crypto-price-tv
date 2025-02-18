//
//  Constants.swift
//  CryptoPrice
//
//  Created by Jan Svensson on 2020-05-10.
//  Copyright © 2020 Jan Svensson. All rights reserved.
//

import Foundation

extension String {
    func capitalizingFirstLetter() -> String {
        return prefix(1).capitalized + dropFirst()
    }

    mutating func capitalizeFirstLetter() {
        self = self.capitalizingFirstLetter()
    }
}

struct RevenueCat {

    static let apiKey = "appl_KQhkWTWuYvnZZXBhuxoKaQATGsD"

    static let entitlementID = "entl94c81b65af"

    static let unlimitedProductIdentifier = "se.nedralia.cryptotv.unlimited_currencies.monthly"

    static let unlimitedProductIdentifiers = [
        "se.nedralia.cryptotv.unlimited_currencies.monthly",
        "se.nedralia.cryptotv.unlimited_currencies.half_year",
        "se.nedralia.cryptotv.unlimited_currencies.annual"
    ]

    static let unlimitedOfferingID = "ofrng3c58a33892"
}
