//
//  ItemsDBAsyncTests.swift
//  HTTPManagerTests
//
//  Created by Jack Wang on 2/11/22.
//

import XCTest

@testable import sYg

/* This tests...
 *  Does the Produce API work?
 *   - Assuming the API URL Request is always correct. 
 */
class ProduceItemsDBAsyncTests: XCTestCase {

    var session: URLSession!
    var urlString: String!

    override func setUpWithError() throws {
        try super.setUpWithError()
        session = URLSession(configuration: .default)
        urlString = "https://saveyourgroceries-api.herokuapp.com/produce"
    }

    override func tearDownWithError() throws {
        session = nil
        urlString = nil
        try super.tearDownWithError()
    }
    
    
    /* URLSession/Datatask test with produce api
     * Positive Cases:
     *  1. All produce
     *  2. Produce Item by Name only
     *  3. Produce Item by Name and IsCut
     *
     * Flavors
     *  - status code => ensures response is correct, status code is 200
     *  - data => ensures data is correct, expected count, expected items returned
     * Notes:
     *  - Fail fast, succeed slow.
     *  - Don't assert inside asynch routine
     */
    func testSuccessfulFetchAllProduceHTTPStatusCode200() throws {
        let url = URL(string: urlString)!
        let promise = expectation(description: "Status Code: 200")
        
        var statusCode: Int?
        var responseError: Error?
        
        let dataTask = session.dataTask(with: url) {
            _, response, error in
            statusCode = (response as? HTTPURLResponse)?.statusCode
            responseError = error
            promise.fulfill()
        }
        dataTask.resume()
        
        wait(for: [promise], timeout: 10)
        
        XCTAssertNil(responseError, "Error: \(responseError!)")
        XCTAssertEqual(statusCode, 200, "Status code: \(statusCode!)")
    }
    
    func testSuccessfulFetchProduceByNameHTTPStatusCode200() throws {
        let capitalizedName = "Apple"
        urlString += "?item_name=\(capitalizedName)"
        let url = URL(string: urlString)!
        let promise = expectation(description: "Status Code: 200")
        
        var statusCode: Int?
        var responseError: Error?
        
        let dataTask = session.dataTask(with: url) {
            _, response, error in
            statusCode = (response as? HTTPURLResponse)?.statusCode
            responseError = error
            promise.fulfill()
        }
        dataTask.resume()
        
        wait(for: [promise], timeout: 10)
        
        XCTAssertNil(responseError, "Error: \(responseError!)")
        XCTAssertEqual(statusCode, 200, "Status code: \(statusCode!)")
    }
    
    func testSuccessfulFetchProduceByNameIsCutHTTPStatusCode200() throws {
        let capitalizedName = "Apple"
        let capitalizedBool = "True"
        urlString += "?item_name=\(capitalizedName)&is_cut=\(capitalizedBool)"
        
        let url = URL(string: urlString)!
        let promise = expectation(description: "Status Code: 200")

        var statusCode: Int?
        var responseError: Error?
        
        let dataTask = session.dataTask(with: url) {
            _, response, error in
            statusCode = (response as? HTTPURLResponse)?.statusCode
            responseError = error
            promise.fulfill()
        }
        dataTask.resume()
        
        wait(for: [promise], timeout: 10)
        
        XCTAssertNil(responseError, "Error: \(responseError!)")
        XCTAssertEqual(statusCode, 200, "Status code: \(statusCode!)")
    }
    
    func testSuccessfulFetchAllProduceItems102Items() throws {
        let url = URL(string: urlString)!
        let promise = expectation(description: "All Produce Items")
        
        var decodingError: Error?
        var returnedProduceItems: [ProduceItem]?
        let expectedItemCount: Int = 102
        
        let dataTask = session.dataTask(with: url) {
            data, response, error in
            
            if let data = data {
                do {
                    returnedProduceItems = try JSONDecoder().decode([ProduceItem].self, from: data)
                } catch let error {
                    decodingError = error
                }
            }
            promise.fulfill()
        }
        dataTask.resume()
        
        wait(for: [promise], timeout: 10)
        
        XCTAssertNil(decodingError, "Error: \(decodingError!)")
        XCTAssertNotNil(returnedProduceItems)
        XCTAssertEqual(returnedProduceItems?.count, expectedItemCount)
    }
    
    func testSuccessfulFetchProduceItemByNameApple() throws {
        let capitalizedName = "Apple"
        urlString += "?item_name=\(capitalizedName)"
        let url = URL(string: urlString)!
        let promise = expectation(description: "Fetched uncut apple")
        
        var decodingError: Error?
        var returnedProduceItems: [ProduceItem]?
        var returnedProduceItem: ProduceItem?
        
        let expectedProduceItem = ProduceItem(Category: "Produce", Item: "Apple", SubCategory: "Fresh", IsCut: false, DaysInFridge: 30, DaysOnShelf: 7, DaysInFreezer: 240, Notes: "https://www.healthline.com/nutrition/how-long-do-apples-last#shelf-life")
        
        let dataTask = session.dataTask(with: url) {
            data, response, error in
            
            if let data = data {
                do {
                    returnedProduceItems = try JSONDecoder().decode([ProduceItem].self, from: data)
                } catch let DecodingError.typeMismatch(_, context) {
                    print(context)
                    returnedProduceItem = try? JSONDecoder().decode(ProduceItem.self, from: data)
                } catch let error {
                    decodingError = error
                }
            }
            promise.fulfill()
        }
        dataTask.resume()
        
        wait(for: [promise], timeout: 10)
        
        XCTAssertNil(decodingError, "Error: \(decodingError!)")
        XCTAssertNil(returnedProduceItems)
        XCTAssertNotNil(returnedProduceItem)
        XCTAssertEqual(returnedProduceItem, expectedProduceItem)
    }
    
    func testSuccessfulFetchProduceItemByNameIsCut() throws {
        let capitalizedName = "Apple"
        let capitalizedBool = "True"
        urlString += "?item_name=\(capitalizedName)&is_cut=\(capitalizedBool)"
        
        let url = URL(string: urlString)!
        let promise = expectation(description: "Fetched cut apple")

        var decodingError: Error?
        var returnedProduceItems: [ProduceItem]?
        var returnedProduceItem: ProduceItem?

        let expectedProduceItem = ProduceItem(Category: "Produce", Item: "Apple", SubCategory: "Fresh", IsCut: true, DaysInFridge: 5, DaysOnShelf: 0, DaysInFreezer: 240, Notes: "https://www.healthline.com/nutrition/how-long-do-apples-last#shelf-life")
        
        let dataTask = session.dataTask(with: url) {
            data, response, error in
            
            if let data = data {
                do {
                    returnedProduceItems = try JSONDecoder().decode([ProduceItem].self, from: data)
                } catch let DecodingError.typeMismatch(_, context) {
                    print(context)
                    returnedProduceItem = try? JSONDecoder().decode(ProduceItem.self, from: data)
                } catch let error {
                    decodingError = error
                }
            }
            promise.fulfill()
        }
        dataTask.resume()
        
        wait(for: [promise], timeout: 10)
        
        XCTAssertNil(decodingError, "Error: \(decodingError!)")
        XCTAssertNil(returnedProduceItems)
        XCTAssertNotNil(returnedProduceItem)
        XCTAssertEqual(returnedProduceItem, expectedProduceItem)
    }
    
    
//    func testFetchAllProducePerformance() throws {
//        let url = URL(string: urlString)!
//
//        let promise = expectation(description: "Completion")
//
//        let dataTask = session.dataTask(with: url) {
//            _, _, _ in
//            promise.fulfill()
//        }
//        self.measure(
//            metrics: [
//                XCTClockMetric(),
//                XCTCPUMetric(),
//                XCTStorageMetric(),
//                XCTMemoryMetric()
//            ] ) {
//                dataTask.resume()
//        }
//        wait(for: [promise], timeout: 10)
//    }

}
