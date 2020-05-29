//
//  CurrencyViewController+Delegate.swift
//  CryptoPrice
//
//  Created by Jan Svensson on 2020-05-29.
//  Copyright © 2020 Jan Svensson. All rights reserved.
//

import UIKit

extension CurrencyViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 450, height: 350)
    }
}

extension CurrencyViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, canFocusItemAt indexPath: IndexPath) -> Bool {
        return true
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
