//
//  ItemsHTTPManagerAsyncTests.swift
//  HTTPManagerTests
//
//  Src: https://www.raywenderlich.com/21020457-ios-unit-testing-and-ui-testing-tutorial#toc-anchor-009
//  Created by Jack Wang on 2/11/22.
//

import XCTest
@testable import sYg

/*
 * This tests
 *  Does the HTTPManager wrapper over URLRequest/Datatask work?
 *    - Assuming underlying data task works
 *  This is just the "fetchProduceItems" and "makeRequest" functions
 */
class ItemsHTTPManagerAsyncTests: XCTestCase {
    
    var session: URLSession!
    var itemsHTTPManager: ItemsHTTPManager<URLSession>!

    var urlString: String!
    
    let expectedItemCount: Int = 102
    
    override func setUpWithError() throws {
        try super.setUpWithError()
        session = URLSession.shared
        itemsHTTPManager = ItemsHTTPManager(session: session)
        urlString = "https://saveyourgroceries-api.herokuapp.com/produce"
    }

    override func tearDownWithError() throws {
        session = nil
        itemsHTTPManager = nil
        urlString = nil
        try super.tearDownWithError()
    }

    /*
     * Asynch Functional tests
     * 1. Test fetching ALL produce items => by count
     * 2. Test fetching specific produce item with name
     * 3. Test fetching specific produce item with name and is cut
     *  Flavors
     *   - response: status code, error
     *   - data: Produce Item list or individual struct returned
     * Negative tests
     * 1. Bad URL Format
     * 2. Timeout
     * 3. Failed URL Response
     *
     * MakeRequest
     *  - URL
     *  - URLRequest
     */
    
    // MARK: URL Based tests
    
    func testSuccessfulMakeRequestWithURLAllProduceHTTPURLResponse200() throws {
        let url = URL(string: urlString)!
        let promise = expectation(description: "Status Code: 200")
        
        var statusCode: Int?
        var responseError: Error?
        
        itemsHTTPManager.makeRequest(with: url) {
            result, response in
            statusCode = (response as? HTTPURLResponse)?.statusCode
            switch result {
            case .success:
                break
            case .failure(let error):
                responseError = error
                break
            }
            promise.fulfill()
        }
        
        wait(for: [promise], timeout: 10)
        
        XCTAssertNil(responseError, "Error: \(responseError!)")
        XCTAssertEqual(statusCode, 200, "Status code: \(statusCode!)")
    }
    
    func testSuccessfulMakeRequestWithURLProduceUnCutAppleHTTPURLResponse200() throws {
        let capitalizedName = "Apple"
        urlString += "?item_name=\(capitalizedName)"
        let url = URL(string: urlString)!
        let promise = expectation(description: "Status Code: 200")
        
        var statusCode: Int?
        var responseError: Error?
        
        itemsHTTPManager.makeRequest(with: url) {
            result, response in
            statusCode = (response as? HTTPURLResponse)?.statusCode
            switch result {
            case .success:
                break
            case .failure(let error):
                responseError = error
                break
            }
            promise.fulfill()
        }
        
        wait(for: [promise], timeout: 10)
        
        XCTAssertNil(responseError, "Error: \(responseError!)")
        XCTAssertEqual(statusCode, 200, "Status code: \(statusCode!)")
    }
    
    func testSuccessfulMakeRequestWithCutAppleURLHTTPURLResponse200() throws {
        let capitalizedName = "Apple"
        let capitalizedBool = "True"
        urlString += "?item_name=\(capitalizedName)&is_cut=\(capitalizedBool)"
        
        let url = URL(string: urlString)!
        let promise = expectation(description: "Status Code: 200")
        
        var statusCode: Int?
        var responseError: Error?
        
        itemsHTTPManager.makeRequest(with: url) {
            result, response in
            statusCode = (response as? HTTPURLResponse)?.statusCode
            switch result {
            case .success:
                break
            case .failure(let error):
                responseError = error
                break
            }
            promise.fulfill()
        }
        
        wait(for: [promise], timeout: 10)
        
        XCTAssertNil(responseError, "Error: \(responseError!)")
        XCTAssertEqual(statusCode, 200, "Status code: \(statusCode!)")
    }
    
    func testSuccessfulFetchAllProduceItemsByURL102Items() throws {
        let url = URL(string: urlString)!
        let promise = expectation(description: "All Produce Items")
        
        var decodingError: Error?
        var returnedProduceItems: [ProduceItem]?
        
        itemsHTTPManager.makeRequest(with: url) {
            result, _ in
            switch result {
            case .success(let data):
                do {
                    returnedProduceItems = try JSONDecoder().decode([ProduceItem].self, from: data)
                } catch {
                    decodingError = error
                }
            case .failure:
                break
            }
            promise.fulfill()
        }
        
        wait(for: [promise], timeout: 10)
        
        XCTAssertNil(decodingError, "Error: \(decodingError!)")
        XCTAssertNotNil(returnedProduceItems)
        XCTAssertEqual(returnedProduceItems?.count, expectedItemCount)
    }
    
    func testSuccessfulFetchProduceItemByURLByNameApple() throws {
        let capitalizedName = "Apple"
        urlString += "?item_name=\(capitalizedName)"
        let url = URL(string: urlString)!
        let promise = expectation(description: "Fetched uncut apple")
        
        var decodingError: Error?
        var returnedProduceItems: [ProduceItem]?
        var returnedProduceItem: ProduceItem?
        
        let expectedProduceItem = ProduceItem(Category: "Produce", Item: "Apple", SubCategory: "Fresh", IsCut: false, DaysInFridge: 30, DaysOnShelf: 7, DaysInFreezer: 240, Notes: "https://www.healthline.com/nutrition/how-long-do-apples-last#shelf-life")
        
        itemsHTTPManager.makeRequest(with: url) {
            result, _ in
            switch result {
            case .success(let data):
                do {
                    returnedProduceItems = try JSONDecoder().decode([ProduceItem].self, from: data)
                } catch let DecodingError.typeMismatch(_, context) {
                    // description
                    print(context.debugDescription)
                    returnedProduceItem = try? JSONDecoder().decode(ProduceItem.self, from: data)
                } catch {
                    decodingError = error
                }
            case .failure:
                break
            }
            promise.fulfill()
        }
        
        wait(for: [promise], timeout: 10)
        
        XCTAssertNil(decodingError, "Error: \(decodingError!)")
        XCTAssertNil(returnedProduceItems)
        XCTAssertNotNil(returnedProduceItem)
        XCTAssertEqual(returnedProduceItem, expectedProduceItem)
    }
    
    func testSuccessfulFetchProduceItemByURLByNameIsCut() throws {
        let capitalizedName = "Apple"
        let capitalizedBool = "True"
        urlString += "?item_name=\(capitalizedName)&is_cut=\(capitalizedBool)"
        
        let url = URL(string: urlString)!
        let promise = expectation(description: "Fetched cut apple")

        var decodingError: Error?
        var returnedProduceItems: [ProduceItem]?
        var returnedProduceItem: ProduceItem?

        let expectedProduceItem = ProduceItem(Category: "Produce", Item: "Apple", SubCategory: "Fresh", IsCut: true, DaysInFridge: 5, DaysOnShelf: 0, DaysInFreezer: 240, Notes: "https://www.healthline.com/nutrition/how-long-do-apples-last#shelf-life")
        
        itemsHTTPManager.makeRequest(with: url) {
            result, _ in
            switch result {
            case .success(let data):
                do {
                    returnedProduceItems = try JSONDecoder().decode([ProduceItem].self, from: data)
                } catch let DecodingError.typeMismatch(_, context) {
                    // description
                    print(context.debugDescription)
                    returnedProduceItem = try? JSONDecoder().decode(ProduceItem.self, from: data)
                } catch {
                    decodingError = error
                }
            case .failure:
                break
            }
            promise.fulfill()
        }
        
        wait(for: [promise], timeout: 10)
        
        XCTAssertNil(decodingError, "Error: \(decodingError!)")
        XCTAssertNil(returnedProduceItems)
        XCTAssertNotNil(returnedProduceItem)
        XCTAssertEqual(returnedProduceItem, expectedProduceItem)
    }
    
    // MARK: URLRequest Based tests
    
    func testSuccessfulMakeRequestWithURLRequestAllProduceHTTPURLResponse200() throws {
        let url = URL(string: urlString)!
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "GET"
        
        let promise = expectation(description: "Status Code: 200")
        
        var statusCode: Int?
        var responseError: Error?
        
        itemsHTTPManager.makeRequest(request: urlRequest) {
            result, response in
            statusCode = (response as? HTTPURLResponse)?.statusCode
            switch result {
            case .success:
                break
            case .failure(let error):
                responseError = error
                break
            }
            promise.fulfill()
        }
        
        wait(for: [promise], timeout: 10)
        
        XCTAssertNil(responseError, "Error: \(responseError!)")
        XCTAssertEqual(statusCode, 200, "Status code: \(statusCode!)")
    }
    
    func testSuccessfulMakeRequestWithURLRequestProduceUnCutAppleHTTPURLResponse200() throws {
        let capitalizedName = "Apple"
        urlString += "?item_name=\(capitalizedName)"
        let url = URL(string: urlString)!
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "GET"
        let promise = expectation(description: "Status Code: 200")
        
        var statusCode: Int?
        var responseError: Error?
        
        itemsHTTPManager.makeRequest(request: urlRequest) {
            result, response in
            statusCode = (response as? HTTPURLResponse)?.statusCode
            switch result {
            case .success:
                break
            case .failure(let error):
                responseError = error
                break
            }
            promise.fulfill()
        }
        
        wait(for: [promise], timeout: 10)
        
        XCTAssertNil(responseError, "Error: \(responseError!)")
        XCTAssertEqual(statusCode, 200, "Status code: \(statusCode!)")
    }
    
    func testSuccessfulMakeRequestWithCutAppleURLRequestHTTPURLResponse200() throws {
        let capitalizedName = "Apple"
        let capitalizedBool = "True"
        urlString += "?item_name=\(capitalizedName)&is_cut=\(capitalizedBool)"
        
        let url = URL(string: urlString)!
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "GET"
        let promise = expectation(description: "Status Code: 200")
        
        var statusCode: Int?
        var responseError: Error?
        
        itemsHTTPManager.makeRequest(request: urlRequest) {
            result, response in
            statusCode = (response as? HTTPURLResponse)?.statusCode
            switch result {
            case .success:
                break
            case .failure(let error):
                responseError = error
                break
            }
            promise.fulfill()
        }
        
        wait(for: [promise], timeout: 10)
        
        XCTAssertNil(responseError, "Error: \(responseError!)")
        XCTAssertEqual(statusCode, 200, "Status code: \(statusCode!)")
    }
    
    func testSuccessfulFetchAllProduceItemsByURLRequest102Items() throws {
        let url = URL(string: urlString)!
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "GET"
        let promise = expectation(description: "All Produce Items")
        
        var decodingError: Error?
        var returnedProduceItems: [ProduceItem]?
        
        itemsHTTPManager.makeRequest(request: urlRequest) {
            result, _ in
            switch result {
            case .success(let data):
                do {
                    returnedProduceItems = try JSONDecoder().decode([ProduceItem].self, from: data)
                } catch {
                    decodingError = error
                }
            case .failure:
                break
            }
            promise.fulfill()
        }
        
        wait(for: [promise], timeout: 10)
        
        XCTAssertNil(decodingError, "Error: \(decodingError!)")
        XCTAssertNotNil(returnedProduceItems)
        XCTAssertEqual(returnedProduceItems?.count, expectedItemCount)
    }
    
    func testSuccessfulFetchProduceItemByURLRequestByNameApple() throws {
        let capitalizedName = "Apple"
        urlString += "?item_name=\(capitalizedName)"
        let url = URL(string: urlString)!
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "GET"
        let promise = expectation(description: "Fetched uncut apple")
        
        var decodingError: Error?
        var returnedProduceItems: [ProduceItem]?
        var returnedProduceItem: ProduceItem?
        
        let expectedProduceItem = ProduceItem(Category: "Produce", Item: "Apple", SubCategory: "Fresh", IsCut: false, DaysInFridge: 30, DaysOnShelf: 7, DaysInFreezer: 240, Notes: "https://www.healthline.com/nutrition/how-long-do-apples-last#shelf-life")
        
        itemsHTTPManager.makeRequest(request: urlRequest) {
            result, _ in
            switch result {
            case .success(let data):
                do {
                    returnedProduceItems = try JSONDecoder().decode([ProduceItem].self, from: data)
                } catch let DecodingError.typeMismatch(_, context) {
                    // description
                    print(context.debugDescription)
                    returnedProduceItem = try? JSONDecoder().decode(ProduceItem.self, from: data)
                } catch {
                    decodingError = error
                }
            case .failure:
                break
            }
            promise.fulfill()
        }
        
        wait(for: [promise], timeout: 10)
        
        XCTAssertNil(decodingError, "Error: \(decodingError!)")
        XCTAssertNil(returnedProduceItems)
        XCTAssertNotNil(returnedProduceItem)
        XCTAssertEqual(returnedProduceItem, expectedProduceItem)
    }
    
    func testSuccessfulFetchProduceItemByURLRequestByNameIsCut() throws {
        let capitalizedName = "Apple"
        let capitalizedBool = "True"
        urlString += "?item_name=\(capitalizedName)&is_cut=\(capitalizedBool)"
        
        let url = URL(string: urlString)!
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "GET"
        let promise = expectation(description: "Fetched cut apple")

        var decodingError: Error?
        var returnedProduceItems: [ProduceItem]?
        var returnedProduceItem: ProduceItem?

        let expectedProduceItem = ProduceItem(Category: "Produce", Item: "Apple", SubCategory: "Fresh", IsCut: true, DaysInFridge: 5, DaysOnShelf: 0, DaysInFreezer: 240, Notes: "https://www.healthline.com/nutrition/how-long-do-apples-last#shelf-life")
        
        itemsHTTPManager.makeRequest(request: urlRequest) {
            result, _ in
            switch result {
            case .success(let data):
                do {
                    returnedProduceItems = try JSONDecoder().decode([ProduceItem].self, from: data)
                } catch let DecodingError.typeMismatch(_, context) {
                    // description
                    print(context.debugDescription)
                    returnedProduceItem = try? JSONDecoder().decode(ProduceItem.self, from: data)
                } catch {
                    decodingError = error
                }
            case .failure:
                break
            }
            promise.fulfill()
        }
        
        wait(for: [promise], timeout: 10)
        
        XCTAssertNil(decodingError, "Error: \(decodingError!)")
        XCTAssertNil(returnedProduceItems)
        XCTAssertNotNil(returnedProduceItem)
        XCTAssertEqual(returnedProduceItem, expectedProduceItem)
    }
    
    // MARK: fetchProduceItem tests
    
    func testSuccessfulFetchAllProduceItems102Items() throws {
        let promise = expectation(description: "All Produce Items")
        
        var responseError: Error?
        var returnedProduceItems: [ProduceItem]?
        
        itemsHTTPManager.fetchProduceItem(for: nil) {
            result in
            switch(result) {
            case .success(let produceItems):
                returnedProduceItems = produceItems
                break
            case .failure(let error):
                responseError = error
            }
            promise.fulfill()
        }
        
        wait(for: [promise], timeout: 10)
        
        XCTAssertNil(responseError, "Error: \(responseError!)")
        XCTAssertNotNil(returnedProduceItems)
        XCTAssertEqual(returnedProduceItems?.count, expectedItemCount)
    }
    
    func testSuccessfulFetchProduceItemByNameApple() throws {
        let capitalizedName = "Apple"
        let promise = expectation(description: "Fetched uncut apple")
        
        var responseError: Error?
        var returnedProduceItems: [ProduceItem]?
        var returnedProduceItem: ProduceItem?

        let expectedProduceItem = ProduceItem(Category: "Produce", Item: "Apple", SubCategory: "Fresh", IsCut: false, DaysInFridge: 30, DaysOnShelf: 7, DaysInFreezer: 240, Notes: "https://www.healthline.com/nutrition/how-long-do-apples-last#shelf-life")
        
        itemsHTTPManager.fetchProduceItem(for: capitalizedName, isCut: false) {
            result in
            switch(result) {
            case .success(let produceItems):
                returnedProduceItems = produceItems
                break
            case .failure(let error):
                responseError = error
            }
            promise.fulfill()
        }
        wait(for: [promise], timeout: 10)
        
        XCTAssertNil(responseError, "Error: \(responseError!)")
        XCTAssertNotNil(returnedProduceItems)
        
        returnedProduceItem = returnedProduceItems?[0]
        XCTAssertNotNil(returnedProduceItem)
        XCTAssertEqual(returnedProduceItem, expectedProduceItem)
    }
    
    func testSuccessfulFetchProduceItemByNameIsCut() throws {
        let capitalizedName = "Apple"
        let promise = expectation(description: "Fetched cut apple")

        var responseError: Error?
        var returnedProduceItems: [ProduceItem]?
        var returnedProduceItem: ProduceItem?

        let expectedProduceItem = ProduceItem(Category: "Produce", Item: "Apple", SubCategory: "Fresh", IsCut: true, DaysInFridge: 5, DaysOnShelf: 0, DaysInFreezer: 240, Notes: "https://www.healthline.com/nutrition/how-long-do-apples-last#shelf-life")
        
        itemsHTTPManager.fetchProduceItem(for: capitalizedName, isCut: true) {
            result in
            switch(result) {
            case .success(let produceItems):
                returnedProduceItems = produceItems
                break
            case .failure(let error):
                responseError = error
            }
            promise.fulfill()
        }
        
        
        wait(for: [promise], timeout: 10)
        
        XCTAssertNil(responseError, "Error: \(responseError!)")
        XCTAssertNotNil(returnedProduceItems)
        
        returnedProduceItem = returnedProduceItems?[0]
        XCTAssertNotNil(returnedProduceItem)
        XCTAssertEqual(returnedProduceItem, expectedProduceItem)
    }
    
//    func testSuccessfulFetchAllProduceResponse() throws {
//        let expectedProduceItemCount: Int = 103
//        let expectedProduceItem: ProduceItem = ProduceItem(Category: "Produce", Item: "Orange", SubCategory: "Fresh", IsCut: false, DaysInFridge: 45, DaysOnShelf: 18, DaysInFreezer: 300, Notes: "http://www.eatbydate.com/fruits/fresh/how-long-do-oranges-last-shelf-life-expiration-date/")
//
//        itemsHTTPManager?.fetchProduceItem(for: nil) {
//            result in
//            print("HELLO")
//            switch result {
//            case .success(let produceItems):
//                // should be same count
//                XCTAssertEqual(produceItems.count, expectedProduceItemCount, "Expected \(expectedProduceItemCount) items within returned array, but got \(produceItems.count)")
//
//                // should have this produce item in it
//                XCTAssert(produceItems.contains(expectedProduceItem), "Expected item \(expectedProduceItem.Item) not found within returned array")
//                break
//            case .failure(let error):
//                XCTFail("Fetching array failed with error \(error)")
//                break
//            }
//        }
//    }
}
