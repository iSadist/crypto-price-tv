//
//  UnlimitedPaywallInteractor.swift
//  CryptoPrice
//
//  Created by Jan Svensson on 2025-02-20.
//  Copyright © 2025 Jan Svensson. All rights reserved.
//

import Foundation
import RevenueCat

protocol UnlimitedPaywallInteractorProtocol {
    func subscribeLeft()
    func subscribeCenter()
    func subscribeRight()
}

class UnlimitedPaywallInteractor: UnlimitedPaywallInteractorProtocol {

    private let leftProduct: StoreProduct

    private let centerProduct: StoreProduct

    private let rightProduct: StoreProduct

    init(products: [StoreProduct]) {
        guard products.count == 3 else {
            fatalError("There must be exactly 3 products")
        }

        self.leftProduct = products[0]
        self.centerProduct = products[1]
        self.rightProduct = products[2]
    }

    private func subscribe(_ product: StoreProduct) {
        Purchases.shared.purchase(product: leftProduct) { transaction, info, error, cancelled in
            if let error = error {
                print("Error purchasing: \(error.localizedDescription)")
            } else if cancelled {
                print("Purchase cancelled")
            } else {
                print("Purchased")
            }
        }
    }

    public func subscribeLeft() {
        subscribe(leftProduct)
    }

    public func subscribeCenter() {
        subscribe(centerProduct)
    }

    public func subscribeRight() {
        subscribe(rightProduct)
    }
}
