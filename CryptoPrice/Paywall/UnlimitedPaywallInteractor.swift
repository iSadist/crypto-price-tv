//
//  UnlimitedPaywallInteractor.swift
//  CryptoPrice
//
//  Created by Jan Svensson on 2025-02-20.
//  Copyright © 2025 Jan Svensson. All rights reserved.
//

import UIKit
import RevenueCat

protocol UnlimitedPaywallInteractorProtocol {
    var coordinator: PaywallCoordinator? { get set }
    func subscribeLeft()
    func subscribeCenter()
    func subscribeRight()
}

class UnlimitedPaywallInteractor: UnlimitedPaywallInteractorProtocol {

    var coordinator: PaywallCoordinator?

    private let leftProduct: StoreProduct?
    private let centerProduct: StoreProduct?
    private let rightProduct: StoreProduct?

    init(products: [StoreProduct]) {
        guard products.count == 3 else {
            self.leftProduct = nil
            self.centerProduct = nil
            self.rightProduct = nil
            return
        }

        self.leftProduct = products[0]
        self.centerProduct = products[1]
        self.rightProduct = products[2]
    }

    private func subscribe(_ product: StoreProduct?) {
        guard let product = product else { return }

        Purchases.shared.purchase(product: product) { transaction, info, error, cancelled in
            if let error = error {
                self.presentError("Error purchasing: \(error.localizedDescription)")
            } else if cancelled {
                self.presentError("Purchase cancelled")
            } else {
                self.purchaseSuccessful()
            }
        }
    }

    private func presentError(_ message: String) {
        coordinator?.presentError(message)
    }

    private func purchaseSuccessful() {
        coordinator?.back()
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
