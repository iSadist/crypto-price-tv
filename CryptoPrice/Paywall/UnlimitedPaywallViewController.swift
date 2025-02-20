//
//  UnlimitedPaywallViewController.swift
//  CryptoPrice
//
//  Created by Jan Svensson on 2025-02-18.
//  Copyright © 2025 Jan Svensson. All rights reserved.
//

import UIKit
import RevenueCat

class UnlimitedPaywallViewController: UIViewController {

    /// The view model
    public var viewModel: UnlimitedPaywallViewModel?

    /// The interactor
    public var interactor: UnlimitedPaywallInteractorProtocol?

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
        interactor?.subscribeLeft()
    }

    @IBAction func centerButtonAction(_ sender: UIButton) {
        interactor?.subscribeCenter()
    }

    @IBAction func rightButtonAction(_ sender: UIButton) {
        interactor?.subscribeRight()
    }
}
