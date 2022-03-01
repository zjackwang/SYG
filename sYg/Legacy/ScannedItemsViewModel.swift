//
//  ScannedItemsViewModel.swift
//  sYg
//
//  Created by Jack Wang on 1/27/22.
//

import SwiftUI
import UIKit

class ScannedItemsViewModel: ObservableObject {
 
    // User's displayed list of UserItems
    @Published var items: [UserItem] = []
    
//    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    // Whether we're debugging
    private var isDebugging: Bool
    
    init(isDebugging: Bool) {
        self.isDebugging = isDebugging
    }
    
    /*
     * Defaults:
     *  - "savedItems" : set of UserItem's
     *  src: https://www.simpleswiftguide.com/how-to-use-userdefaults-in-swift/
     */
    private let defaults = UserDefaults.standard
    
    /*
     * Initialize the displayed list with items in UserDefaults
     */
    func populateItems() {
        if isDebugging {
            items.append(contentsOf: UserItem.samples)
        } else {
            do {
                try updatePublishedItems()
            } catch (let error) {
                // TODO: handle error 
            }
        }
    }
    
    /*
     * Updates the published list of items
     */
    func updatePublishedItems() throws {
        do {
            // Get items from cache
            let savedUserItems = try getAllItems()
            // Update list
            items = savedUserItems
        } catch (let error) {
            throw error
        }
    }
    
//    func addItemsTEST() {
//        let savedUserItems: [UserItem] = UserItem.samples
//        items.append(contentsOf: savedUserItems)
//    }
    
   
    
    /*
     * Adds list of items to UserDefault storage
     * Input: Array of UserItem structs
     */
    func addItems(_ scannedItems: [UserItem]) {
        // Update published list
        items.append(contentsOf: scannedItems)
        // Save
        updateItems()
    }
    
    /*
     * Input: IndexSet index of item to be deleted
     */
    func removeItem(index: IndexSet) {
        // Remove item from published list
        items.remove(atOffsets: index)
        // Save
        updateItems()
    }
    
    /*
     * Update based on displayed list
     * Input: array of UserItem structs
     * Updates the stored set using intersection
     */
    private func updateItems()  {
        // Get existing items
        let savedItems: Set<UserItem> = getAllItemsSet()
        // Intersect with updated list
        let updatedItems: [UserItem] = Array(savedItems.intersection(items))

        // Encode updated items
        guard
            let encodedUserItems = try? encodeUserItems(userItems: updatedItems)
        else {
            print("Could not encode updated UserItem List... No update")
            return
        }
        // Save all together
        defaults.set(encodedUserItems, forKey: "savedItems")
        
        // Save each one for quick access
//        defaults.set(userItem, forKey: userItem.id)
    }
    
    /*
     * Output: Array of all stored UserItem structs
     * Throws: JSONDecoder error
     */
    private func getAllItems() throws -> [UserItem] {
        if let savedUserItemsData = defaults.object(forKey: "savedItems") as? Data {
            do {
                return try decodeUserItems(userItemData: savedUserItemsData)
            } catch (let error) {
                throw error
            }
        }
        // None saved
        return [UserItem]()
    }

    /*
     * Output: Set of all currently stored UserItem structs
     */
    private func getAllItemsSet() -> Set<UserItem> {
        guard
            let savedUserItems = try? getAllItems()
        else {
            print("Error decoding UserItems from UserDefaults")
            return Set<UserItem>()
        }
        return Set(savedUserItems)
    }

    /*
     * Encode list of UserItems to Data
     * Input: Array of UserItems
     * Output: Data
     * Throws: JSONEncoder error
     */
    private func encodeUserItems(userItems: [UserItem]) throws -> Data {
        let encoder = JSONEncoder()
        do {
            let encodedUserItems = try encoder.encode(userItems)
            return encodedUserItems
        } catch (let error) {
            throw error
        }
    }
    
    /*
     * Decode Data to UserItems
     * Input: Data
     * Output: Array of UserItems
     * Throws: JSONDecoder Error
     */
    private func decodeUserItems(userItemData: Data) throws -> [UserItem] {
        let decoder = JSONDecoder()
        do {
            let savedUserItems = try decoder.decode([UserItem].self, from: userItemData)
            return savedUserItems
        } catch (let error) {
            throw error
        }
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
    
    

}