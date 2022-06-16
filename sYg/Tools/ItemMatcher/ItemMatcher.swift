//
//  ItemMatcher.swift
//  sYg
//
//  Created by Jack Wang on 6/10/22.
//

import Foundation

class ItemMatcher {
    
    /*
     * MARK: Initialization
     */
    static let matcher = ItemMatcher()
    private init() {}
    
    private var givm = GenericItemViewModel.shared
    
    /*
     * If scannedItem has been matched before, return matched
     *  generic item eat by interval (default stored in fridge)
     * Else, return nil
     * Input: String scannedItem.
     * Output: optional TimeInterval eat by interval.
     */
    func getEatByInterval(for scannedItem: String) -> TimeInterval? {
        var eatByInterval: TimeInterval?
        
        if let matchedItem = givm.getMatchedItem(for:scannedItem) {
            // default to fridge
            eatByInterval = matchedItem.DaysInFridge
        }
        
        return eatByInterval
    }
    
    /*
     * Finds closest generic item match given scannedItem
     * Input: String scannedItem.
     * Output: Optional GenericItem
     */
    func matchScannedItem(for scannedItem: String) -> GenericItem? {
        let item = linearMatcher(for: scannedItem)
        
        return item
    }
    
    
    /*
     * Finds closest generic item match for given scannedItem
     *  The closest match is defined as the longest name from a generic item
     *  that is a substring of the scannedItem's name
     * Input: String scannedItem.
     * Output: Generic item
     */
    func linearMatcher(for scannedItem: String) -> GenericItem? {
        let items = givm.genericItems
        // max size 3
        var closestMatch: GenericItem?

        for item in items {
            if scannedItem.lowercased().contains(item.Name.lowercased()) {
                let closestMatchCount: Int = closestMatch?.Name.count ?? 0
                closestMatch = item.Name.count > closestMatchCount ? item : closestMatch
            }
        }
        return closestMatch
    }
}
