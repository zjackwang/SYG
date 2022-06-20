//
//  Searching.swift
//  sYg
//
//  Created by Jack Wang on 6/17/22.
//

import Foundation

class Searching {
    static func filterGenericItemsByNameAndDescription(searchText: String, genericItems: [GenericItem]) -> [GenericItem]{
        // Filter packages (w/ priority)
        //  1. By Name
        //  2. By Category
        
        var searchedItems: [GenericItem] = []
        
        let searchTextLowerCase = searchText.lowercased()
        
        searchedItems.append(
            contentsOf:
                genericItems.filter({
                    $0.Name.lowercased().contains(searchTextLowerCase)
                        || $0.Category.lowercased().contains(searchTextLowerCase)
                })
                .sorted(
                    by: { $0.Name.lowercased().contains(searchTextLowerCase) && !$1.Name.lowercased().contains(searchTextLowerCase)}
                )
        )
        
        return searchedItems
    }
}
