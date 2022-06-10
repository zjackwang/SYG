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
     * Else, try to match scannedItem to a generic item
     * INPUT: String scannedItem.
     * OUTPUT: TimeInterval eat by interval.
     */
    func getEatByInterval(for scannedItem: String) -> TimeInterval {
        // TODO: Here goes call to match item dict to get matched generic item info
        // return getMatchedItem(...)
        
        // Use this for now
        return matchScannedItem(for: scannedItem)
    }
    
    /*
     * Finds closest generic item match given scannedItem
     *  and returns its days in fridge interval
     *  or returns default interval
     */
    func matchScannedItem(for scannedItem: String) -> TimeInterval {
        let item = linearMatcher(for: scannedItem)
        
        guard let item = item else {
            return TimeConstants.dayTimeInterval * 4
        }
        
        return TimeConstants.dayTimeInterval * item.DaysInFridge
    }
    
    
    /*
     * Finds closest generic item match for given scannedItem
     *  The closest match is defined as the longest name from a generic item
     *  that is a substring of the scannedItem's name
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
