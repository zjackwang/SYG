//
//  ItemsHTTPManagerMock.swift
//  HTTPManagerTests
//
//  Created by Jack Wang on 2/11/22.
//

import Foundation
@testable import sYg

// TODO: Change to fit the actual usage of this? For ViewModel Tests 
class ItemsHTTPManagerMock <T: URLSessionProtocol>: HTTPManagerProtocol {
    let session: T
    
    required init(session: T) {
        self.session = session
    }
    
    func makeRequest(with url: URL, completionBlock: @escaping (Result<Data, Error>, URLResponse?) -> Void) {
        if let dta = "This succeeded".data(using: .utf8) {
            completionBlock(.success(dta), nil)
        }
    }
    
    func makeRequest(request: URLRequest, completionBlock: @escaping (Result<Data, Error>, URLResponse?) -> Void) {
        if let dta = "This succeeded".data(using: .utf8) {
            completionBlock(.success(dta), nil)
        }
    }
}
