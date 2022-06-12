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

struct GenericItem: Hashable, Codable {
    /*
     * <Receipt Name>
     * <Days til expiration stored in fridge>
     * <Days til expiration stored on shelf>
     * <Days til expiration stored in freezer>
     * <Grocery category - Produce, Meats, Dairy, etc.>
     * <Extra Notes>
     */
    let Name: String
    var DaysInFridge: Double
    var DaysInFreezer: Double
    var DaysOnShelf: Double
    let Category: String
    let Subcategory: String
    let IsCut: Bool?
    let IsCooked: Bool?
    let IsOpened: Bool? 
    let Notes: String
    let Links: String
    
    private enum CodingKeys: String, CodingKey {
        case Name, DaysInFridge, DaysInFreezer, DaysOnShelf, Category, Subcategory,
        IsCut, IsCooked, IsOpened, Notes, Links
    }
    
    init(name: String, daysInFridge: Double, daysInFreezer: Double, daysOnShelf: Double, category: String, subcategory: String, isCut: Bool?, isCooked: Bool?, isOpened: Bool?, notes: String, links: String) {
        Name = name
        DaysInFridge = daysInFridge
        DaysOnShelf = daysOnShelf
        DaysInFreezer = daysInFreezer
        Category = category
        Subcategory = subcategory
        IsCut = isCut
        IsCooked = isCooked
        IsOpened = isOpened
        Notes = notes
        Links = links
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        self.Name = try container.decode(String.self, forKey: .Name)
        self.DaysInFridge = try container.decode(Double.self, forKey: .DaysInFridge)
        self.DaysInFreezer = try container.decode(Double.self, forKey: .DaysInFreezer)
        self.DaysOnShelf = try container.decode(Double.self, forKey: .DaysOnShelf)
        self.Category = try container.decode(String.self, forKey: .Category)
        self.Subcategory = try container.decode(String.self, forKey: .Subcategory)
        self.IsCut = try container.decodeIfPresent(Bool.self, forKey: .IsCut)
        self.IsCooked = try container.decodeIfPresent(Bool.self, forKey: .IsCooked)
        self.IsOpened = try container.decodeIfPresent(Bool.self, forKey: .IsOpened)
        self.Notes = try container.decode(String.self, forKey: .Notes)
        self.Links = try container.decode(String.self, forKey: .Links)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encode(Name, forKey: .Name)
        try container.encode(DaysInFridge, forKey: .DaysInFridge)
        try container.encode(DaysInFreezer, forKey: .DaysInFreezer)
        try container.encode(DaysOnShelf, forKey: .DaysOnShelf)
        try container.encode(Category, forKey: .Category)
        try container.encode(Subcategory, forKey: .Subcategory)
        try container.encodeIfPresent(IsCut, forKey: .IsCut)
        try container.encodeIfPresent(IsCooked, forKey: .IsCooked)
        try container.encodeIfPresent(IsOpened, forKey: .IsOpened)
        try container.encode(Notes, forKey: .Notes)
        try container.encode(Links, forKey: .Links)
    }
}
