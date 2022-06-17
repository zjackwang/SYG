//
//  UserSuggestionAPIEndpointTests.swift
//  sYgTests
//
//  Created by Jack Wang on 6/11/22.
//

import XCTest
@testable import sYg

class UserSuggestionAPIEndpointTests: XCTestCase {

    var session: URLSession!
    var userSuggestionHTTPManager: UserSuggestionHTTPManager<URLSession>!
   
    
    override func setUpWithError() throws {
        try super.setUpWithError()
        session = URLSession.shared
        userSuggestionHTTPManager = UserSuggestionHTTPManager(session: session)
    }

    override func tearDownWithError() throws {
        session = nil
        userSuggestionHTTPManager = nil
        try super.tearDownWithError()
    }

    func testSuccessfulPostGenericItemTestAsync() async throws {
        let submittedGenericItem: GenericItem = GenericItem(name: "Example", daysInFridge: 20.5, daysInFreezer: 20.5, daysOnShelf: 20.5, category: "Produce", subcategory: "Fresh", isCut: false, isCooked: false, isOpened: false, notes: "", links: "")
        
        try await userSuggestionHTTPManager.submitSuggestGenericItemAsync(genericItem: submittedGenericItem)
        
    }
    
    func testSuccessfulPostMatchedItemTestAsync() async throws {
        let submittedGenericItem: GenericItem = GenericItem(name: "Apple", daysInFridge: 30.0, daysInFreezer: 240.0, daysOnShelf: 10.0, category: "Produce", subcategory: "Fresh", isCut: false, isCooked: nil, isOpened: nil, notes: "", links: "https://www.healthline.com/nutrition/how-long-do-apples-last#shelf-life")
        
        let submittedMatchedItem: MatchedItem = MatchedItem(scannedItemName: "ExampleScannedName", genericItem: submittedGenericItem)
        
        try await userSuggestionHTTPManager.submitSuggestedMatchedItemAsync(matchedItem: submittedMatchedItem)
        
    }
    
    func testSuccessfulPostGenericItemUpdateTestAsync() async throws {
        let exampleOriginal: GenericItem = GenericItem(name: "Example Original", daysInFridge: 20.5, daysInFreezer: 20.5, daysOnShelf: 20.5, category: "Produce", subcategory: "Fresh", isCut: false, isCooked: false, isOpened: false, notes: "", links: "")
        
        let exampleUpdated: GenericItem = GenericItem(name: "Example Updated", daysInFridge: 203.3, daysInFreezer: 20.5, daysOnShelf: 20.5, category: "Produce", subcategory: "Fresh", isCut: false, isCooked: false, isOpened: false, notes: "", links: "")
        
        let updatedGenericItem = UserUpdatedGenericItem(Original: exampleOriginal, Updated: exampleUpdated)
        
        
        try await userSuggestionHTTPManager.submitSuggestedGenericItemUpdateAsync(updatedGenericItem: updatedGenericItem)
        
    }

}
