//
//  UnlimitedPaywallViewModel.swift
//  CryptoPrice
//
//  Created by Jan Svensson on 2025-02-20.
//  Copyright © 2025 Jan Svensson. All rights reserved.
//

import Foundation
import UIKit
import RevenueCat

class UnlimitedPaywallViewModel {
    var leftTitle: String
    var centerTitle: String
    var rightTitle: String
    var leftDescription: String
    var centerDescription: String
    var rightDescription: String
    var leftButtonTitle: String
    var centerButtonTitle: String
    var rightButtonTitle: String

    init(leftTitle: String, centerTitle: String, rightTitle: String, leftDescription: String, centerDescription: String, rightDescription: String, leftButtonTitle: String, centerButtonTitle: String, rightButtonTitle: String) {
        self.leftTitle = leftTitle
        self.centerTitle = centerTitle
        self.rightTitle = rightTitle
        self.leftDescription = leftDescription
        self.centerDescription = centerDescription
        self.rightDescription = rightDescription
        self.leftButtonTitle = leftButtonTitle
        self.centerButtonTitle = centerButtonTitle
        self.rightButtonTitle = rightButtonTitle
    }

    init(products: [StoreProduct]) {
        guard products.count == 3 else {
            fatalError("There must be exactly 3 products")
        }

        let firstProduct = products[0]
        let secondProduct = products[1]
        let thirdProduct = products[2]

        leftTitle = firstProduct.localizedTitle
        leftDescription =
"""
\(firstProduct.localizedPriceString)
or
\(firstProduct.localizedPricePerMonth ?? "") / month
"""
        leftButtonTitle = "Subscribe"

        centerTitle = secondProduct.localizedTitle
        centerDescription =
"""
\(secondProduct.localizedPriceString)
or
\(secondProduct.localizedPricePerMonth ?? "") / month
"""
        centerButtonTitle = "Subscribe"

        rightTitle = thirdProduct.localizedTitle
        rightDescription =
"""
\(thirdProduct.localizedPriceString)
or
\(thirdProduct.localizedPricePerMonth ?? "") / month
"""
        rightButtonTitle = "Subscribe"
    }
}
