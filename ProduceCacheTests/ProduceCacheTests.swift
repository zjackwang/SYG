//
//  ProduceCacheTests.swift
//  ProduceCacheTests
//
//  Created by Jack Wang on 2/11/22.
//

import XCTest
@testable import sYg

/*
 * This tests..
 *   The cache singleton for produce items
 */
class ProduceCacheTests: XCTestCase {
    
    /*
     * Given a sample array of Produce Items, can we store and retrieve
     * within this cache?
     *  Different from the UserDefault UserItem storage
     */
    
    var produceCache: ProduceItemCache!
    
    let produceItems: [ProduceItem] = [
        ProduceItem(Category: "Produce", Item: "Apple", SubCategory: "Fresh", IsCut: false, DaysInFridge: 30, DaysOnShelf: 7, DaysInFreezer: 240, Notes: ""),
        ProduceItem(Category: "Produce", Item: "Avocado", SubCategory: "Fresh", IsCut: false, DaysInFridge: 10, DaysOnShelf: 3, DaysInFreezer: 0, Notes: ""),
        ProduceItem(Category: "Produce", Item: "Corn", SubCategory: "Fresh", IsCut: false, DaysInFridge: 6, DaysOnShelf: 0, DaysInFreezer: 0, Notes: ""),
        ProduceItem(Category: "Produce", Item: "Parsnips", SubCategory: "Fresh", IsCut: false, DaysInFridge: 30, DaysOnShelf: 4, DaysInFreezer: 180, Notes: "")
    ]
    
    let keys: [String] = [
        "Apple", "Avocado", "Corn", "Parsnips"
    ]

    override func setUpWithError() throws {
        produceCache = ProduceItemCache.shared
        
    }

    override func tearDownWithError() throws {
        produceCache = nil
    }

    /*
     * Functional tests
     *  1. Test cache/getItem for an array of items (Bulk cache)
     *  2. Test cache/hasItem for specific item (Ind. cache)
     *  3. neg - Test cache/getItem for unavailable item
     *  4. neg - Test cache/hasItem for unavaialble item
     */
    func testSuccessfulBulkCacheGetItemArrayItems() throws {
        // cache items
        produceCache.bulkCache(items: produceItems, for: keys)
        
        // retrieve
        let retrievedItems = produceCache.bulkGet(for: keys)
        
        for (item, expectedItem) in zip(retrievedItems, produceItems) {
            XCTAssertNotNil(item)
            XCTAssertEqual(item, expectedItem)
        }
    }
    
    func testSuccessfulCacheItemGetItem() throws {
        // cache
        produceCache.cache(produceItems[0], for: keys[0])
        
        // retrieve
        let retrievedItem = produceCache.getItem(for: keys[0])
        
        XCTAssertNotNil(retrievedItem)
        XCTAssertEqual(retrievedItem, produceItems[0])
    }
    
    func testSuccessfulBulkCacheHasItemArrayItems() throws {
        // cache items
        produceCache.bulkCache(items: produceItems, for: keys)
        
        // Lookup availability
        for key in keys {
            XCTAssertTrue(produceCache.hasItem(for: key))
        }
    }
    
    func testSuccessfulCacheItemHasItem() throws {
        // cache
        produceCache.cache(produceItems[0], for: keys[0])
        
        // Lookup availability
        XCTAssertTrue(produceCache.hasItem(for: keys[0]))
    }
    
    func testNegativeBulkCacheGetItems() throws {
        let nonexistentKeys: [String] = [
            "Celery", "Banana", "Wafers", "Cereal"
        ]
        
        // cache items
        produceCache.bulkCache(items: produceItems, for: keys)
        
        // retrieve
        let retrievedItems = produceCache.bulkGet(for: nonexistentKeys)
        
        for item in retrievedItems {
            XCTAssertNil(item)
        }
    }
    
    func testNegativeCacheGetItem() throws {
        let nonexistentKey = "Celery"
        
        // cache items
        produceCache.cache(produceItems[0], for: keys[0])
        
        // retrieve
        let retrievedItem = produceCache.getItem(for: nonexistentKey)
        
        XCTAssertNil(retrievedItem)
    }
    
    func testNegativeBulkCacheHasItemArrayItems() throws {
        let nonexistentKeys: [String] = [
            "Celery", "Banana", "Wafers", "Cereal"
        ]
        // cache items
        produceCache.bulkCache(items: produceItems, for: keys)
        
        // Lookup availability
        for key in nonexistentKeys {
            XCTAssertFalse(produceCache.hasItem(for: key))
        }
    }
    
    func testNegativeCacheItemHasItem() throws {
        let nonexistentKey = "Celery"
        // cache
        produceCache.cache(produceItems[0], for: keys[0])
        
        // Lookup availability
        XCTAssertFalse(produceCache.hasItem(for: nonexistentKey))
    }

    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        measure {
            // Put the code you want to measure the time of here.
        }
    }

}
