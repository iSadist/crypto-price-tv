//
//  PaywallCoordinator.swift
//  CryptoPrice
//
//  Created by Jan Svensson on 2025-02-20.
//  Copyright © 2025 Jan Svensson. All rights reserved.
//

import Foundation
import UIKit

class PaywallCoordinator: JSVCoordinator {
    var navigationController: UINavigationController?

    required init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }

    func back() {
        navigationController?.popViewController(animated: true)
    }

    func presentError(_ message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        navigationController?.present(alert, animated: true, completion: nil)
    }
}
