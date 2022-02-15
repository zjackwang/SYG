//
//  ProduceItemCacheMock.swift
//  sYg
//
//  Created by Jack Wang on 2/14/22.
//

import Foundation
import UIKit
@testable import sYg

// Cache adapted from https://betterprogramming.pub/analysing-data-caching-with-nscache-e0fcbed17b2b
// Simple key/value cache using NSCache
class ProduceItemCacheMock: NSCache<NSString, StructWrapper<ProduceItem>> {
    static let shared = ProduceItemCacheMock()
    
    private override init() {}
    
    func bulkCache(items: [ProduceItem], for keys: [String]) {
        for (item, key) in zip(items, keys) {
            self.cache(item, for: key)
        }
    }
    
    func bulkGet(for keys: [String]) -> [ProduceItem?] {
        var items: [ProduceItem?] = []
        for key in keys {
            items.append(self.getItem(for: key))
        }
        return items
    }
    
    func cache(_ item: ProduceItem, for key: String) {
        let keyString = NSString(string: key)
        let itemWrapper = StructWrapper(item)
        self.setObject(itemWrapper, forKey: keyString)
    }
    
    func hasItem(for key: String) -> Bool {
        return self.getItem(for: key) != nil
    }
    
    func getItem(for key: String) -> ProduceItem? {
        let keyString = NSString(string: key)
        let itemWrapper = self.object(forKey: keyString)
        return itemWrapper?.value
    }
}
