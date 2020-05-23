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
    var currencies = [CryptoCurrency]()
    var selectedCurrencies: [CryptoCurrency]?
    var database: Database?
    
    private let selectedColor: UIColor = #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 0.5)

    override func viewDidLoad() {
        super.viewDidLoad()
        database = Database(format: "yyyy'-'MM'-'dd")
        getCurrencies()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        let menuGesture = UITapGestureRecognizer()
        menuGesture.allowedPressTypes = [NSNumber( value: UIPress.PressType.menu.rawValue)]
        menuGesture.addTarget(self, action: #selector(CurrencyViewController.menuPressed(recognizer:)))
        view.addGestureRecognizer(menuGesture)
    }
    
    @objc func menuPressed(recognizer: UITapGestureRecognizer) {
        coordinator?.back(selectedCurrencies: selectedCurrencies ?? [])
    }
    
    private func getCurrencies() {
        database?.getCryptocurrencies(completionHandler: { [weak self] (assets) in
            self?.currencies = assets
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
            let currency = currencies[indexPath.row]
            cell.label.text = currency.name
            cell.codeLabel.text = currency.symbol

            
            cell.backgroundColor = selectedCurrencies?.contains(currency) ?? false ? selectedColor : UIColor.clear
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
            if selectedCurrencies?.count ?? 0 > 1,
                let index = selectedCurrencies?.firstIndex(of: currency) {
                selectedCurrencies?.remove(at: index)
            }
        } else {
            selectedCurrencies?.append(currency)
        }
        
        if let cell = collectionView.cellForItem(at: indexPath) as? CollectionViewCell {
            cell.backgroundColor = selectedCurrencies?.contains(currency) ?? false ? selectedColor : UIColor.clear
        }
    }
}
