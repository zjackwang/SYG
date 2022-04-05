//
//  Category.swift
//  sYg
//
//  Created by Jack Wang on 3/31/22.
//

import Foundation

/*
 * Categories of grocery items
 *  => only produce for now
 */
enum Category: String, Codable {
    case unknown
    case produce
    case dairy
    case meatPoultrySeafood
    case condiments
    case drinks
}

class CategoryConverter {
    static func rawValue(given category: Category) -> String {
        switch category {
        case .unknown:
            return "Unknown"
        case .produce:
            return "Produce"
        case .dairy:
            return "Dairy"
        case .meatPoultrySeafood:
            return "Meat, Poultry, Seafood"
        case .condiments:
            return "Condiments"
        case .drinks:
            return "Drinks"
        }
    }
    
    static func fromRawValue(for rawValue: String) -> Category {
        if rawValue == "Produce" {
            return Category.produce
        } else if rawValue == "Dairy" {
            return Category.dairy
        } else if rawValue == "Meat, Poultry, Seafood" {
            return Category.meatPoultrySeafood
        } else if rawValue == "Condiments" {
            return Category.condiments
        } else if rawValue == "Drinks" {
            return Category.drinks
        } else {
            return Category.unknown
        }
    }
}

