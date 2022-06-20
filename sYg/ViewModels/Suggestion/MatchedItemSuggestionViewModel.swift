//
//  MatchedItemSuggestionViewModel.swift
//  sYg
//
//  Created by Jack Wang on 6/19/22.
//

import Foundation

class MatchedItemSuggestionViewModel: ObservableObject {
    
    // MARK: Initialization
    static let shared = MatchedItemSuggestionViewModel()
    private init() {}
    
    private let usvm: UserSuggestionViewModel = UserSuggestionViewModel.shared
    
    let title: String = "Suggest Match"
    @Published var matchedItem: MatchedItem?
    @Published var genericItem: GenericItem?
    
    
    // MARK: Functions
    func setMatchedItem(matchedItem: MatchedItem) {
        self.matchedItem = matchedItem
    }
    
    func setGenericItem(genericItem: GenericItem) {
        self.genericItem = genericItem
    }
    
    func submitMatchedItemSuggestion() {
        do {
            let updatedMatchedItem = try updateMatchedItem()
            Task {
                await usvm.suggestMatchedItemAsync(matchedItem: updatedMatchedItem)
                // Enough time to display message
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0, execute: {
                    self.usvm.showSuggestionAlert()
                })
            }
        } catch {
            usvm.handleError(error: error)
        }
    }
    
    func updateMatchedItem() throws -> MatchedItem {
        guard
            var matchedItem = matchedItem,
            let genericItem = genericItem
        else {
            throw GeneralError("Nil value for generic item or matched item in misvm")
        }
        matchedItem.GenericItemObj = genericItem
        return matchedItem
    }
    
}
