//
//  MainScreenCoordinator.swift
//  CryptoPrice
//
//  Created by Jan Svensson on 2020-05-11.
//  Copyright © 2020 Jan Svensson. All rights reserved.
//

import Foundation
import UIKit

class MainScreenCoordinator: JSVCoordinator {
    var navigationController: UINavigationController?
    
    required init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    func more(_ selectedCurrencies: [Currency]) {
        let vc = CurrencyViewController.instantiate()
        vc.selectedCurrencies = selectedCurrencies
        vc.coordinator = CurrencyCoordinator(navigationController: navigationController ?? UINavigationController())
        navigationController?.pushViewController(vc, animated: true)
    }
}
