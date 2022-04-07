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
    var daysInFridge: [Double]
    var daysOnShelf: [Double]?
    var daysInFreezer: [Double]?
    
    let category: String?
    let storage: String?
    let notes: String?
    
    
    init?(record: CKRecord) {
        guard
            let name = record["name"] as? String
        else {
            return nil
        }
        
        self.name = name
        self.daysInFridge = record["daysInFridge"] as? [Double] ?? []
        self.daysOnShelf = record["daysOnShelf"] as? [Double] ?? []
        self.daysInFreezer = record["daysInFreezer"] as? [Double] ?? []
        
        
        self.category = record["category"]
        self.storage = record["storage"]
        self.notes = record["notes"]
        
        self.record = record
    }
    
    init?(name: String, daysInFridge: TimeInterval, daysOnShelf: TimeInterval?, daysInFreezer: TimeInterval?, category: String, storage: String, notes: String?) {
        // blank record
        let record = CKRecord(recordType: CloudItem.recordType)
        record["name"] = name
        record["daysInFridge"] = [daysInFridge]
        
        if let daysOnShelf = daysOnShelf {
            record["daysOnShelf"] = [daysOnShelf]
        }
        
        if let daysInFreezer = daysInFreezer {
            record["daysInFreezer"] = [daysInFreezer]
        }
        
        record["category"] = category
        record["storage"] = storage
        record["notes"] = notes
        
        self.init(record: record)
    }
    
    func updateFridgeDays(newDays: Double) -> CloudItem? {
        let record = record
        guard var daysInFridge = record["daysInFridge"] as? [Double] else { return nil }
        daysInFridge.append(newDays)
        record["daysInFridge"] = daysInFridge
        return CloudItem(record: record)
    }
    
    func updateCategory(newCategory: String) -> CloudItem? {
        let record = record
        record["category"] = newCategory
        return CloudItem(record: record)
    }
}
