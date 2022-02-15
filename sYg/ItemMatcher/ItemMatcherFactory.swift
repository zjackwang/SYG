//
//  ItemMatcherFactory.swift
//  sYg
//
//  Created by Jack Wang on 2/10/22.
//

import Foundation

/*
 * Categories of grocery items
 *  => only produce for now
 */
enum Category: String {
    case produce
    case dairy
    case meatPoultrySeafood
    case condiments
    case drinks
}

/*
 * Concept: Given a string - scanned item name, return expiration timeinterval
 *  how?
 *    - get the category of the scanned item
 *    - get the correct item view model
 *          - how to get correct item view model? pass in? hm... TODO Create a itemViewModel factory also 
 *    - match scanned item to item view model items
 */
class ItemMatcher {
    static let factory = ItemMatcher()
    
    private init() {}
    
    func getExpirationTimeInterval(for scannedItem: String, using pvm: ProduceViewModel) -> TimeInterval {
        let category = matchItemCategory(for: scannedItem)
        
        switch category {
        case .produce:
            return self.matchScannedItemProduce(for: scannedItem, using: pvm)
//        case .dairy:
//
//        case .meatPoultrySeafood:
//            <#code#>
//        case .condiments:
//            <#code#>
//        case .drinks:
//            <#code#>
        default:
            return self.matchScannedItemProduce(for: scannedItem, using: pvm)
        }
    }
    
    /*
     * Match the category of the scanned item to one of the defined categories
     * Input: String, scanned item name
     * Output: Enum ItemCategory, one of the categories defined
     */
    private func matchItemCategory(for scannedItem: String) -> Category {
        // TODO, observe tropes for each category on receipt
        return .produce
    }
    
    
    /*
     * Matching scanned item name to a produce item
     *  Considerations
     *   - Convert all lower case
     *   - Match each produce item to name
     *      -> Which ever match has most letters wins out (specification)
     *      -> Split string by " " and match all each one (could be out of order)
     *   - How to handle abbreviations?
     *      -> Manually handle them?
     *          => Separate DB... make it manually for now
     *      -> For now, then email HEB guy
     */
    
    /*
     * Match one scanned item to item and exp date in produce DB
     * Input: String, item name; ProduceViewModel, interface to produce DB
     * Output: TimeInterval, Days til expiration/eat-by
     */
    
    // TODO use factory to get the viewmodel instead of passing it
    private func matchScannedItemProduce(for scannedItem: String, using produceViewModel: ProduceViewModel) -> TimeInterval {
        let produceItems = produceViewModel.getAllItemsInfo()
        
        // Capitalize words
//        let capitalizedItems: [String.SubSequence] = scannedItem.lowercased().capitalized.split(separator: " ")
        let capitalizedItem: String = scannedItem.lowercased().capitalized
        
        /*
         * Example:
         *  scannedItem: "Large Hass Avocados"
         *  capitalizedItems: [Large, Hass, Avocados]
         *  => closestMatch: Avocado
         */
        var closestMatch: ProduceItem?
        // linear search
        for produceItem in produceItems {
            if capitalizedItem.contains(produceItem.Item) {
                let closestMatchCount: Int = closestMatch?.Item.count ?? 0
                closestMatch = produceItem.Item.count > closestMatchCount ? produceItem : closestMatch
            }
        }
        
        guard let closestMatch = closestMatch else {
            // TODO: default 4 days. could be customizable in settings
            return 4 * 24 * 60 * 60
        }
        
        return closestMatch.DaysInFridge * 24 * 60 * 60

    }
    
    /*
     * Create one for each category
     */
    
//    private func matchScannedItemDairy(for scannedItem: String, using produceViewModel: ProduceViewModel) -> TimeInterval {

    
}
