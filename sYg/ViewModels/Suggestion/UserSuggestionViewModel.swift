//
//  UserSuggestionViewModel.swift
//  sYg
//
//  Created by Jack Wang on 6/11/22.
//

import Foundation
import Combine

/*
 * UserSuggestionViewModel
 *  should submit user suggested generic items for approval
 *  should submit user suggested matched items for approval
 *  should submit user suggested generic item updates for approval
 *  should propagate errors in the above submission processes to the user
 */
class UserSuggestionViewModel: ObservableObject {
    
    /*
     * MARK: Initialization
     */
    
    static let shared = UserSuggestionViewModel()
    private init () {}
    
    private let userSuggestionHTTPManager: UserSuggestionHTTPManager = UserSuggestionHTTPManager(session: URLSession.shared)
    private let givm: GenericItemViewModel = GenericItemViewModel.shared
    
    enum SuggestionType {
        case SuggestGenericItem
        case SuggestMatchedItem
    }
    
    // For notif to user after a scan
    // Reset by each scan, result of prev scan will stay in memory for now
    @Published var matchedItems: [MatchedItem] = []
    
    @Published var suggestionType: SuggestionType = .SuggestGenericItem
    @Published var showGenericItemSuggestionView: Bool = false
    @Published var showMatchedItemSuggestionView: Bool = false

    // Let listeners know when edits have finished
    @Published var showAlert: Bool = false
    @Published var alertText: String = "Success!"
    @Published var error: Error?
    
    /*
     * MARK: Functions
     */
    
    func setSuggestionType(suggestionType: SuggestionType) {
        self.suggestionType = suggestionType
        givm.message = suggestionType == .SuggestGenericItem ?
                    "Swipe right on an item to suggest edit" :
                    "Swipe right to an item to suggest match"
    }
    
    func suggestGenericItemAsync(genericItem: GenericItem) async {
        do {
            try await userSuggestionHTTPManager.submitSuggestGenericItemAsync(genericItem: genericItem)
        } catch {
            self.handleError(error: error)
        }
    }
    
    func suggestGenericItemUpdateAsync(userUpdatedGenericItem: UserUpdatedGenericItem) async {
        do {
            try await userSuggestionHTTPManager.submitSuggestedGenericItemUpdateAsync(updatedGenericItem: userUpdatedGenericItem)
        } catch {
            self.handleError(error: error)
        }
    }
    
    func suggestMatchedItemAsync(matchedItem: MatchedItem) async {
        do {
            try await userSuggestionHTTPManager.submitSuggestedMatchedItemAsync(matchedItem: matchedItem)
        } catch {
            self.handleError(error: error)
        }
    }
    
    func showSuggestionAlert() {
        self.showAlert.toggle()
    }
    
    func handleError(error: Error) {
        DispatchQueue.main.async {
            self.error = error
        }
    }
}
