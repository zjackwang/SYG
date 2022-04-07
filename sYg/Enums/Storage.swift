//
//  Storage.swift
//  sYg
//
//  Created by Jack Wang on 4/7/22.
//

import Foundation

/*
 * Categories of grocery items
 *  => only produce for now
 */
enum Storage: String, Codable, CaseIterable {
    case unknown
    case fridge
    case freezer
    case shelf
}

class StorageConverter {
    static func rawValue(given storage: Storage) -> String {
        switch storage {
        case .unknown:
            return "Unknown"
        case .fridge:
            return "Fridge"
        case .freezer:
            return "Freezer"
        case .shelf:
            return "Shelf"
        }
    }
    
    static func fromRawValue(for rawValue: String) -> Storage {
        if rawValue == "Fridge" {
            return Storage.fridge
        } else if rawValue == "Freezer" {
            return Storage.freezer
        } else if rawValue == "Shelf" {
            return Storage.shelf
        } else {
            return Storage.unknown
        }
    }
}

