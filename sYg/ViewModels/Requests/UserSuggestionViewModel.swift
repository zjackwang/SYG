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
    private init () {
        addButtonSubscriber()
        addTextFieldsSubscriber()
    }
    
    private var userSuggestionHTTPManager: UserSuggestionHTTPManager = UserSuggestionHTTPManager(session: URLSession.shared)
    
    // For error handling
//    private let mvm = MainViewModel.shared
    
    // For recording user submission
    
    // used to update reminder
    @Published var genericItemToChange: GenericItem?
    
    @Published var title: String = "Suggest Changes"
    
    @Published var nameText: String = ""
    @Published var nameTextIsValid: Bool = false
    @Published var nameTextCount: Int = 0
    
    @Published var category: Category = .produce
    @Published var categorySelection: String = ""
    @Published var subcategory: String = ""
    
    @Published var daysInFridgeText: String = ""
    @Published var daysInFreezerText: String = ""
    @Published var daysOnShelfText: String = ""
    
    @Published var daysInFridgeTextIsValid: Bool = false
    @Published var daysInFreezerTextIsValid: Bool = false
    @Published var daysOnShelfTextIsValid: Bool = false

    @Published var daysInFridge: Double = 0
    @Published var daysInFreezer: Double = 0
    @Published var daysOnShelf: Double = 0
    
    @Published var isCut = false
    @Published var isCutSelection = "Uncut"
    @Published var isCooked = false
    @Published var isCookedSelection = "Uncooked"
    @Published var isOpened = false
    @Published var isOpenedSelection = "Unopened"
    
    @Published var link: String = ""
    
    @Published var showConfirmButton: Bool = false
    
    // Let listeners know when edits have finished
    @Published var showAlert: Bool = false
    @Published var alertText: String = "Success!"
    @Published var error: Error?
    @Published var showSuggestionView: Bool = false

    var cancellables = Set<AnyCancellable>()

    /*
     * MARK: Functions
     */
    
    func submitGenericItemSuggestion() {
        let item = saveEditsToGenericItem()
        Task {
            await suggestGenericItemAsync(genericItem: item)
            // Enough time to display message
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0, execute: {
                self.showAlert.toggle()
                print(self.showAlert)
            })
        }
    }
    
    func addButtonSubscriber() {
        $nameTextIsValid
            .combineLatest($daysInFridgeTextIsValid, $daysInFreezerTextIsValid, $daysOnShelfTextIsValid)
            .sink {
                [weak self]
                (isValid, isFridgeTextValid, isFreezerTextValid, isShelfTextValid) in
                guard let self = self else { return }
                if isValid && isFridgeTextValid && isFreezerTextValid && isShelfTextValid{
                    self.showConfirmButton = true
                } else {
                    self.showConfirmButton = false
                }
            }
            .store(in: &cancellables)
    }
    
    func addTextFieldsSubscriber() {
        $nameText
            .debounce(for: .seconds(0.5), scheduler: DispatchQueue.main)
            .map({ $0.count > 1 })
            .sink {
                [weak self]
                isValid in
                self?.nameTextIsValid = isValid
            }
            .store(in: &cancellables)
        
        $daysInFridgeText
            .debounce(for: .seconds(0.5), scheduler: DispatchQueue.main)
            .map({
                return $0.count > 0
                            && ((Double($0) ?? nil) != nil)
                            || $0.isEmpty
            })
            .sink {
                [weak self]
                isValid in
                self?.daysInFridgeTextIsValid = isValid
            }
            .store(in: &cancellables)
        
        $daysInFreezerText
            .debounce(for: .seconds(0.5), scheduler: DispatchQueue.main)
            .map({
                return $0.count > 0
                                && ((Double($0) ?? nil) != nil)
                                || $0.isEmpty
            })
            .sink {
                [weak self]
                isValid in
                self?.daysInFreezerTextIsValid = isValid
            }
            .store(in: &cancellables)
        
        $daysOnShelfText
            .debounce(for: .seconds(0.5), scheduler: DispatchQueue.main)
            .map({
                return $0.count > 0
                            && ((Double($0) ?? nil) != nil)
                            || $0.isEmpty
            })
            .sink {
                [weak self]
                isValid in
                self?.daysOnShelfTextIsValid = isValid
            }
            .store(in: &cancellables)
    }
    
    func setItemFields(from genericItem: GenericItem) {
        self.nameText = genericItem.Name
        self.category = CategoryConverter.fromRawValue(for: genericItem.Category)
        self.subcategory = genericItem.Subcategory
        self.daysInFridge = genericItem.DaysInFridge
        self.daysInFreezer = genericItem.DaysInFreezer
        self.daysOnShelf = genericItem.DaysOnShelf
        self.daysInFridgeText = "\(self.daysInFridge)"
        self.daysInFreezerText = "\(self.daysInFreezer)"
        self.daysOnShelfText = "\(self.daysOnShelf)"
        self.isCut = genericItem.IsCut ?? false
        self.isCooked = genericItem.IsCooked ?? false
        self.isOpened = genericItem.IsOpened ?? false
    }
    
    func saveEditsToGenericItem() -> GenericItem {
        self.daysInFridge = Double(self.daysInFridgeText) ?? 0.0
        self.daysInFreezer = Double(self.daysInFreezerText) ?? 0.0
        self.daysOnShelf = Double(self.daysOnShelfText) ?? 0.0
        
        let item = GenericItem(name: self.nameText, daysInFridge: self.daysInFridge, daysInFreezer: self.daysInFreezer, daysOnShelf: self.daysOnShelf, category: self.categorySelection, subcategory: self.subcategory, isCut: self.isCut, isCooked: self.isCooked, isOpened: self.isOpened, notes: "User Suggested Edit", links: self.link)
        self.resetFields()
        print("DEBUGGING >>>> SAVED ITEM: \(item)")
        return item
    }
    
    func resetFields() {
        self.nameText = ""
        self.category = .produce
        self.categorySelection = ""
        self.subcategory = ""
        self.daysInFridge = 0.0
        self.daysInFreezer = 0.0
        self.daysOnShelf = 0.0
        self.isCut = false
        self.isCooked = false
        self.isOpened = false
    }
    
    /*
     * Display error on main view if any routine returns one
     */
    func handleError(error: Error) {
        DispatchQueue.main.async {
            self.error = error
        }
    }
}

// MARK: Submitting suggestion functions
extension UserSuggestionViewModel {
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
}
