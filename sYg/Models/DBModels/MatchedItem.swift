//
//  MatchedItem.swift
//  sYg
//
//  Created by Jack Wang on 6/10/22.
//

import Foundation

struct MatchedItem: Codable, Hashable {
    var ScannedItemName: String
    var GenericItemObj: GenericItem?
    
    private enum CodingKeys: String, CodingKey {
        case ScannedItemName, GenericItemObj
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        self.ScannedItemName = try container.decode(String.self, forKey: .ScannedItemName)
        self.GenericItemObj = try container.decodeIfPresent(GenericItem.self, forKey: .GenericItemObj)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encode(ScannedItemName, forKey: .ScannedItemName)
        try container.encodeIfPresent(GenericItemObj, forKey: .GenericItemObj)
    }
    
    init(scannedItemName: String, genericItem: GenericItem?) {
        ScannedItemName = scannedItemName
        GenericItemObj = genericItem
    }
}

extension MatchedItem {
    
    
    
}

