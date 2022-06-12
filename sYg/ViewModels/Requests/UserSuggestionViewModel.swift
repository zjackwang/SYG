//
//  UserSuggestionViewModel.swift
//  sYg
//
//  Created by Jack Wang on 6/11/22.
//

import Foundation

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
    
    private var userSuggestionHTTPManager: UserSuggestionHTTPManager = UserSuggestionHTTPManager(session: URLSession.shared)
    
    // For error handling
    private let mvm = MainViewModel.shared
    
    /*
     * MARK: Functions
     */
    
    func suggestGenericItemAsync(genericItem: GenericItem) async {
        do {
            try await userSuggestionHTTPManager.submitSuggestGenericItemAsync(genericItem: genericItem)
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
    
    func suggestGenericItemUpdateAsync(userUpdatedGenericItem: UserUpdatedGenericItem) async {
        do {
            try await userSuggestionHTTPManager.submitSuggestedGenericItemUpdateAsync(updatedGenericItem: userUpdatedGenericItem)
        } catch {
            self.handleError(error: error)
        }
    }
    
    /*
     * Display error on main view if any routine returns one
     */
    func handleError(error: Error) {
        mvm.alertTitle = "Database Request Error"
        mvm.error = error
    }
}
