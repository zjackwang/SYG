//
//  ItemMatcherTests.swift
//  sYgTests
//
//  Created by Jack Wang on 2/10/22.
//

import XCTest
@testable import sYg

class ItemMatcherTests: XCTestCase {

    // Item Matcher Obj
    var itemMatcher: ItemMatcher!
    // Produce Mock
    var produceViewModel: ProduceViewModel!

    override func setUpWithError() throws {
        itemMatcher = ItemMatcher.factory
        produceViewModel = ProduceViewModelMock(error: nil)
    }

    override func tearDownWithError() throws {
        itemMatcher = nil
        produceViewModel  = nil
    }
    
    /*
     * Given scanned produce string, do we get the expected match from ItemMatcher?
     *  One word ProduceItem name
     *   1. ProduceItem name SUBSTRING of scanned item string
     *   2. ProduceItem name SUPERSTRING of scanned item string (abbrev)
     *   3. ProduceItem name NOT found in scanned item string
     *  TODO: Testing SubCategories
     *  TODO: Testing IsCut
     *  TODO: Testing DaysOnShelf
     *  TODO: Testing DaysInFreezer
     */
    func testItemMatcherProduceItemSubString() throws {
        let dayTimeInterval: TimeInterval = 24 * 60 * 60
        
        let produceItems: [String] = ["Organic Bananas", "Red Bell Peppers", "Large Hass Avocados", "CM Organic Green Cabbage", "Small Lemon"]
        let expectedFridgeTimeIntervals: [TimeInterval] = [9 * dayTimeInterval, 12 * dayTimeInterval, 10 * dayTimeInterval, 40 * dayTimeInterval, 45 * dayTimeInterval]
        var returnedFridgeTimeInterval: TimeInterval?
        
        for (produceItem, expectedFridgeTimeInterval) in zip(produceItems, expectedFridgeTimeIntervals) {
            returnedFridgeTimeInterval = itemMatcher.getExpirationTimeInterval(for: produceItem, using: produceViewModel)
            
            XCTAssertEqual(expectedFridgeTimeInterval, returnedFridgeTimeInterval, "For \(produceItem) Item Matcher returned \(returnedFridgeTimeInterval!) while expected \(expectedFridgeTimeInterval)")
        }
        
   }
    
    func testItemMatcherProduceItemNotFound() throws {
        let produce: String = "Jalapeno Pepper"
        let expectedFridgeTimeInterval: TimeInterval = 4 * 24 * 60 * 60 // four days
        let returnedFridgeTimeInterval: TimeInterval = itemMatcher.getExpirationTimeInterval(for: produce, using: produceViewModel)
        XCTAssertEqual(expectedFridgeTimeInterval, returnedFridgeTimeInterval, "Item Matcher incorrectly matched produce to an existing item when there was no match")
    }

    func testItemMatcherProduceItemSuperString() throws {
//        let produce: String = "Baby Bella Sliced Mushroo"
//        let expectedFridgeTimeInterval: TimeInterval = 9 * 24 * 60 * 60 // nine days
//        let returnedFridgeTimeInterval: TimeInterval = itemMatcher.getExpirationTimeInterval(for: produce, using: produceViewModel)
//        print(expectedFridgeTimeInterval)
//
//        XCTAssertEqual(expectedFridgeTimeInterval, returnedFridgeTimeInterval, "Item Matcher could not find the correct produce in the DB to match")
    }

    
    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}
//
//class ProduceViewModelMock: ProduceViewModel {
//    
//    private var mockProduce: [ProduceItem] = [
//        ProduceItem(Category: "Produce", Item: "Banana", SubCategory: "Green", IsCut: false, DaysInFridge: 9, DaysOnShelf: 6, DaysInFreezer: 90, Notes: ""),
//        ProduceItem(Category: "Produce", Item: "Banana", SubCategory: "Yellow", IsCut: false, DaysInFridge: 7, DaysOnShelf: 3, DaysInFreezer: 90, Notes: ""),
//        ProduceItem(Category: "Produce", Item: "Cabbage", SubCategory: "fresh", IsCut: false, DaysInFridge: 40, DaysOnShelf: 1.5, DaysInFreezer: 365, Notes: ""),
//        ProduceItem(Category: "Produce", Item: "Cabbage", SubCategory: "fresh", IsCut: true, DaysInFridge: 7, DaysOnShelf: 0.15, DaysInFreezer: 365, Notes: "")
//    ]
//    
//    override func getAllItemsInfo() -> [ProduceItem] {
//        if !self.items.isEmpty {
//            return self.items
//        } else {
//            return mockProduce
//        }
//    }
//    
//    override func getProduceInfo(for name: String, isCut: Bool = false) -> ProduceItem? {
//        for item in mockProduce {
//            if item.Item == name {
//                return item
//            }
//        }
//        return nil
//    }
//}
