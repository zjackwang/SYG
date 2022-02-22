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
    
    // TODO: make this a singleton.
    //      figure out why I'm using this cache.
    //      need to be able to fetch my items and match them up. Works in unit tests...
    /*
     * OUTPUT: List of Produce Items, every one. May not exist
     */
    func getAllItemsInfo() -> [ProduceItem] {
        if !items.isEmpty{
            print("Fetching \(items.count) produce items from cache")
            return items
        } else {
            let group = DispatchGroup()
            group.enter()
            print("Fetching all produce items from remote")
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
                group.leave()
            }
            group.wait()
            print("Produce items cached \(items.count) items.")
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
                    // TODO: Add isCut?
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
     * TODO: Should fire off interrupt to main thread (popup) 
     * What happens when API Request returns failure?
     */
    func handleError(error: Error) {
        print("Error fetching produce items: \(error.localizedDescription)")
    }
}
