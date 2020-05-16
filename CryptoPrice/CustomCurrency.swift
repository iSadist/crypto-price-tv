//
//  CustomCurrency.swift
//  CryptoPrice
//
//  Created by Jan Svensson on 2020-05-10.
//  Copyright © 2020 Jan Svensson. All rights reserved.
//

import Foundation

class CustomCurrency {
    static let shared = CustomCurrency()
    
    var currencies: [Currency] = [Currency(currency: "bitcoin", code: "BTC", price: nil)]
    var currency: String?
    var code: String?
    var price: String?
}

class Currency: Hashable {
    static func == (lhs: Currency, rhs: Currency) -> Bool {
        return lhs.code == rhs.code
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(currency)
        hasher.combine(code)
    }
    
    init(currency: String?, code: String?, price: String?) {
        self.currency = currency
        self.code = code
        self.price = price
    }
    
    var currency: String?
    var code: String?
    var price: String?
}
