//
//  CurrencyCoordinator.swift
//  CryptoPrice
//
//  Created by Jan Svensson on 2020-05-11.
//  Copyright © 2020 Jan Svensson. All rights reserved.
//

import Foundation
import UIKit

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
}
