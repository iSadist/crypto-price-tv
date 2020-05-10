//
//  CurrencyViewController.swift
//  CryptoPrice
//
//  Created by Jan Svensson on 2020-05-10.
//  Copyright © 2020 Jan Svensson. All rights reserved.
//

import UIKit
import Alamofire

class CurrencyViewController: UICollectionViewController, UICollectionViewDelegateFlowLayout {
    var currencies = [(code: String, country: String)]()

    override func viewDidLoad() {
        super.viewDidLoad()

        getCurrencies()
    }
    
    private func getCurrencies() {
        AF.request(supportedCurrenciesURL).responseJSON { [weak self] (response) in
            
            switch response.result {
            case .success(let data):
                print("Success")
                if let array = data as? [Any] {
                    
                    for entry in array {
                        if let currency = entry as? [String: String] {
                            let code = currency["currency"]!
                            let country = currency["country"]!
                            let tuple = (code, country)
                            
                            self?.currencies.append(tuple)
                        }
                    }
                }
                
            case .failure(let error):
                print(error)
            }
            
            self?.collectionView.reloadData()
        }
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
            cell.label.text = currencies[indexPath.row].country
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
        
        CustomCurrency.shared.code = currency.code
        CustomCurrency.shared.currency = currency.country
        
        self.navigationController?.popViewController(animated: true)
    }
}
