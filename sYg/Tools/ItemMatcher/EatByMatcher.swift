//
//  EatByMatcher.swift
//  sYg
//
//  Created by Jack Wang on 4/20/22.
//

import SwiftUI
import Combine

/*
 * EatByMatcher
 *  Interfaces with recordType "MatchedItem" in iCloud
 *  Functions:
 *   - getMatchedEatBy: (Str, Storage) -> TimeInterval
 */
class EatByMatcher {
    static let instance = EatByMatcher()
    
    private var cancellables = Set<AnyCancellable>()
    
    /*
     * Return eat-by time interval of matched item
     *  with given name and place of storage
     * Input: String name
     *        Storage storage
     * Output: TimeInterval eatByTimeInterval
     */
    //TODO: Subcategory
    func getMatchedEatBy(name: String, storage: Storage) -> TimeInterval {
        guard storage != .unknown else { return 0 }
        
        return fetchMatchedEatBy(name: name, storage: storage)
    }
    
    private func fetchMatchedEatBy(name: String, storage: Storage) -> TimeInterval {
        let predicate = NSPredicate(format: "name == %@", name)
        var items: [GenericItem] = []

        let group = DispatchGroup()
        group.enter()
        CloudKitUtility.fetch(predicate: predicate, recordType: GenericItem.recordType)
            .receive(on: DispatchQueue.global(qos: .default))
            .sink { _ in
                group.leave()
            } receiveValue: {
                returnedItems in
                items = returnedItems
            }
            .store(in: &cancellables)

        group.wait()
        
        switch storage {
        case .unknown:
            return 0
        case .fridge:
            return items[0].daysInFridge
        case .freezer:
            return items[0].daysInFreezer
        case .shelf:
            return items[0].daysOnShelf
        }
    }
}
