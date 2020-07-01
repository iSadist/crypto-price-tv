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
    var rates: [Rate]? = []

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
         self.clearsSelectionOnViewWillAppear = false

        // Register cell classes
//        self.collectionView!.register(RateCollectionViewCell.self, forCellWithReuseIdentifier: reuseIdentifier)
        
        database = Database(format: "yyyy'-'MM'-'dd")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        database?.getRates(completionHandler: { [weak self] (rates) in
            self?.rates?.append(contentsOf: rates?.data ?? [])
            self?.collectionView.reloadData()
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
        // #warning Incomplete implementation, return the number of sections
        return 1
    }


    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of items
        return rates?.count ?? 0
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath)
    
        if let rateCell = cell as? RateCollectionViewCell {
            let rate = rates?[indexPath.row]
            rateCell.topLabel.text = rate?.id
            rateCell.centerLabel.text = rate?.rateUsd
            rateCell.bottomLabel.text = rate?.symbol
        }
    
        return cell
    }

    // MARK: UICollectionViewDelegate

    /*
     Uncomment this method to specify if the specified item should be highlighted during tracking
     */
    override func collectionView(_ collectionView: UICollectionView, shouldHighlightItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let selectedRate = rates?[indexPath.row] else { return }
        coordinator?.back(selectedRate)
    }

    /*
    // Uncomment this method to specify if the specified item should be selected
    override func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    */

    // Uncomment these methods to specify if an action menu should be displayed for the specified item, and react to actions performed on the item
    override func collectionView(_ collectionView: UICollectionView, shouldShowMenuForItemAt indexPath: IndexPath) -> Bool {
        return true
    }

    override func collectionView(_ collectionView: UICollectionView, canPerformAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) -> Bool {
        return false
    }

    override func collectionView(_ collectionView: UICollectionView, performAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) {
    
    }
}

extension CurrencyCollectionViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        print("updating search")
    }
}
