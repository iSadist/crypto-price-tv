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

class RateSelectorViewController: UITableViewController, Storyboarded {
    var database: Database?
    var coordinator: RateSelectorCoordinator?
    var visibleRates: [Rate]! = []
    var rates: [Rate]! = []

    fileprivate var previousSearchText: String?
    
    deinit {
        print("deinit rate")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.clearsSelectionOnViewWillAppear = false
        database = Database(format: "yyyy'-'MM'-'dd")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        database?.getRates(completionHandler: { [weak self] (rates) in
            guard let `self` = self else { return }

            if let fiatRates = rates?.data.filter({ (rate) -> Bool in
                return rate.type == "fiat" && rate.currencySymbol != nil
            }) {
                self.rates.append(contentsOf: fiatRates)
                self.visibleRates.append(contentsOf: self.rates)
                self.tableView.reloadData()
            }
        })
    }
    
    // MARK: UITableViewDataSource
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return visibleRates.count
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "Rates"
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath)
        
        if let rateCell = cell as? RateViewCell {
            let rate = visibleRates[indexPath.row]
            rateCell.centerLabel.text = "\(rate.symbol ?? "") - \(rate.id?.replacingOccurrences(of: "-", with: " ").capitalizingFirstLetter() ?? "")"
        }
    
        return cell
    }

    // MARK: UICollectionViewDelegate
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedRate = visibleRates[indexPath.row]
        coordinator?.back(selectedRate)
    }
}

extension RateSelectorViewController: UISearchResultsUpdating {
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

        tableView.reloadData()
    }
}
