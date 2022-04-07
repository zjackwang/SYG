//
//  UserItem.swift
//  sYg
//
//  Created by Jack Wang on 1/17/22.
//

import Foundation

struct UserItem: Identifiable, Codable {
    var id: String = UUID().uuidString
    let NameFromAnalysis: String
    var Name: String
    var DateOfPurchase: Date
    var DateToRemind: Date
    var Category: Category // Filled out by user or auto-populated
    var Storage: Storage
}

extension UserItem {
    
    init(from item: UserItem) {
        self.id = item.id
        self.NameFromAnalysis = item.NameFromAnalysis
        self.Name = item.Name
        self.DateOfPurchase = item.DateOfPurchase
        self.DateToRemind = item.DateToRemind
        self.Category = item.Category
        self.Storage = item.Storage
    }
    
    func updateName(newName: String) -> UserItem {
        var newItem = UserItem(from: self)
        newItem.Name = newName
        return newItem
    }

    func updateDateOfPurchase(newDate: Date) -> UserItem {
        var newItem = UserItem(from: self)
        newItem.DateOfPurchase = newDate
        return newItem
    }
    
    func updateDateToRemind(newDate: Date) -> UserItem {
        var newItem = UserItem(from: self)
        newItem.DateToRemind = newDate
        return newItem
    }
    
    func updateCategory(newCategory: Category) -> UserItem {
        var newItem = UserItem(from: self)
        newItem.Category = newCategory
        return newItem
    }
    
    func updateStorage(newStorage: Storage) -> UserItem {
        var newItem = UserItem(from: self)
        newItem.Storage = newStorage
        return newItem
    }
}

extension UserItem: Hashable {
    static func == (lhs: UserItem, rhs: UserItem) -> Bool {
        return lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
        hasher.combine(Name)
        hasher.combine(DateOfPurchase)
        hasher.combine(DateToRemind)
    }
}

extension UserItem {
    static let samples = [
        UserItem(NameFromAnalysis: "Apple", Name: "Apple", DateOfPurchase: Date(), DateToRemind: Date(timeIntervalSinceNow: 24 * 60 * 60), Category: .unknown, Storage: .fridge),
        UserItem(NameFromAnalysis: "Banana", Name: "Banana", DateOfPurchase: Date(), DateToRemind: Date(timeIntervalSinceNow:
                                                                                3 * 24 * 60 * 60), Category: .produce, Storage: .fridge),
        UserItem(NameFromAnalysis: "Clementine", Name: "Clementine", DateOfPurchase: Date(), DateToRemind: Date(timeIntervalSinceNow:
                                                                                    7 * 24 * 60 * 60), Category: .produce, Storage: .fridge),
        UserItem(NameFromAnalysis: "Grapefruit", Name: "Grapefruit", DateOfPurchase: Date(), DateToRemind: Date(timeIntervalSinceNow:
                                                                                    14 * 24 * 60 * 60), Category: .produce, Storage: .fridge),
        UserItem(NameFromAnalysis: "Dragonfruit", Name: "Dragonfruit", DateOfPurchase: Date(), DateToRemind: Date(timeIntervalSinceNow:
                                                                                    60 * 24 * 60 * 60), Category: .produce, Storage: .fridge)
    ]
}
