//
//  CurrencyViewController.swift
//  CryptoPrice
//
//  Created by Jan Svensson on 2020-05-10.
//  Copyright © 2020 Jan Svensson. All rights reserved.
//

import UIKit
import Alamofire

class CurrencyViewController: UICollectionViewController, UICollectionViewDelegateFlowLayout, Storyboarded {
    var coordinator: CurrencyCoordinator?
    var currencies = [Currency]()
    var selectedCurrencies: [Currency]?
    var database: Database?

    override func viewDidLoad() {
        super.viewDidLoad()
        database = Database(format: "yyyy'-'MM'-'dd")
        getCurrencies()
    }
    
    private func getCurrencies() {
        database?.getCryptocurrencies(completionHandler: { [weak self] (rates) in
            self?.currencies = rates.map { (tuple) -> Currency in
                return Currency(currency: tuple.1, code: tuple.0, price: nil)
            }
            self?.collectionView.reloadData()
        })
    }
    
    override func collectionView(_ collectionView: UICollectionView, canFocusItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        1
    }

    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return currencies.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "standardCell", for: indexPath) as? CollectionViewCell {
            cell.label.text = currencies[indexPath.row].currency
            cell.codeLabel.text = currencies[indexPath.row].code
            return cell
        }
        
        return collectionView.dequeueReusableCell(withReuseIdentifier: "standardCell", for: indexPath)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 450, height: 350)
    }
    
    override func didUpdateFocus(in context: UIFocusUpdateContext, with coordinator: UIFocusAnimationCoordinator) {
        if let nextView = context.nextFocusedView {
            UIView.animate(withDuration: 0.25) {
                nextView.transform = CGAffineTransform(scaleX: 1.1, y: 1.1)
            }
        }
        
        if let previousView = context.previouslyFocusedView {
            UIView.animate(withDuration: 0.25) {
                previousView.transform = CGAffineTransform(scaleX: 1, y: 1)
            }
        }
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let currency = currencies[indexPath.row]
        
        if selectedCurrencies?.contains(currency) ?? false {
            if let index = selectedCurrencies?.firstIndex(of: currency) {
                selectedCurrencies?.remove(at: index)                
            }
        } else {
            selectedCurrencies?.append(Currency(currency: currency.currency, code: currency.code, price: nil))
        }
        
        coordinator?.back(selectedCurrencies: selectedCurrencies ?? [])
    }
}
