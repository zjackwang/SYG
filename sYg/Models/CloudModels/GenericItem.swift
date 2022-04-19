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
    // TODO: create in iCloud
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
    let notes: String

    
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
        self.notes = record["notes"] ?? ""

        self.record = record

    }
    
    // TODO: Add parameters
    init() {
        let record = CKRecord(recordType: GenericItem.recordType)
        self.init(record: record)
    }
    

}


