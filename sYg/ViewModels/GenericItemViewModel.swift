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
    private init() {}

    // Display or for item name matching
    @Published var genericItems: [GenericItem] = []
    
    var genericItemsHTTPManager: GenericItemsHTTPManager = GenericItemsHTTPManager(session: URLSession.shared)
    
    // Searching
    let searchPrompt: String = "Enter an item name here!"
    @Published var searchText: String = ""

    
    // For error handling
    private let mvm = MainViewModel.shared
    
    // MARK: Functions
    
    
    func fetchAllGenericItemsAsync() async {
        do {
            self.genericItems = try await genericItemsHTTPManager.fetchAllGenericItemsAsync()
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
            do {
                genericItems = try await genericItemsHTTPManager.fetchAllGenericItemsAsync()
            } catch {
                self.handleError(error: error)
            }
        }
        return genericItems
    }
    
    /*
     * Return a query for generic items by name and optional parameters
     *  (for generic item lookup by item matcher)
     */
    func getGenericItemAsync(name: String, params: [String: String]?) async -> [GenericItem] {
        var items: [GenericItem] = []
        do {
            items = try await genericItemsHTTPManager.fetchGenericItemAsync(for: name, formParms: params)
        } catch {
            self.handleError(error: error)
        }
        return items
    }
    
    /*
     * Return a list of all generic item names
     */
    func getGenericItemNames() async -> [String] {
        var itemNames: [String] = []
        do {
            itemNames = try await genericItemsHTTPManager.fetchGenericItemNamesAsync()
        } catch {
            self.handleError(error: error)
        }
        return itemNames
    }
    
    /*
     * Display error on main view if any routine returns one
     */
    func handleError(error: Error) {
        mvm.alertTitle = "Database Request Error"
        mvm.error = error 
    }
}
