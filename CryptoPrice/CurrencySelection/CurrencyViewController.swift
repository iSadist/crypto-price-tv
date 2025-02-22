//
//  CurrencyViewController.swift
//  CryptoPrice
//
//  Created by Jan Svensson on 2020-05-10.
//  Copyright © 2020 Jan Svensson. All rights reserved.
//

import UIKit
import Alamofire
import StoreKit
import RevenueCat

fileprivate let selectedColor: UIColor = #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 0.1547920335)
fileprivate let selectedTextColor: UIColor = .systemBlue
fileprivate let unlimitedCurrenciesIdentifier = "com.jansvenssoncv.cryptochartstv.unlimited"
fileprivate let iapIdentifiers = ["com.jansvenssoncv.cryptochartstv.unlimited"]

protocol ErrorPresentable {
    func presentError(error: Error?)
}

protocol Promptable {
    func prompt(_ message: String)
}

class CurrencyViewController: UIViewController, Storyboarded {
    var coordinator: CurrencyCoordinator?
    var currencies = [CryptoCurrency]()
    
    var filtered: [CryptoCurrency] {
        get {
            guard let searchText = searchField.text else { return currencies }
            guard searchText != "" else { return currencies }
            return currencies.filter { ($0.name?.lowercased().contains(searchText.lowercased()) ?? false) ||
                ($0.id?.lowercased().contains(searchText.lowercased()) ?? false) ||
                ($0.symbol?.lowercased().contains(searchText.lowercased()) ?? false)
            }
        }
    }
    
    var selectedCurrencies: [CryptoCurrency]!
    var database: Database?
    private var IAPClient = InAppPurchaseClient()
    private var availableProducts: [SKProduct] = []
    private var isSubscribed = false

    @IBOutlet weak var premiumButton: UIButton!
    @IBOutlet weak var restoreButton: UIButton!
    @IBOutlet weak var searchField: UITextField!
    @IBOutlet weak var collectionView: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let focusGuideLeft = UIFocusGuide()
        let focusGuideRight = UIFocusGuide()
        view.addLayoutGuide(focusGuideLeft)
        view.addLayoutGuide(focusGuideRight)

        premiumButton.isEnabled = !UserDefaults.standard.unlimitedCurrencies
        restoreButton.isEnabled = !UserDefaults.standard.unlimitedCurrencies

        focusGuideLeft.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        focusGuideLeft.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        focusGuideLeft.rightAnchor.constraint(equalTo: searchField.leftAnchor).isActive = true
        focusGuideLeft.bottomAnchor.constraint(equalTo: searchField.bottomAnchor).isActive = true

        focusGuideRight.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        focusGuideRight.leftAnchor.constraint(equalTo: searchField.rightAnchor).isActive = true
        focusGuideRight.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        focusGuideRight.bottomAnchor.constraint(equalTo: searchField.bottomAnchor).isActive = true

        focusGuideLeft.preferredFocusEnvironments = [searchField]
        focusGuideRight.preferredFocusEnvironments = [searchField]

        let menuGesture = UITapGestureRecognizer()
        menuGesture.allowedPressTypes = [NSNumber( value: UIPress.PressType.menu.rawValue)]
        menuGesture.addTarget(self, action: #selector(CurrencyViewController.menuPressed(recognizer:)))
        view.addGestureRecognizer(menuGesture)

        collectionView.dataSource = self
        collectionView.delegate = self
        searchField.delegate = self

        IAPClient.productsCallback = prodsCallback(_:)
        IAPClient.paymentCallback = paymentCallback(_:error:)
        IAPClient.fetchProducts(identifiers: iapIdentifiers)
        IAPClient.restoreCallback = restorePurchaseCallback(_:)

        database = Database(format: "yyyy'-'MM'-'dd")
        getCurrencies()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        Task {
            self.isSubscribed = await checkUserSubscription()
        }
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        IAPClient.productsCallback = nil
        IAPClient.paymentCallback = nil
    }

    @IBAction func didPressPremium(_ sender: UIButton) {
        coordinator?.presentPaywall()
    }

    @IBAction func didPressRestore(_ sender: UIButton) {
        IAPClient.restorePurchase()
        Purchases.shared.restorePurchases() // Should probably not need to do this for RenevueCat
    }

    @objc func menuPressed(recognizer: UITapGestureRecognizer) {
        coordinator?.back(selectedCurrencies: selectedCurrencies)
    }
    
    private func getCurrencies() {
        database?.getCryptocurrencies(completionHandler: { [weak self] (assets) in
            self?.currencies = assets
            self?.collectionView.reloadData()
        })
    }

    /// Checks whether the user has a valid subscription.
    /// It is valid either if the user has previously bought the lifetime deal,
    /// or a current RevenueCat subscription exists.
    ///
    /// - Returns: True if user is subscribed
    private func checkUserSubscription() async -> Bool {
        let result = await withCheckedContinuation { continuation in
            Purchases.shared.getCustomerInfo(fetchPolicy: .fetchCurrent) { info, error in
                let unlimited = info?.entitlements[RevenueCat.entitlementID]?.isActive == true
                continuation.resume(returning: unlimited)
            }
        }

        return result || UserDefaults.standard.unlimitedCurrencies
    }

    /// Appends a crypto to the selected list
    /// - Parameter crypto: The crypto to add
    func append(_ crypto: CryptoCurrency) async {
        if selectedCurrencies.count >= 3 && !isSubscribed {
            coordinator?.presentPaywall()
            return
        } else if selectedCurrencies.count >= 20 {
            let alertController = UIAlertController(title: "Max limit reached", message: "A maximim of 20 crypto currencies can be selected at one time.", preferredStyle: .alert)
            let okAction = UIAlertAction(title: "Dismiss", style: .cancel) { (action) in
                alertController.dismiss(animated: true, completion: nil)
            }
            alertController.addAction(okAction)
            present(alertController, animated: true, completion: nil)
            return
        }

        selectedCurrencies.append(crypto)
    }
    
    func remove(_ crypto: CryptoCurrency) {
        if selectedCurrencies.count > 1,
            let index = selectedCurrencies.firstIndex(of: crypto) {
            selectedCurrencies.remove(at: index)
        }
    }
    
    override func didUpdateFocus(in context: UIFocusUpdateContext, with coordinator: UIFocusAnimationCoordinator) {
        super.didUpdateFocus(in: context, with: coordinator)
        if let nextView = context.nextFocusedView {
            UIView.animate(withDuration: 0.25) {
                nextView.transform = CGAffineTransform(scaleX: 1.05, y: 1.05)
                if let collectionCell = nextView as? CollectionViewCell {
                    collectionCell.codeLabel.textColor = selectedTextColor
                    collectionCell.label.textColor = selectedTextColor
                }
            }
        }

        if let previousView = context.previouslyFocusedView {
            UIView.animate(withDuration: 0.25) {
                previousView.transform = CGAffineTransform(scaleX: 1, y: 1)
                if let collectionCell = previousView as? CollectionViewCell {
                    collectionCell.codeLabel.textColor = .label
                    collectionCell.label.textColor = .label
                }
            }
        }
    }
}

extension CurrencyViewController {
    func restorePurchaseCallback(_ success: Bool) {
        if success {
            prompt("Your purchase has been restored")
        } else {
            prompt("Could not restore purchase")
        }
    }

    func prodsCallback(_ prods: [SKProduct]) {
        availableProducts = prods
    }
    
    func paymentCallback(_ prods: [SKProduct], error: Error?) {
        if let error = error {
            presentError(error: error)
        }

        if prods.contains(where: { $0.productIdentifier == unlimitedCurrenciesIdentifier }) {
            UserDefaults.standard.unlimitedCurrencies = true
        }
    }
}

extension CurrencyViewController: ErrorPresentable {
    func presentError(error: Error?) {
        let errorMessage = error?.localizedDescription ?? "Unknown error"
        let alertController = UIAlertController(title: "Something went wrong", message: errorMessage, preferredStyle: .alert)
        let dismissAction = UIAlertAction(title: "Dismiss", style: .cancel) { (action) in
            alertController.dismiss(animated: true, completion: nil)
        }
        alertController.addAction(dismissAction)
        present(alertController, animated: true, completion: nil)
    }
}

extension CurrencyViewController: Promptable {
    func prompt(_ message: String) {
        let alertController = UIAlertController(title: "Message", message: message, preferredStyle: .alert)
        let dismissAction = UIAlertAction(title: "Dismiss", style: .cancel) { (action) in
            alertController.dismiss(animated: true, completion: nil)
        }
        alertController.addAction(dismissAction)
        present(alertController, animated: true, completion: nil)
    }
}
