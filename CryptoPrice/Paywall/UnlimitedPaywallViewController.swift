//
//  UnlimitedPaywallViewController.swift
//  CryptoPrice
//
//  Created by Jan Svensson on 2025-02-18.
//  Copyright © 2025 Jan Svensson. All rights reserved.
//

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

class UnlimitedPaywallViewController: UIViewController {

    /// The view model
    public var viewModel: UnlimitedPaywallViewModel?

    @IBOutlet weak var leftTitleLabel: UILabel!
    @IBOutlet weak var centerTitleLabel: UILabel!
    @IBOutlet weak var rightTitleLabel: UILabel!
    @IBOutlet weak var leftDescriptionLabel: UILabel!
    @IBOutlet weak var centerDescriptionLabel: UILabel!
    @IBOutlet weak var rightDescriptionLabel: UILabel!
    @IBOutlet weak var leftButton: UIButton!
    @IBOutlet weak var centerButton: UIButton!
    @IBOutlet weak var rightButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()

        if let viewModel = self.viewModel {
            setupView(from: viewModel)
        }
    }

    private func setupView(from viewModel: UnlimitedPaywallViewModel) {
        leftTitleLabel.text = viewModel.leftTitle
        leftDescriptionLabel.text = viewModel.leftDescription
        leftButton.setTitle(viewModel.leftButtonTitle, for: .normal)

        rightTitleLabel.text = viewModel.rightTitle
        rightDescriptionLabel.text = viewModel.rightDescription
        rightButton.setTitle(viewModel.rightButtonTitle, for: .normal)

        centerTitleLabel.text = viewModel.centerTitle
        centerDescriptionLabel.text = viewModel.centerDescription
        centerButton.setTitle(viewModel.centerButtonTitle, for: .normal)
    }

    @IBAction func leftButtonAction(_ sender: UIButton) {
    }

    @IBAction func centerButtonAction(_ sender: UIButton) {
    }

    @IBAction func rightButtonAction(_ sender: UIButton) {
    }
}
