//
//  ProduceViewModelTests.swift
//  sYgTests
//
//  Created by Jack Wang on 2/10/22.
//

import XCTest
@testable import sYg

/*
 * This tests
 *   How view model updates items info and returns it
 *    and how it handles errors
 */
class ProduceViewModelTests: XCTestCase {
    var produceViewModel: ProduceViewModel!
    
    override func setUpWithError() throws {
        produceViewModel = ProduceViewModelMock(error: nil)
    }

    override func tearDownWithError() throws {
        produceViewModel = nil
    }

    /*
     * Testing
     *  1. Getting all info without any in storage
     *  2. Getting all info with it in storage (not cache)
     *  3. Getting info for specific produce without it in cache
     *  4. Getting info for specific produce with it in cache
     *  Neg
     *  1. Error returned from getting all info
     *  2. Error returned from getting specific produce item
     */
    
    func testSuccessfulGetAllItemsInfoInitEmpty() throws {
        XCTAssertTrue(produceViewModel.items.isEmpty)
        let returnedItems: [ProduceItem] = produceViewModel.getAllItemsInfo()
        
        for (item, expectedItem) in zip(returnedItems, produceItemsMock) {
            XCTAssertEqual(item, expectedItem)
        }
    }
    
    func testSuccessfulGetAllItemsInfoNotEmpty() throws {
        let _ = produceViewModel.getAllItemsInfo()
        XCTAssertFalse(produceViewModel.items.isEmpty)
        let returnedItems: [ProduceItem] = produceViewModel.getAllItemsInfo()
        
        for (item, expectedItem) in zip(returnedItems, produceItemsMock) {
            XCTAssertEqual(item, expectedItem)
        }
    }
    
    func testSuccessfulGetSpecificItemNotInCache() throws {
        XCTAssertTrue(produceViewModel.items.isEmpty)

        let apple = produceViewModel.getProduceInfo(for: "Apple")
        
        XCTAssertNotNil(apple)
        XCTAssertEqual(apple?.Item, "Apple")
    }
    
    func testSuccessfulGetSpecificItemInCache() throws {
        let _ = produceViewModel.getAllItemsInfo()
        XCTAssertFalse(produceViewModel.items.isEmpty)

        let apple = produceViewModel.getProduceInfo(for: "Apple")
        
        XCTAssertNotNil(apple)
        XCTAssertEqual(apple?.Item, "Apple")
    }
    
    // TODO: Error
    
    
    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}
