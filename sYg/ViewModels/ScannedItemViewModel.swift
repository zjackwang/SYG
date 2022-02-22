//
//  ScannedItemViewModel.swift
//  sYg
//
//  Created by Jack Wang on 2/17/22.
//

import CoreData

/*
 * TODO: Description
 */
class ScannedItemViewModel: ObservableObject {
    
    /*
     * MARK: Initialization
     */
    
    // Singleton
    static let shared = ScannedItemViewModel()
    
    let container: NSPersistentContainer
    @Published var scannedItems: [ScannedItem] = []
    
    init() {
        container = NSPersistentContainer(name: "ScannedItemsDataModel")
        container.loadPersistentStores {
            description, error in
            
            if let error = error {
                fatalError("Error: \(error.localizedDescription)")
            } else {
                print("Successfully loaded scanned items container! :)")
            }
        }
        
        getScannedItems {
            result in
            switch(result) {
            case .failure(let error):
                print("Error requesting saved items: \(error.localizedDescription)")
            case .success(_):
                break
            }
        }
    }
    
    /*
     * MARK: CRUD FUNCTIONS
     */
    
    /*
     * Get all scanned items for user
     */
    func getScannedItems(completionHandler: @escaping (Result<Data?, Error>) -> () = { _ in }) {
        let request = NSFetchRequest<ScannedItem>(entityName: "ScannedItem")
        do {
            scannedItems = try container.viewContext.fetch(request)
        } catch (let error) {
            completionHandler(.failure(error))
        }
    }
    
    /*
     * Add list of newly scanned items to persistent container
     * Input: List of UserItem objs
     */
    func addScannedItems(userItems: [UserItem], completionHandler: @escaping ([(Result<Data?, Error>, String)]) -> () = { _ in }) {
        var results: [(Result<Data?, Error>, String)] = []
        for userItem in userItems {
            addScannedItem(userItem: userItem) {
                result in
                switch result {
                case .failure(let error):
                    results.append((.failure(error), userItem.Name))
                case .success(_):
                    break
                }
            }
        }
        completionHandler(results)
    }
    
    /*
     * Add a newly scanned item to the persistent container
     * Input: UserItem obj, decoded from receipt
     */
    func addScannedItem(userItem: UserItem, completionHandler: @escaping (Result<Data?, Error>) -> () = { _ in }) {
        let scannedItem = ScannedItem(context: container.viewContext)
        scannedItem.name = userItem.Name
        scannedItem.dateOfPurchase = userItem.DateOfPurchase
        scannedItem.dateToRemind = userItem.DateToRemind
        scannedItems.append(scannedItem)
        
        saveScannedItems(completionHandler: completionHandler)
    }
    
    /*
     * Delete an entity from the persistent container
     * NOTE: Unused
     * Input: NSManagedObject
     */
    func deleteScannedItem(_ object: NSManagedObject, completionHandler: @escaping (Result<Data?, Error>) -> () = {_ in }) {
        let context = container.viewContext
        context.delete(object)
        saveScannedItems(completionHandler: completionHandler)
    }
    
    /*
     * Delete a scanned item entity via ScannedItem Object from teh persistent container
     * Input: IndexSet for entiteis to be deleted from scannedItems list
     */
    func removeScannedItem(at offsets: IndexSet, completionHandler: @escaping (Result<Data?, Error>) -> () = {_ in }) {
        guard let index = offsets.first else { return }
//        for index in offsets {
        let item = scannedItems[index]
        container.viewContext.delete(item)
        scannedItems.remove(at: index)
//        }
        saveScannedItems(completionHandler: completionHandler)
    }
        
    /*
     * Save any changes to the persistent container
     * Error if failure, nothing if success
     */
    func saveScannedItems(completionHandler: @escaping (Result<Data?, Error>) -> () = {_ in }) {
        let context = container.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch (let error) {
                completionHandler(.failure(error))
            }
        }
    }
    
    /*
     * MARK: DEV FUNCTIONS
     */
    func resetContainer() {
        for obj in scannedItems {
            container.viewContext.delete(obj)
        }
        scannedItems = [] 
        saveScannedItems {
            result in
            switch (result) {
            case .failure(let error):
                print("Error deleting items from persistent container \(error.localizedDescription)")
            case .success:
                print("Reset persistent container")
            }
        }
    }
}
