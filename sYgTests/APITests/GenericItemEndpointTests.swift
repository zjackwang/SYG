//
//  GenericItemEndpointTests.swift
//  sYgTests
//
//  src: https://www.raywenderlich.com/21020457-ios-unit-testing-and-ui-testing-tutorial#toc-anchor-009
//
//  Created by Jack Wang on 6/7/22.
//

import XCTest
@testable import sYg

/*
 * This tests GenericItemsHTTPManager and its connection
 *  to the public api-syg server for each type of request to each
 *  respective endpoint.
*/
class GenericItemEndpointTests: XCTestCase {
    
    var session: URLSession!
    var genericItemsHTTPManager: GenericItemsHTTPManager<URLSession>!
   
    
    override func setUpWithError() throws {
        try super.setUpWithError()
        session = URLSession.shared
        genericItemsHTTPManager = GenericItemsHTTPManager(session: session)
    }

    override func tearDownWithError() throws {
        session = nil
        genericItemsHTTPManager = nil
        try super.tearDownWithError()
    }
    
    
    // MARK: Successful request tests
     
    func testSuccessfulFetchAllGenericItems() throws {
        weak var promise = expectation(description: "All Generic Items")

        var responseError: Error?
        var returnedItems: [GenericItem]?

        genericItemsHTTPManager.fetchAllGenericItems { result in
            switch result {
            case .failure(let error):
                responseError = error
            case .success(let items):
                returnedItems = items
            }
            guard let p = promise else {
                return
            }
            p.fulfill()
            promise = nil
        }

        waitForExpectations(timeout: 10)
        XCTAssertNil(responseError, "Error: \(responseError!)")
        XCTAssertNotNil(returnedItems, "Did not get items back")
    }
    
    func testSuccessfulFetchGenericItemApple() throws {
        weak var promise = expectation(description: "Generic Item: Apple")

        let genericItem = "Apple"
        let formParams: [String: String] = [:]
        
        var responseError: Error?
        var returnedItems: [GenericItem]?

        genericItemsHTTPManager.fetchGenericItem(for: genericItem, formParams: formParams) { result in
            switch result {
            case .failure(let error):
                responseError = error
            case .success(let items):
                returnedItems = items
            }
            guard let p = promise else {
                return
            }
            p.fulfill()
            promise = nil
        }

        waitForExpectations(timeout: 10)
        XCTAssertNil(responseError, "Error: \(responseError!)")
        XCTAssertNotNil(returnedItems, "Did not get items back")
    }
    
    func testSuccessfulFetchGenericItemNames() throws {
        weak var promise = expectation(description: "Generic Item Names")

        var responseError: Error?
        var returnedItems: [String]?

        genericItemsHTTPManager.fetchGenericItemNames() { result in
            switch result {
            case .failure(let error):
                responseError = error
            case .success(let items):
                returnedItems = items
            }
            guard let p = promise else {
                return
            }
            p.fulfill()
            promise = nil
        }

        waitForExpectations(timeout: 10)
        XCTAssertNil(responseError, "Error: \(responseError!)")
        XCTAssertNotNil(returnedItems, "Did not get items back")
    }
    
    func testSuccessfulFetchMatchedItem() throws {
        weak var promise = expectation(description: "Matched Item")

        var responseError: Error?
        let scannedItemName = "Premium Bananas"
        var returnedMatchedItem: String?

        genericItemsHTTPManager.fetchMatchedItem(for: scannedItemName) { result in
            switch result {
            case .failure(let error):
                responseError = error
            case .success(let item):
                returnedMatchedItem = item
            }
            guard let p = promise else {
                return
            }
            p.fulfill()
            promise = nil
        }

        waitForExpectations(timeout: 10)
        XCTAssertNil(responseError, "Error: \(responseError!)")
        XCTAssertNotNil(returnedMatchedItem, "Did not get item back")
    }
    
    func testNotFoundFetchMatchedItem() throws {
        weak var promise = expectation(description: "Matched Item")

        var responseError: Error?
        let scannedItemName = "Definitely not in there"
        var returnedMatchedItem: String?

        genericItemsHTTPManager.fetchMatchedItem(for: scannedItemName) { result in
            switch result {
            case .failure(let error):
                responseError = error
            case .success(let item):
                returnedMatchedItem = item
            }
            guard let p = promise else {
                return
            }
            p.fulfill()
            promise = nil
        }

        waitForExpectations(timeout: 10)
        XCTAssertNil(responseError, "Error: \(responseError!)")
        XCTAssertNil(returnedMatchedItem, "Got something back...")
    }
    
    // MARK: Async Tests
    func testSuccessfulFetchAllGenericItemsAsync() async throws {
        let returnedItems = try await genericItemsHTTPManager.fetchAllGenericItemsAsync()
        
        XCTAssertGreaterThanOrEqual(returnedItems.count, 192, "Did not get items back")
    }
    
    func testSuccessfulFetchGenericItemAppleAsync() async throws {
        let genericItem = "Apple"
        let formParams: [String: String] = [:]
        
        let returnedItems = try await genericItemsHTTPManager.fetchGenericItemAsync(for: genericItem, formParms: formParams)

        XCTAssertGreaterThanOrEqual(returnedItems.count, 1, "Did not get items back")
    }
    
    func testSuccessfulFetchGenericItemNamesAsync() async throws {
        let returnedItems = try await genericItemsHTTPManager.fetchGenericItemNamesAsync()
        
        XCTAssertGreaterThanOrEqual(returnedItems.count, 192, "Did not get items back")
    }
    
    func testSuccessfulFetchMatchedItemAsync() async throws {
        let scannedItemName = "Premium Bananas"
        let returnedMatchedItem = try await genericItemsHTTPManager.fetchMatchedItemAsync(for: scannedItemName)
        
        XCTAssertNotNil(returnedMatchedItem)
    }
    
    func testNotFoundFetchMatchedItemAsync() async throws {
        let scannedItemName = "Will Not Exist"
        let returnedMatchedItem = try await genericItemsHTTPManager.fetchMatchedItemAsync(for: scannedItemName)
        
        XCTAssertNil(returnedMatchedItem)
    }
}
