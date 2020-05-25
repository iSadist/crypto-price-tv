//
//  CurrencyViewController.swift
//  CryptoPrice
//
//  Created by Jan Svensson on 2020-05-10.
//  Copyright © 2020 Jan Svensson. All rights reserved.
//

import UIKit
import Alamofire

class CurrencyViewController: UIViewController, UICollectionViewDelegateFlowLayout, UICollectionViewDataSource, UICollectionViewDelegate, Storyboarded {
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
    
    var selectedCurrencies: [CryptoCurrency]?
    var database: Database?
    
    private let selectedColor: UIColor = #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 0.1547920335)
    private let selectedTextColor: UIColor = .systemBlue

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
        
        database = Database(format: "yyyy'-'MM'-'dd")
        getCurrencies()
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
    
    func collectionView(_ collectionView: UICollectionView, canFocusItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        1
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return filtered.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "standardCell", for: indexPath) as? CollectionViewCell {
            let currency = filtered[indexPath.row]
            cell.label.text = currency.name
            cell.codeLabel.text = currency.symbol
            
            let isSelected = selectedCurrencies?.contains(currency) ?? false
            cell.checkmark.isHidden = !isSelected
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
                nextView.transform = CGAffineTransform(scaleX: 1.05, y: 1.05)
                if let collectionCell = nextView as? CollectionViewCell {
                    collectionCell.codeLabel.textColor = self.selectedTextColor
                    collectionCell.label.textColor = self.selectedTextColor
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
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let currency = filtered[indexPath.row]
        
        if selectedCurrencies?.contains(currency) ?? false {
            if selectedCurrencies?.count ?? 0 > 1,
                let index = selectedCurrencies?.firstIndex(of: currency) {
                selectedCurrencies?.remove(at: index)
            }
        } else {
            selectedCurrencies?.append(currency)
        }
        
        if let cell = collectionView.cellForItem(at: indexPath) as? CollectionViewCell {
            let isSelected = selectedCurrencies?.contains(currency) ?? false
            cell.checkmark.isHidden = !isSelected
        }
    }
}

extension CurrencyViewController: UITextFieldDelegate {
    func textFieldDidEndEditing(_ textField: UITextField) {
        collectionView.reloadData()
    }
}
