//
//  ItemMatcherFactory.swift
//  sYg
//
//  Created by Jack Wang on 2/10/22.
//

import Foundation

/*
 * Given a string - scanned item name, return expiration timeinterval
 */
class ItemMatcher {

    /*
     * MARK: Initialization
     */
    
    static let factory = ItemMatcher()
    private init() {}
    
    private var pvm = ProduceViewModel.shared

    func getExpirationTimeInterval(for scannedItem: String) -> TimeInterval {
        let category = matchItemCategory(for: scannedItem)
        
        switch category {
        case .produce:
            return self.matchScannedItemProduce(for: scannedItem)
        default:
            return self.matchScannedItemProduce(for: scannedItem)
        }
    }
    
    /*
     * Match the category of the scanned item to one of the defined categories
     * Input: String, scanned item name
     * Output: Enum ItemCategory, one of the categories defined
     */
    private func matchItemCategory(for scannedItem: String) -> Category {
        return .produce
    }
    
    /*
     * Match one scanned item to item and exp date in produce DB
     * Input: String, item name; ProduceViewModel, interface to produce DB
     * Output: TimeInterval, Days til expiration/eat-by
     */
    private func matchScannedItemProduce(for scannedItem: String) -> TimeInterval {
        let produceItems = pvm.getAllItemsInfo()
        
        // Capitalize words
        let capitalizedItem: String = scannedItem.lowercased().capitalized
        
        /*
         * Example:
         *  scannedItem: "Large Hass Avocados"
         *  capitalizedItems: [Large, Hass, Avocados]
         *  => closestMatch: Avocado
         */
        // linear search
        let closestMatch = linearMatcher(for: capitalizedItem, produceItems: produceItems)
        
        guard let closestMatch = closestMatch else {
            return 4 * 24 * 60 * 60
        }
        
        return closestMatch.DaysInFridge * 24 * 60 * 60

    }
    
    private func linearMatcher(for scannedItem: String, produceItems: [ProduceItem]) -> ProduceItem? {
        var closestMatch: ProduceItem?

        for produceItem in produceItems {
            if scannedItem.contains(produceItem.Item) {
                let closestMatchCount: Int = closestMatch?.Item.count ?? 0
                closestMatch = produceItem.Item.count > closestMatchCount ? produceItem : closestMatch
            }
        }
        
        return closestMatch
    }
}
