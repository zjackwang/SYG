//
//  ProduceItem.swift
//  sYg
//
//  Created by Jack Wang on 12/28/21.
//


struct ProduceItem: Hashable, Codable {
    let Category: String
    let Item: String
    let SubCategory: String
    let IsCut: Bool
    let DaysInFridge: Double
    let DaysOnShelf: Double
    let DaysInFreezer: Double
    let Notes: String
    
}

extension ProduceItem {
    static func == (lhs: ProduceItem, rhs: ProduceItem) -> Bool {
        return lhs.Item == rhs.Item && lhs.IsCut == rhs.IsCut && lhs.DaysInFridge == rhs.DaysInFridge
    }
}

