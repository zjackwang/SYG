//
//  GenericItemViewModel.swift
//  sYg
//
//  Created by Jack Wang on 4/19/22.
//

import Foundation

/*
 * GenericItemViewModel services look-up requests for
 *  specific generic items and provides a list of all
 *  generic items or all generic item names 
 */
class GenericItemViewModel: ObservableObject {

    // MARK: Initialization

    static let shared = GenericItemViewModel()
    
    private init() {
        // Fetch generic items to put into memory
        Task {
            await fetchAllGenericItemsAsync()
        }
    }

    // Display or for item name matching
    @Published var genericItems: [GenericItem] = []
    
    private var genericItemsHTTPManager: GenericItemsHTTPManager = GenericItemsHTTPManager(session: URLSession.shared)
    
    // Searching
    let searchPrompt: String = "Enter an item name here!"
    @Published var searchText: String = ""

    // For fetching
    // may have situation where app is fetching, then tries to fetch again.
    private var isFetching: Bool = false
    
    // For error handling
    private let mvm = MainViewModel.shared
    
    // MARK: Functions
    
    
    func fetchAllGenericItemsAsync() async {
        do {
            let items = try await genericItemsHTTPManager.fetchAllGenericItemsAsync()
            DispatchQueue.main.async {
                self.genericItems = items
            }
        } catch {
            self.handleError(error: error)
        }
    }
    
    /*
     * Fetches all generic items and stores in genericItems
     *  (for updating gui)
     */
    func fetchAllGenericItems() {
        print("INFO: Fetching all generic items from api")
        genericItemsHTTPManager.fetchAllGenericItems { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .failure(let error):
                self.handleError(error: error)
            case . success(let items):
                self.genericItems = items
            }
        }
    }
        
    /*
     * Returns a list of all generic items, first fetching if
     *  the list is empty
     */
    func getAllGenericItemsAsync() async -> [GenericItem] {
        if genericItems.isEmpty {
            await fetchAllGenericItemsAsync()
        }
        return genericItems
    }
    
    /*
     * Return a query for generic items by name and optional parameters
     *  (for generic item lookup by item matcher)
     */
    func getGenericItem(name: String, params: [String: String]?) -> [GenericItem] {
        var items: [GenericItem] = []
        let group = DispatchGroup()
        group.enter()
        
        genericItemsHTTPManager.fetchGenericItem(for: name, jsonParams: params) { [weak self] result in
            switch result {
            case .failure(let error):
                self?.handleError(error: error)
            case .success(let genericItems):
                items = genericItems
            }
            group.leave()
        }
        group.wait()
        return items
    }
    
    func getGenericItemAsync(name: String, params: [String: String]?) async -> [GenericItem] {
        var items: [GenericItem] = []
        do {
            items = try await genericItemsHTTPManager.fetchGenericItemAsync(for: name, jsonParams: params)
        } catch {
            self.handleError(error: error)
        }
        return items
    }
    
    /*
     * Return a list of all generic item names
     */
    func getGenericItemNamesAsync() async -> [String] {
        var itemNames: [String] = []
        do {
            itemNames = try await genericItemsHTTPManager.fetchGenericItemNamesAsync()
        } catch {
            self.handleError(error: error)
        }
        return itemNames
    }
    
    /*
     * Return String, matched generic item, given scannedItem
     */
    func getMatchedItem(for scannedItem: String) -> String? {
        var matchedItem: String?
        let group = DispatchGroup()
        group.enter()
        
        genericItemsHTTPManager.fetchMatchedItem(for: scannedItem) { [weak self] result in
            switch result {
            case .failure(let error):
                self?.handleError(error: error)
            case .success(let result):
                matchedItem = result
            }
            group.leave()
        }
        group.wait()
        return matchedItem
    }
    
    func getMatchedItemAsync(for scannedItem: String) async -> String? {
        var matchedItem: String?
        do {
            matchedItem = try await genericItemsHTTPManager.fetchMatchedItemAsync(for: scannedItem)
        } catch {
            self.handleError(error: error)
        }
        return matchedItem
    }
    
    /*
     * Display error on main view if any routine returns one
     */
    func handleError(error: Error) {
        mvm.alertTitle = "Database Request Error"
        mvm.error = error 
    }
}
