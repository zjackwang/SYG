//
//  HTTPManagerMock.swift
//  HTTPManagerTests
//
//  Created by Jack Wang on 2/11/22.
//

import Foundation

@testable import sYg

class HTTPManagerMock<T : URLSessionMock> : HTTPManagerProtocol {
    let session: T
    
    required init(session: T) {
        self.session = session
    }
    
    func makeRequest(with url: URL, completionBlock: @escaping (Result<Data, Error>, URLResponse?) -> Void) {
        if let dta = "This Succeeded".data(using: .utf8) {
                    completionBlock(.success(dta), nil)
        }
    }
    
    func makeRequest(request: URLRequest, completionBlock: @escaping (Result<Data, Error>, URLResponse?) -> Void) {
        if let dta = "This Succeeded".data(using: .utf8) {
                    completionBlock(.success(dta), nil)
        }
    }
}
