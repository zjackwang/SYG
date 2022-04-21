//
//  GenericItem.swift
//  sYg
//
//  Created by Jack Wang on 4/19/22.
//

import CloudKit

/*
 * GenericItem
 *  - iCloud recordType: "GenericItem"
 *  - Foundational model for matching strings to eat-by dates
 */

struct GenericItem: Hashable, CloudKitableProtocol {
    static let recordType = "GenericItem"

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
    var daysInFridge: Double
    var daysInFreezer: Double
    var daysOnShelf: Double
    let category: String
    let subcategory: String
    let notes: String
    let links: String

    
    init(record: CKRecord) {
//        guard
//            let name = record["name"] as? String
//        else {
//            return nil
//        }
        
        self.name = record["name"] as? String ?? "Unknown"
        self.daysInFridge = record["daysInFridge"] ?? 0
        self.daysInFreezer = record["daysInFreezer"] ?? 0
        self.daysOnShelf = record["daysOnShelf"] ?? 0
        self.category = record["category"] ?? "Unknown"
        self.subcategory = record["subcategory"] ?? ""
        self.notes = record["notes"] ?? ""
        self.links = record["links"] ?? ""
        self.record = record
        
    }
    
    // TODO: Add parameters
    init() {
        let record = CKRecord(recordType: GenericItem.recordType)
        self.init(record: record)
    }
    
    /*
     * Initializer for new generic item
     */
    init?(name: String, daysInFridge: TimeInterval, daysInFreezer: TimeInterval, daysOnShelf: TimeInterval, category: String, subcategory: String, notes: String, links: String) {
    
        let record = CKRecord(recordType: GenericItem.recordType)
        record["name"] = name
        
        record["daysInFridge"] = daysInFridge
        record["daysInFreezer"] = daysInFreezer
        record["daysOnShelf"] = daysOnShelf
        record["category"] = category
        record["subcategory"] = subcategory
        record["notes"] = notes
        record["links"] = links
        
        self.init(record: record)
    }
    

}


