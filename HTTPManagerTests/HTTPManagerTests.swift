//
//  HTTPManagerTests.swift
//  HTTPManagerTests
//
//  Created by Jack Wang on 2/11/22.
//

import XCTest
@testable import sYg

class HTTPManagerTests: XCTestCase {
    var urlSession: URLSessionMock?
    var httpManager: HTTPManager<URLSessionMock>?
    
    func testSuccessfulURLResponse() {
        urlSession = URLSessionMock()
        let data = Data("TEsts12".utf8)
        urlSession?.data = data
        httpManager = HTTPManager(session: urlSession!)
        let expect = expectation(description: #function)
        let url = URL(fileURLWithPath: "http://www.google.com")
        httpManager?.makeRequest(with: url) { result, response in
            XCTAssertNotNil(result)
            switch result {
            case .success(let data):
                let decodedString = String(decoding: data, as: UTF8.self)
                XCTAssertEqual(decodedString, "TEsts12")
               expect.fulfill()
            case .failure:
                XCTFail()
            }
        }
        waitForExpectations(timeout: 3.0)
    }
    
    func testFailureURLResponse() {
        // One way of testing failure is for the URLSession to simply provide no data to return
        urlSession = URLSessionMock()
        urlSession?.error = NSError(domain: "error", code: 101, userInfo: nil)
        httpManager = HTTPManager(session: urlSession!)
        let expect = expectation(description: #function)
        let url = URL(fileURLWithPath: "http://www.google.com")
        httpManager?.makeRequest(with: url) { result, response in
            XCTAssertNotNil(result)
            switch result {
            case .success:
                XCTFail()
            case .failure(let error):
                XCTAssertEqual((error as NSError).code, 101)
                expect.fulfill()
            }
        }
        waitForExpectations(timeout: 3.0)
    }

    func testBadlyFormattedURLResponse() {
        urlSession = URLSessionMock()
        httpManager = HTTPManager(session: urlSession!)
        let expectation = XCTestExpectation(description: #function)
        let url = URL(fileURLWithPath: "http://www.google.com")
        httpManager?.makeRequest(with: url) {result, response in
            switch result {
            case .success:
                XCTFail()
            case .failure(let error):
                XCTAssertNotNil(error)
                expectation.fulfill()
            }
        }
        wait(for: [expectation], timeout: 3.0)
    }

    func testSuccessfulDataResponse(){
        urlSession = URLSessionMock()
        httpManager = HTTPManager(session: urlSession!)
        let expectation = XCTestExpectation(description: #function)
        let data = Data(endPointResponse.utf8)
        urlSession?.data = data
        let url = URL(fileURLWithPath: "http://www.google.com")
        httpManager?.makeRequest(with: url) { result, response in
            do {
                let decoder = JSONDecoder()
                switch result {
                case .failure:
                    XCTFail()
                case .success(let data):
                    let content = try! decoder.decode(EndPointModel.self, from: data)
                    let test: [String: String]? = ["data key":"data value"]
                    let expectedData = EndPointModel(status: "200", data: test )
                    XCTAssertEqual(content, expectedData)
                }
            }
            expectation.fulfill()
        }
    }

    func testSuccessfulDataResponse303(){
        urlSession = URLSessionMock()
        httpManager = HTTPManager(session: urlSession!)
        let expectation = XCTestExpectation(description: #function)
        let data = Data(endPointResponse303.utf8)
        urlSession?.data = data
        let url = URL(fileURLWithPath: "http://www.google.com")
        httpManager?.makeRequest(with: url) { result, response in
            do {
                let decoder = JSONDecoder()
                switch result {
                case .failure:
                    XCTFail()
                case .success(let data):
                    let content = try! decoder.decode(EndPointModel.self, from: data)
                    let test: [String: String]? = ["data key":"data value"]
                    let expectedData = EndPointModel(status: "303", data: test )
                    XCTAssertEqual(content, expectedData)
                }
            }
            expectation.fulfill()
        }
    }
    
}

