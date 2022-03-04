//
//  ScannedItemViewModel.swift
//  sYg
//
//  Created by Jack Wang on 2/17/22.
//

import CoreData

class ScannedItemViewModel: ObservableObject {
    
    /*
     * MARK: Initialization
     */
    
    // Singleton
    static var shared = ScannedItemViewModel()
    
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
     * Get # of scanned items for user
     */
    func getNumberScannedItems() -> Int {
        return scannedItems.count
    }
    
    /*
     * Get item at offset
     * Input: IndexSet offset
     */
    func getItemAtOffset(at offsets: IndexSet) -> ScannedItem? {
        guard let index = offsets.first else {
            print("FAULT: Invalid IndexSet for removal-index was not first!")
            return nil
        }
        return scannedItems[index]
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
    
    /*
     * Delete a scanned item entity via ScannedItem Object from the persistent container and return its identifier
     * Input: IndexSet for entities to be deleted from scannedItems list
     *        completionHandler, returning identifier of removed item
     * Output: String identifier, a formatted version of the eat by date
     */
    func removeScannedItem(at offsets: IndexSet) -> String? {
        guard let index = offsets.first else {
            print("FAULT: Invalid IndexSet for removal-index was not first!")
            return nil
        }
        let item = scannedItems[index]
        print("INFO: Removing from container item \(item.debugDescription)")
        
        guard
            let identifier = item.dateToRemind?.getFormattedDate(format: "yyyy-MM-dd")
        else {
            print("FAULT: Could not retrieve reminder date")
            return nil
        }
        
        container.viewContext.delete(item)

        var isFailure = false
        saveScannedItems {
            result in
            switch (result) {
            case .failure(let error):
                isFailure = true
                print("FAULT: Save returned - \((error as NSError).localizedDescription)")
            case .success(_):
                break
            }
        }

        if isFailure {
            return nil
        }
        self.scannedItems.remove(at: index)
        return identifier
    }
    
    /*
     * Delete a scanned item entity via ScannedItem Object from teh persistent container
     *
     * Input: IndexSet for entities to be deleted from scannedItems list
     *        Closure completionHandler,
     *          returning identifier of removed item on success
     *          returning NSError on failure
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
     * Note: Escaping NSError if failure, nothing if success
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
}
