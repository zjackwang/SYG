//
//  ProduceViewModelMock.swift
//  sYg
//
//  Created by Jack Wang on 2/13/22.
//

import Foundation
@testable import sYg 

class ProduceViewModelMock: ProduceViewModel {
        
    private var itemsHTTPManager: ItemsHTTPManager<URLSession>
    
    init(error: Error?) {
        itemsHTTPManager = ItemsHTTPManagerMock(session: URLSession.shared, error: error)
    }
    
    override func getAllItemsInfo() -> [ProduceItem] {
        if !self.items.isEmpty {
            return self.items
        } else {
            let group = DispatchGroup()
            group.enter()
            
            // get all items from API
            itemsHTTPManager.fetchProduceItem(for: nil) { [weak self]
                result in
                switch result {
                case .success(let produceItems):
                    // add to cache
                    for item in produceItems {
                        ProduceItemCacheMock.shared.cache(item, for: item.Item)
                    }
                    self?.items.append(contentsOf: produceItems)
                    break
                case .failure(let error):
                    self?.handleError(error: error)
                    break
                }
                group.leave()
            }
            group.wait()
            return self.items
        }
    }
    
    override func getProduceInfo(for name: String, isCut: Bool = false) -> ProduceItem? {
        // In current cache
        if let cachedProduceItem = ProduceItemCacheMock.shared.getItem(for: name) {
            return cachedProduceItem
        } else {
            let group = DispatchGroup()
            group.enter()
            
            // Get from API
            itemsHTTPManager.fetchProduceItem(for: name, isCut: isCut) { [weak self]
                result in
                switch result {
                case .success(let produceItems):
                    // Add to cache
                    for item in produceItems {
                        ProduceItemCacheMock.shared.cache(item, for: item.Item)
                    }
                    self?.items.append(contentsOf: produceItems)
                    break
                case .failure(let error):
                    self?.handleError(error: error)
                    return
                }
                group.leave()
            }
            group.wait()
            return ProduceItemCacheMock.shared.getItem(for: name)
        }
    }
}
