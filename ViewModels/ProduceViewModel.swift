//
//  ProduceViewModel.swift
//  sYg
//
//  Created by Jack Wang on 12/28/21.
//

import Foundation
import SwiftUI

class ProduceViewModel: ObservableObject {
    @Published var items: [ProduceItem] = []
    
    // Delegate to Produce/Item Interface
    private var itemsHTTPManager: ItemsHTTPManager = ItemsHTTPManager(session: URLSession.shared)
    
    /*
     * OUTPUT: List of Produce Items, every one. May not exist
     */
    func getAllItemsInfo() -> [ProduceItem] {
        if !self.items.isEmpty {
            return self.items
        } else {
            // get all items from API
            itemsHTTPManager.fetchProduceItem(for: nil) { [weak self]
                result in
                switch result {
                case .success(let produceItems):
                    // add to cache
                    for item in produceItems {
                        ProduceItemCache.shared.cache(item, for: item.Item)
                    }
                    self?.items.append(contentsOf: produceItems)
                    break
                case .failure(let error):
                    self?.handleError(error: error)
                    break
                }
            }
            return self.items
        }
    }
    
    /*
     * Wrapper around fetch calls
     *  - tries to get from cache, else getse from HTTP
     * INPUT: String name of produce item, Boolean whether item is cut open
     * OUTPUT: Optional Produce Item that is found in DB. May not exist
     */
    func getProduceInfo(for name: String, isCut: Bool = false) -> ProduceItem? {
        // In current cache
        if let cachedProduceItem = ProduceItemCache.shared.getItem(for: name) {
            return cachedProduceItem
        } else {
            // Get from API
            itemsHTTPManager.fetchProduceItem(for: name, isCut: isCut) { [weak self]
                result in
                switch result {
                case .success(let produceItems):
                    // Add to cache
                    // TODO Add isCut?
                    ProduceItemCache.shared.cache(produceItems[0], for: name)
                    self?.items.append(produceItems[0])
                    break
                case .failure(let error):
                    self?.handleError(error: error)
                    return
                }
            }
            return ProduceItemCache.shared.getItem(for: name)
        }
    }
    
    /*
     * TODO 
     * What happens when API Request returns failure?
     */
    private func handleError(error: Error) {
        
    }
}
