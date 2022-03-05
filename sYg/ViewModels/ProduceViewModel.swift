//
//  ProduceViewModel.swift
//  sYg
//
//  Created by Jack Wang on 12/28/21.
//

import Foundation
import SwiftUI

class ProduceViewModel: ObservableObject {
    /*
     * MARK: Initialization
     */
    
    static var shared = ProduceViewModel()
    
    private init() {}
    
    @Published var items: [ProduceItem] = []
    
    // Delegate to Produce/Item Interface
    private var itemsHTTPManager: ItemsHTTPManager = ItemsHTTPManager(session: URLSession.shared)
    
    /*
     * MARK: Get functions
     */
    
    /*
     * OUTPUT: List of Produce Items, every one. May not exist
     */
    func getAllItemsInfo() -> [ProduceItem] {
        if !items.isEmpty{
            print("INFO: Fetching \(items.count) produce items from cache")
            return items
        } else {
            let group = DispatchGroup()
            group.enter()
            print("INIT: Fetching all produce items from remote")
            // get all items from API
            var returnedItems: [ProduceItem]?
            itemsHTTPManager.fetchProduceItem(for: nil) { [weak self]
                result in
                switch result {
                case .success(let produceItems):
                    // add to cache
                    for item in produceItems {
                        ProduceItemCache.shared.cache(item, for: item.Item)
                    }
                    returnedItems = produceItems
                case .failure(let error):
                    self?.handleError(error: error)
                }
                group.leave()
            }
            group.wait()
            
            if let returnedItems = returnedItems {
                print("INFO: Produce items cached \(returnedItems.count) items.")
                self.items.append(contentsOf: returnedItems)
                return self.items
            }
            print("FAULT: Error caching items")
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
            print("Fetching produce item from cache")
            return cachedProduceItem
        } else {
            let group = DispatchGroup()
            group.enter()
            print("Fetching the specific produce item")
            // Get from API
            itemsHTTPManager.fetchProduceItem(for: name, isCut: isCut) { [weak self]
                result in
                switch result {
                case .success(let produceItems):
                    // Add to cache
                    ProduceItemCache.shared.cache(produceItems[0], for: name)
                    self?.items.append(produceItems[0])
                    print("Produce items cached")
                    break
                case .failure:
                    // Not found in database.
                    return
                }
                group.leave()
            }
            group.wait()
            return ProduceItemCache.shared.getItem(for: name)
        }
    }
    
    /*
     * What happens when API Request returns failure?
     */
    func handleError(error: Error) {
        print("Error fetching produce items: \(error.localizedDescription)")
    }
}
