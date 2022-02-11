//
//  UserItem.swift
//  sYg
//
//  Created by Jack Wang on 1/17/22.
//

import Foundation

struct UserItem: Identifiable, Codable {
    var id: String = UUID().uuidString
    let Name: String
    let DateOfPurchase: Date
    let DateToRemind: Date
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
        UserItem(Name: "Apple", DateOfPurchase: Date(), DateToRemind: Date(timeIntervalSinceNow: 24 * 60 * 60)),
        UserItem(Name: "Banana", DateOfPurchase: Date(), DateToRemind: Date(timeIntervalSinceNow:
                                                                                    3 * 24 * 60 * 60)),
        UserItem(Name: "Clementine", DateOfPurchase: Date(), DateToRemind: Date(timeIntervalSinceNow:
                                                                                    7 * 24 * 60 * 60)),
        UserItem(Name: "Grapefruit", DateOfPurchase: Date(), DateToRemind: Date(timeIntervalSinceNow:
                                                                                    14 * 24 * 60 * 60)),
        UserItem(Name: "Dragonfruit", DateOfPurchase: Date(), DateToRemind: Date(timeIntervalSinceNow:
                                                                                    60 * 24 * 60 * 60))
    ]
}
