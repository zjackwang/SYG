//
//  ScannedItemViewModel.swift
//  sYg
//
//  Created by Jack Wang on 2/17/22.
//

import CoreData

/*
 * Owns core data local persistence container 
 */
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
                print("INIT: Successfully loaded scanned items container! :)")
            }
        }
        
        getScannedItems {
            result in
            switch(result) {
            case .failure(let error):
                print("FAULT: Error requesting saved items: \(error.localizedDescription)")
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
    func addScannedItems(userItems: [UserItem], completionHandler: @escaping ([(Result<ScannedItem, Error>, String)]?) -> () = { _ in }) {
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
        completionHandler(results.count > 0 ? results : nil)
    }
    
    /*
     * Add a newly scanned item to the persistent container
     * Input: UserItem obj, decoded from receipt
     */
    func addScannedItem(userItem: UserItem, completionHandler: @escaping (Result<ScannedItem, Error>) -> () = { _ in }) {
        let scannedItem = ScannedItem(context: container.viewContext)
        scannedItem.id = UUID()
        scannedItem.nameFromAnalysis = userItem.NameFromAnalysis
        scannedItem.name = userItem.Name
        scannedItem.dateOfPurchase = userItem.DateOfPurchase
        scannedItem.dateToRemind = userItem.DateToRemind
        scannedItem.category = CategoryConverter.rawValue(given: userItem.Category)
        scannedItem.storage = StorageConverter.rawValue(given: userItem.Storage)
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
     * Delete a scanned item entity via offset from the persistent container and return its identifier
     * Input: IndexSet for entities to be deleted from scannedItems list
     * Output: String identifier, a formatted version of the eat by date
     */
//    func removeScannedItem(at offsets: IndexSet) -> String? {
//        guard let index = offsets.first else {
//            print("FAULT: Invalid IndexSet for removal-index was not first!")
//            return nil
//        }
//        let item = scannedItems[index]
//        print("INFO: Removing from container item \(item.debugDescription)")
//
//        return removeScannedItem(index: index)
//    }
    /*
     * Delete a scanned item entity via ScannedItem Object from the persistent container and return its identifier
     * Input: ScannedItem item, item to be removed
     * Output: String identifier, a formatted version of the eat by date
     */
    func removeScannedItem(item: ScannedItem) -> String? {
        guard
            let identifier = item.dateToRemind?.getFormattedDate(format: "yyyy-MM-dd")
        else {
            print("FAULT: Could not retrieve reminder date")
            return nil
        }
        
        guard let index = scannedItems.firstIndex(of: item) else { return nil }
        scannedItems.remove(at: index)
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
        
        return identifier
    }
    
    /*
     * Delete a scanned item entity via ScannedItem Object from the persistent container
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
     * Creating a scanned item from component attributes
     */
    func createScannedItem(name: String, purchaseDate: Date, remindDate: Date) -> ScannedItem {
        let scannedItem = ScannedItem(context: container.viewContext)
        scannedItem.name = name
        scannedItem.dateOfPurchase = purchaseDate
        scannedItem.dateToRemind = remindDate
        
        return scannedItem
    }
           
    
    /*
     * Update stored scanned item via UserItem struct returned from edit view
     */
    func updateScannedItem(newItem: UserItem) -> Result<ScannedItem, Error> {
        // guards
        guard
            let item = scannedItems.first(where: {$0.nameFromAnalysis  == newItem.NameFromAnalysis}),
            let index = scannedItems.firstIndex(of: item)
        else {
            return .failure(EatByReminderError("Could not find stored item"))
        }
        
        item.name = newItem.Name
        item.dateOfPurchase = newItem.DateOfPurchase
        item.dateToRemind = newItem.DateToRemind
        item.category = CategoryConverter.rawValue(given: newItem.Category)
        item.storage = StorageConverter.rawValue(given: newItem.Storage)
        scannedItems[index] = item

        var returnedError: Error?
        saveScannedItems {
            result in
            switch result {
            case .failure(let error):
                returnedError = error
            case .success:
                break
            }
        }
        
        if let error = returnedError {
            print("FAULT: \(error.localizedDescription)")
            return .failure(error)
        }
        return .success(item)
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
    
    // MARK: TESTING
    
    // NOTE: Does not schedule 
    func addSampleItems() {
        addScannedItems(userItems: UserItem.samples)
    }
    
    func removeAllItems() {
        for item in scannedItems {
            container.viewContext.delete(item)
        }
        scannedItems = []
    }
}
