//
//  CollectionViewController.swift
//  CryptoPrice
//
//  Created by Jan Svensson on 2020-05-30.
//  Copyright © 2020 Jan Svensson. All rights reserved.
//

import UIKit

private let reuseIdentifier = "RateCell"

fileprivate let selectedColor: UIColor = #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 0.1547920335)
fileprivate let selectedTextColor: UIColor = .systemBlue


class CurrencyCollectionViewController: UICollectionViewController, Storyboarded {
    var database: Database?
    var coordinator: RateSelectorCoordinator?
    var visibleRates: [Rate]! = []
    var rates: [Rate]! = []
    
    fileprivate var previousSearchText: String?

    override func viewDidLoad() {
        super.viewDidLoad()
        self.clearsSelectionOnViewWillAppear = false
        database = Database(format: "yyyy'-'MM'-'dd")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        database?.getRates(completionHandler: { [weak self] (rates) in
            guard let `self` = self else { return }
            
            if let fiatRates = rates?.data.filter({ (rate) -> Bool in
                return rate.type == "fiat" && rate.currencySymbol != nil
            }) {
                self.rates.append(contentsOf: fiatRates)
                self.visibleRates.append(contentsOf: self.rates)
                self.collectionView.reloadData()
            }
        })
    }
    
    override func didUpdateFocus(in context: UIFocusUpdateContext, with coordinator: UIFocusAnimationCoordinator) {
        if let nextView = context.nextFocusedView {
            UIView.animate(withDuration: 0.25) {
                nextView.transform = CGAffineTransform(scaleX: 1.05, y: 1.05)
                if let rateCell = nextView as? RateCollectionViewCell {
                    rateCell.topLabel.textColor = selectedTextColor
                    rateCell.centerLabel.textColor = selectedTextColor
                    rateCell.bottomLabel.textColor = selectedTextColor
                }
            }
        }
        
        if let previousView = context.previouslyFocusedView {
            UIView.animate(withDuration: 0.25) {
                previousView.transform = CGAffineTransform(scaleX: 1, y: 1)
                if let rateCell = previousView as? RateCollectionViewCell {
                    rateCell.topLabel.textColor = .label
                    rateCell.centerLabel.textColor = .label
                    rateCell.bottomLabel.textColor = .label
                }
            }
        }
    }

    // MARK: UICollectionViewDataSource

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }


    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return visibleRates.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath)
    
        if let rateCell = cell as? RateCollectionViewCell {
            let rate = visibleRates[indexPath.row]
            rateCell.topLabel.text = rate.id
            rateCell.centerLabel.text = rate.rateUsd
            rateCell.bottomLabel.text = rate.symbol
        }
    
        return cell
    }

    // MARK: UICollectionViewDelegate
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let selectedRate = visibleRates[indexPath.row]
        coordinator?.back(selectedRate)
    }
}

extension CurrencyCollectionViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 450, height: 300)
    }
}

extension CurrencyCollectionViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        guard let searchText = searchController.searchBar.text?.localizedLowercase else { return }
        guard previousSearchText != searchText else { return }
        previousSearchText = searchText
        
        visibleRates.removeAll()
        
        if searchText.isEmpty {
            visibleRates.append(contentsOf: rates)
        } else {
            let filteredResult = self.rates.filter({ ($0.id?.localizedLowercase.contains(searchText) ?? false) || ($0.symbol?.localizedLowercase.contains(searchText) ?? false) })
            visibleRates.append(contentsOf: filteredResult)
        }
        
        visibleRates.sort()
        
        self.collectionView.reloadData()
    }
}
