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
    func getScannedItems(completionHandler: @escaping (Result<ScannedItem, Error>) -> () = { _ in }) {
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
    func addScannedItems(userItems: [UserItem], completionHandler: @escaping ([(Result<ScannedItem, Error>, String)]) -> () = { _ in }) {
        var results: [(Result<ScannedItem, Error>, String)] = []
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
    func addScannedItem(userItem: UserItem, completionHandler: @escaping (Result<ScannedItem, Error>) -> () = { _ in }) {
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
    func deleteScannedItem(_ object: NSManagedObject, completionHandler: @escaping (Result<ScannedItem, Error>) -> () = {_ in }) {
        let context = container.viewContext
        context.delete(object)
        saveScannedItems(completionHandler: completionHandler)
    }
    
    // NEW REMOVE
    // TODO: REFACTOR

    func removeScannedItem(at offsets: IndexSet) throws -> String {
        guard let index = offsets.first else {
            print("FAULT: index was not first!")
            throw ReceiptScanningError("Invalid IndexSet for removal")
        }
        let item = scannedItems[index]
        print("INFO: Removing from container item \(item.debugDescription)")
        
        guard
            let identifier = item.dateToRemind?.getFormattedDate(format: "yyyy-MM-dd")
        else {
            print("FAULT: Error retrieving scanned item reminder date")
            throw ReceiptScanningError("Could not retrieve reminder date")
        }
        
        container.viewContext.delete(item)
        scannedItems.remove(at: index)

        var saveError: Error?
        saveScannedItems {
            result in
            switch (result) {
            case .failure(let error):
                saveError = error
            case .success(_):
                break
            }
        }
        if let saveError = saveError {
            throw saveError
        }
        return identifier
    }
    
    /*
     * Delete a scanned item entity via ScannedItem Object from teh persistent container
     * Input: IndexSet for entities to be deleted from scannedItems list
     *        completionHandler, returning identifier of removed item
     */
    func removeScannedItem(at offsets: IndexSet, completionHandler: @escaping (Result<String, Error>) -> () = {_ in }) {
        guard let index = offsets.first else {
            print("FAULT: index was not first!")
            completionHandler(.failure(ReceiptScanningError("ERROR removing item!")))
            return
        }
//        for index in offsets {
        let item = scannedItems[index]
        print("INFO: Removing item \(item.debugDescription)")
        
        guard
            let identifier = item.dateToRemind?.getFormattedDate(format: "yyyy-MM-dd")
        else {
            print("FAULT: Error retrieving scanned item reminder date")
            return
        }
        
        container.viewContext.delete(item)
        scannedItems.remove(at: index)
//        }
        saveScannedItems {
            result in
            switch (result) {
            case .failure(let error):
                completionHandler(.failure(error))
            case .success(_):
                completionHandler(.success(identifier))
            }
        }
    }
        
    /*
     * Save any changes to the persistent container
     * Error if failure, nothing if success
     */
    func saveScannedItems(completionHandler: @escaping (Result<ScannedItem, Error>) -> () = {_ in }) {
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
     * MARK: Testing functions
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
    

    func addRandomScannedItem(dateToRemind: Date) -> ScannedItem{
        let scannedItem = createScannedItem(name: UUID().uuidString, dateToRemind: dateToRemind)
        scannedItems.append(scannedItem)
        
        saveScannedItems {
            result in
            switch (result) {
            case .failure(let error):
                print("Error adding random ScannedItem \(error.localizedDescription)")
            case .success:
                print("Added Random ScannedItem")
            }
        }
        return scannedItem
    }
    
    func createScannedItem(name: String, dateToRemind: Date) -> ScannedItem {
        let scannedItem = ScannedItem(context: container.viewContext)
        scannedItem.name = name
        scannedItem.dateOfPurchase = Date.now
        scannedItem.dateToRemind = dateToRemind
        
        return scannedItem
    }
}
