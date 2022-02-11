//
//  ItemsHTTPManagerTests.swift
//  sYgTests
//
//  Created by Jack Wang on 2/10/22.
//

import XCTest
@testable import sYg

class ItemsHTTPManagerMockedTests: XCTestCase {
    
    private var urlSession: URLSessionMock?
    
    private var itemsHTTPManager: ItemsHTTPManager<URLSessionMock>?
    
    override func setUpWithError() throws {
        print("Starting Fetching Tests")
    }

    override func tearDownWithError() throws {
    }

    func testSuccessfulFetchProduceByNameAndIsCutMock() throws {
        
    }
    
    func testSuccessfulFetchProduceByNameMock() throws {
        urlSession = URLSessionMock()
        itemsHTTPManager = ItemsHTTPManager(session: urlSession!)
        let expectation = XCTestExpectation(description: #function)
        let data = Data(CornNotCutResponse.utf8)
        urlSession?.data = data
        
        let url = URL(fileURLWithPath: "http://www.google.com")
        itemsHTTPManager?.makeRequest(with: url) {
            result, response in
            do {
                let decoder = JSONDecoder()
                switch result {
                case.failure:
                    XCTFail()
                case .success(let data):
                    let content = try! decoder.decode(ProduceItem.self, from: data)
                    let expectedData = ProduceItem(Category: "Produce", Item: "Corn", SubCategory: "Fresh", IsCut: false, DaysInFridge: 6, DaysOnShelf: 0, DaysInFreezer: 0, Notes: "http://www.eatbydate.com/vegetables/fresh-vegetables/corn/")
                    XCTAssertEqual(content, expectedData)
                }
            }
            expectation.fulfill()
        }
        
    }

    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}
