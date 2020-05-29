//
//  CurrencyViewController+DataSource.swift
//  CryptoPrice
//
//  Created by Jan Svensson on 2020-05-29.
//  Copyright © 2020 Jan Svensson. All rights reserved.
//

import UIKit

extension CurrencyViewController: UICollectionViewDataSource {    
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
}
