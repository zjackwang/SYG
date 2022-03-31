//
//  UserItem.swift
//  sYg
//
//  Created by Jack Wang on 1/17/22.
//

import Foundation

struct UserItem: Identifiable, Codable {
    var id: String = UUID().uuidString
    var Name: String
    var DateOfPurchase: Date
    var DateToRemind: Date
    var Category: Category // Filled out by user or auto-populated
}

extension UserItem {
    
    init(from item: UserItem) {
        self.id = item.id
        self.Name = item.Name
        self.DateOfPurchase = item.DateOfPurchase
        self.DateToRemind = item.DateToRemind
        self.Category = item.Category
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
        UserItem(Name: "Apple", DateOfPurchase: Date(), DateToRemind: Date(timeIntervalSinceNow: 24 * 60 * 60), Category: .unknown),
        UserItem(Name: "Banana", DateOfPurchase: Date(), DateToRemind: Date(timeIntervalSinceNow:
                                                                                3 * 24 * 60 * 60), Category: .produce),
        UserItem(Name: "Clementine", DateOfPurchase: Date(), DateToRemind: Date(timeIntervalSinceNow:
                                                                                    7 * 24 * 60 * 60), Category: .produce),
        UserItem(Name: "Grapefruit", DateOfPurchase: Date(), DateToRemind: Date(timeIntervalSinceNow:
                                                                                    14 * 24 * 60 * 60), Category: .produce),
        UserItem(Name: "Dragonfruit", DateOfPurchase: Date(), DateToRemind: Date(timeIntervalSinceNow:
                                                                                    60 * 24 * 60 * 60), Category: .produce)
    ]
}
