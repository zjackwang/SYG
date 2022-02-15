//
//  itemsHTTPManagerMock.swift
//  sYg
//
//  Created by Jack Wang on 2/13/22.
//

import Foundation
@testable import sYg

class ItemsHTTPManagerMock<T: URLSessionProtocol>: ItemsHTTPManager<T> {
    
    var error: Error?
    
    required init(session: T) {
        super.init(session: session)
    }
    
    init(session: T, error: Error?) {
        super.init(session: session)
        self.error = error
    }
    
    override func fetchProduceItem(for name: String?, isCut: Bool = false, completionBlock: @escaping (Result<[ProduceItem], Error>) -> Void) {
        
        if let error = error {
            completionBlock(.failure(error))
        }
        completionBlock(.success(produceItemsMock))
    }
}
