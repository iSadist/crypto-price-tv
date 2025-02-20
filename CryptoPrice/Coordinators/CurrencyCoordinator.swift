//
//  CurrencyCoordinator.swift
//  CryptoPrice
//
//  Created by Jan Svensson on 2020-05-11.
//  Copyright © 2020 Jan Svensson. All rights reserved.
//

import Foundation
import UIKit
import RevenueCat

class CurrencyCoordinator: JSVCoordinator {
    weak var navigationController: UINavigationController?
    
    required init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    func back(selectedCurrencies: [CryptoCurrency]) {
        if let mainVC = navigationController?.viewControllers.first as? MainViewController {
            mainVC.presenter?.currencies = selectedCurrencies
            navigationController?.popViewController(animated: true)
        }
    }
    
    /// Presents the UnlimitedPaywallViewController from Paywalls.storyboard as a modal view
    public func presentPaywall() {
        let storyboard = UIStoryboard(name: "Paywalls", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "UnlimitedPaywallViewController") as! UnlimitedPaywallViewController

        Purchases.shared.getProducts(RevenueCat.unlimitedProductIdentifiers) { products in
            let viewModel = UnlimitedPaywallViewModel(products: products)
            vc.viewModel = viewModel

            let interactor = UnlimitedPaywallInteractor(products: products)
            interactor.coordinator = PaywallCoordinator(navigationController: self.navigationController ?? UINavigationController())
            vc.interactor = interactor

            vc.modalPresentationStyle = .fullScreen

            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
}
