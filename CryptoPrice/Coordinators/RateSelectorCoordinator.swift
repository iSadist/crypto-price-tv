//
//  RateSelectorCoordinator.swift
//  CryptoPrice
//
//  Created by Jan Svensson on 2020-05-31.
//  Copyright © 2020 Jan Svensson. All rights reserved.
//

import UIKit

class RateSelectorCoordinator: JSVCoordinator {
    var navigationController: UINavigationController?
    
    required init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    func back(_ rate: Rate) {
        if let mainVC = navigationController?.viewControllers.first as? MainViewController {
            mainVC.presenter?.selectedRate = rate
            navigationController?.popViewController(animated: true)
        }
    }
}
