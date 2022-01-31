//
//  ScannedItemsViewModel.swift
//  sYg
//
//  Created by Jack Wang on 1/27/22.
//

import SwiftUI

class ScannedItemsViewModel: ObservableObject {
    /*
     * TODO
     * 1. Post new items to DB
     * 2. Grab existing from DB
     */
   
    /*
     * Defaults:
     *  - "savedItems" : set of UserItem's
     *  - ...
     */
    let defaults = UserDefaults.standard
    
    /*
     * Input: Array of UserItem structs
     * Adds each to the UserDefault storage
     */
    func addItems(_ scannedItems: [UserItem]) {
        var savedItems: Set<UserItem> = defaults.object(forKey: "savedItems") as? Set<UserItem> ?? Set<UserItem>()
        for userItem in scannedItems {
            savedItems.insert(userItem)
            // Save each one for quick access
//            defaults.set(userItem, forKey: userItem.id)
        }
        // Save all for returning all
        defaults.set(savedItems, forKey: "savedItems")
    }
    
    /*
     * Output: Array of all stored UserItem structs
     */
    func getAllItemsArray() -> [UserItem] {
        return Array(getAllItems())
    }

    /*
     * Output: Set of all currently stored UserItem structs
     */
    func getAllItems() -> Set<UserItem> {
        return defaults.object(forKey: "savedItems") as? Set<UserItem> ?? Set<UserItem>()
    }

    /*
     * Input: id of a UserItem
     * Output: stored UserItem optional
     */
//    func getItem(_ id: String) -> UserItem? {
//        return defaults.object(forKey: id) as? UserItem
//    }
    
    /*
     * Input: id of a UserItem
     * Output: boolean, whether successfully removed
     */
//    func removeItem(_ id: String) -> Bool {
//        if let _ = defaults.object(forKey: id) as? UserItem {
//            defaults.removeObject(forKey: id)
//            return true
//        }
//        return false
//    }
    
    /*
     * Input: array of UserItem structs
     * Updates the stored set using intersection
     */
    func updateItems(updatedItems: [UserItem])  {
        let savedItems: Set<UserItem> = getAllItems()
        let update = savedItems.intersection(updatedItems)
        defaults.set(update, forKey: "savedItems")
    }
}
