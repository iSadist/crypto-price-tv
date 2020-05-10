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
    var currency: String?
    var code: String?
}
