//
//  CurrencyViewController+.swift
//  CryptoPrice
//
//  Created by Jan Svensson on 2020-05-29.
//  Copyright © 2020 Jan Svensson. All rights reserved.
//

import UIKit

extension CurrencyViewController: UITextFieldDelegate {
    func textFieldDidEndEditing(_ textField: UITextField) {
        collectionView.reloadData()
    }
}
