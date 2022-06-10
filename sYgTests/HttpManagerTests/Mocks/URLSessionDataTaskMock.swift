//
//  URLSessionDataTaskMock.swift
//  HTTPManagerTests
//
//  Created by Jack Wang on 6/7/22.
//

import Foundation

@testable import sYg

class URLSessionDataTaskMock: URLSessionDataTaskProtocol {
    private let closure: () -> Void
    
    init(closure: @escaping () -> Void) {
        self.closure = closure
    }
    
    func resume() {
        closure()
    }
}
