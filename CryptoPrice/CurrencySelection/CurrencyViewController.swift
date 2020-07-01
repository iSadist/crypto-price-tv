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

fileprivate let selectedColor: UIColor = #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 0.1547920335)
fileprivate let selectedTextColor: UIColor = .systemBlue
fileprivate let unlimitedCurrenciesIdentifier = "unlimited_currencies"
fileprivate let iapIdentifiers = ["unlimited_currencies"]

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

    @IBOutlet weak var searchField: UITextField!
    @IBOutlet weak var collectionView: UICollectionView!

    override func viewDidLoad() {
        super.viewDidLoad()
        
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
        
        #if true
        UserDefaults.standard.unlimitedCurrencies = true
        #endif
        
        database = Database(format: "yyyy'-'MM'-'dd")
        getCurrencies()
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
    
    func append(_ crypto: CryptoCurrency) {
        if selectedCurrencies.count >= 3 && !UserDefaults.standard.unlimitedCurrencies {
            let alertController = UIAlertController(title: "Hello", message: "Limited to three cryptos", preferredStyle: .alert)
            let okAction = UIAlertAction(title: "OK", style: .cancel) { (action) in
                alertController.dismiss(animated: true, completion: nil)
            }
            alertController.addAction(okAction)
            
            if IAPClient.canMakePayments() {
                let unlockAction = UIAlertAction(title: "Unlock unlimited", style: .default) { [weak self] (action) in
                    guard let product = self?.availableProducts.first else { return }
                    self?.IAPClient.purchase(product: product)
                }
                alertController.addAction(unlockAction)
            }
            
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
    func prodsCallback(_ prods: [SKProduct]) {
        availableProducts = prods
    }
    
    func paymentCallback(_ prods: [SKProduct], error: Error?) {
        if let error = error {
            let alertController = UIAlertController(title: "Something went wrong", message: error.localizedDescription, preferredStyle: .alert)
            let dismissAction = UIAlertAction(title: "Dismiss", style: .cancel) { (action) in
                alertController.dismiss(animated: true, completion: nil)
            }
            alertController.addAction(dismissAction)
            present(alertController, animated: true, completion: nil)
        }
        
        if prods.contains(where: { $0.productIdentifier == unlimitedCurrenciesIdentifier }) {
            UserDefaults.standard.unlimitedCurrencies = true
        }
    }
}
