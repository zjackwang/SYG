//
//  CloudKitViewModel.swift
//  sYg
//
//  Created by Jack Wang on 3/29/22.
//

import SwiftUI
import CloudKit
import Combine

/*
 * TODO: Create PushNotificationsViewModel
 *      - Schedule Notification
 *      - Remove Notification
 *          - One notification per day for all exp items that day (grouped)
 *      - Edit Notification
 *      - Get all Notificaitons
 */

/*
 * Owns interface to iCloud data storage
 */
class CloudKitViewModel: ObservableObject {
    static var shared = CloudKitViewModel()
    
    @Published var items: [CloudItem] = []
    
    private var cancellables = Set<AnyCancellable>()
    private var error: Error?

    init() {
        fetchItems()
    }
    
    /*
     * Generic fetch to "scanned items"
     *  Gets all recorded items from iCloud
     *
     */
    func fetchItems() {
        let predicate = NSPredicate(value: true)
        CloudKitUtility.fetch(predicate: predicate, recordType: CloudItem.recordType, sortDescriptors: nil, resultsLimit: nil)
            .receive(on: DispatchQueue.main)
            .sink { _ in
                
            } receiveValue: {
                [weak self]
                returnedItems in
                self?.items = returnedItems
            }
            .store(in: &cancellables)
    }
    
    /*
     * Compare recently scanned (and edited) items to items in cloud
     *  - if item doesn't exist, add to cloud
     *  - else add item's attributes to cloud item attributes list
     *  -  if it is exp date related
     *  -  if it is category, update category
     *  - "name" should not update in cloud, use original
     * INPUT
     *  List UserItem 'confirmedItems'
     */
    func updateCloudDatabase(confirmedItems: [UserItem]) {
        /*
         * 1. Calculate time interval between each item's
         *      purchase date and remind date
         * 2. Add to cloud using utility
         */
        print("INFO: saved items:\n\(self.items)")
        
        var itemsDict: [String: CloudItem] = [:]
        for item in self.items {
            itemsDict[item.name] = item
        }
        
        for confirmedItem in confirmedItems {
            let timeTilExpire = confirmedItem.DateToRemind.timeIntervalSince(confirmedItem.DateOfPurchase)
            
            if let cloudItem = itemsDict[confirmedItem.NameFromAnalysis] {
                // Add time til exp to appropriate exp times list
                var updatedCloudItem: CloudItem?
                switch confirmedItem.Storage {
                case .fridge:
                    updatedCloudItem = cloudItem.updateFridgeDays(newDays: timeTilExpire)
                case .freezer:
                    updatedCloudItem = cloudItem.updateFreezerDays(newDays: timeTilExpire)
                case .shelf:
                    updatedCloudItem = cloudItem.updateShelfDays(newDays: timeTilExpire)
                case .unknown:
                    break
                }
                
                guard let updatedCloudItem = updatedCloudItem,
                      let updatedCloudItem = updatedCloudItem.updateCategory(category: confirmedItem.Category)
                else {
                    print("FAULT: Could not update \(confirmedItem.Name)")
                    continue
                }
                
                print("INFO: Updating cloud item")
                CloudKitUtility.update(item: updatedCloudItem)
                    .receive(on: DispatchQueue.main)
                    .sink {
                        [weak self]
                        completion in
                        switch completion {
                            case .finished:
                                break
                            case .failure(let error):
                                self?.error = error
                                print(error)
                        }
                    } receiveValue: { success in
                    }
                    .store(in: &cancellables)
            } else {
                // Not in cloud storage, add entire item
                var cloudItem: CloudItem?
                switch confirmedItem.Storage {
                case .fridge:
                    cloudItem = CloudItem(name: confirmedItem.NameFromAnalysis, daysInFridge: timeTilExpire,  daysInFreezer: nil, daysOnShelf: nil, category: CategoryConverter.rawValue(given: confirmedItem.Category), notes: nil)
                case .freezer:
                    cloudItem = CloudItem(name: confirmedItem.NameFromAnalysis, daysInFridge: nil,  daysInFreezer: timeTilExpire, daysOnShelf: nil, category: CategoryConverter.rawValue(given: confirmedItem.Category), notes: nil)
                case .shelf:
                    cloudItem = CloudItem(name: confirmedItem.NameFromAnalysis, daysInFridge: nil,  daysInFreezer: nil, daysOnShelf: timeTilExpire, category: CategoryConverter.rawValue(given: confirmedItem.Category), notes: nil)
                case .unknown:
                    break
                }
                
                guard let cloudItem = cloudItem,
                      let cloudItem = cloudItem.updateCategory(category: confirmedItem.Category)
                else {
                    print("FAULT: Could not create cloud item")
                    continue
                }
                
                print("INFO: Adding new cloud item \(cloudItem)")
                CloudKitUtility.add(item: cloudItem)
                    .receive(on: DispatchQueue.main)
                    .sink {
                        [weak self]
                        completion in
                        switch completion {
                            case .finished:
                                break
                            case .failure(let error):
                                print(error)
                                self?.error = error
                        }
                    } receiveValue: { success in
                    }
                    .store(in: &cancellables)
                // Update local store
                items.append(cloudItem)
            }
        }
    }
    
}
