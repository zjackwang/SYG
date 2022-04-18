//
//  CloudItem.swift
//  sYg
//
//  Created by Jack Wang on 3/29/22.
//

import CloudKit

struct CloudItem: Hashable, CloudKitableProtocol {
    static let recordType = "ScannedGroceryItems"
    
    let record: CKRecord
    
    /*
     * <Receipt Name>
     * <Days til expiration stored in fridge>
     * <Days til expiration stored on shelf>
     * <Days til expiration stored in freezer>
     * <Grocery category - Produce, Meats, Dairy, etc.>
     * <Extra Notes>
     */
    
    let name: String
    var daysInFridgeDisplayed: Double
    var daysOnShelfDisplayed: Double
    var daysInFreezerDisplayed: Double
    
    var daysInFridge: [Double]
    var daysOnShelf: [Double]
    var daysInFreezer: [Double]
    
    let category: String
    let categoryList: [String]
    let notes: String
    
    init?(record: CKRecord) {
        guard
            let name = record["name"] as? String
        else {
            return nil
        }
        
        self.name = name
        self.daysInFridge = record["daysInFridge"] as? [Double] ?? []
        self.daysInFreezer = record["daysInFreezer"] as? [Double] ?? []
        self.daysOnShelf = record["daysOnShelf"] as? [Double] ?? []
        
        self.daysInFridgeDisplayed = record["daysInFridgeDisplayed"] ?? 4 * TimeConstants.dayTimeInterval
        self.daysInFreezerDisplayed = record["daysInFreezerDisplayed"] ?? 30 * TimeConstants.dayTimeInterval
        self.daysOnShelfDisplayed = record["daysOnShelfDisplayed"] ?? 1 * TimeConstants.dayTimeInterval
        
        self.category = record["category"] ?? "Unknown"
        self.categoryList = record["categoryList"] as? [String] ?? []
        self.notes = record["notes"] ?? ""
        
        self.record = record
    }
    
    /*
     * Initializer for new cloud item
     */
    init?(name: String, daysInFridgeDisplayed: TimeInterval?, daysInFreezerDisplayed: TimeInterval?, daysOnShelfDisplayed: TimeInterval?, daysInFridge: TimeInterval?, daysInFreezer: TimeInterval?, daysOnShelf: TimeInterval?, category: String, notes: String?) {
        // blank record
        let record = CKRecord(recordType: CloudItem.recordType)
        record["name"] = name
        
        if let daysInFridgeDisplayed = daysInFridgeDisplayed {
            record["daysInFridgeDisplayed"] = daysInFridgeDisplayed
        }
        
        if let daysInFreezerDisplayed = daysInFreezerDisplayed {
            record["daysInFreezerDisplayed"] = daysInFreezerDisplayed
        }
        
        if let daysOnShelfDisplayed = daysOnShelfDisplayed {
            record["daysOnShelfDisplayed"] = daysOnShelfDisplayed
        }
        
        if let daysInFridge = daysInFridge {
            record["daysInFridge"] = [daysInFridge]
        }
        
        if let daysOnShelf = daysOnShelf {
            record["daysOnShelf"] = [daysOnShelf]
        }
        
        if let daysInFreezer = daysInFreezer {
            record["daysInFreezer"] = [daysInFreezer]
        }
        
        record["category"] = category
        record["notes"] = notes
        
        self.init(record: record)
    }
    
    // TODO: update displayed date as well 
    
    func updateFridgeDays(newDays: Double) -> CloudItem? {
        let record = record
        var daysInFridge = record["daysInFridge"] as? [Double] ?? []
        daysInFridge.append(newDays)
        record["daysInFridge"] = daysInFridge
        return CloudItem(record: record)
    }
    
    func updateFreezerDays(newDays: Double) -> CloudItem? {
        let record = record
        print("DEBUG >>> freezer record: \(record)")
        var daysInFreezer = record["daysInFreezer"] as? [Double] ?? []
        daysInFreezer.append(newDays)
        record["daysInFreezer"] = daysInFreezer
        return CloudItem(record: record)
    }
    
    func updateShelfDays(newDays: Double) -> CloudItem? {
        let record = record
        var daysOnShelf = record["daysOnShelf"] as? [Double] ?? []
        daysOnShelf.append(newDays)
        record["daysOnShelf"] = daysOnShelf
        return CloudItem(record: record)
    }
    
    func updateCategory(category: Category) -> CloudItem? {
        let record = record
        var categoryList = record["categoryList"] as? [String] ?? []
        categoryList.append(CategoryConverter.rawValue(given: category))
        record["categoryList"] = categoryList
        return CloudItem(record: record)
    }
    
    
}
