//
//  GenericItemSuggestionViewModel.swift
//  sYg
//
//  Created by Jack Wang on 6/19/22.
//

import Foundation
import Combine 

class GenericItemSuggestionViewModel: ObservableObject {
    
    // MARK: Initialization
    static let shared = GenericItemSuggestionViewModel()
    private init () {
        addButtonSubscriber()
        addTextFieldsSubscriber()
    }
    
    private let usvm: UserSuggestionViewModel = UserSuggestionViewModel.shared

    var title: String = "Suggest Changes"

    // For recording user submission
    @Published var genericItemToChange: GenericItem?
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
    
    // For combine 
    var cancellables = Set<AnyCancellable>()
            
    // MARK: Functions
    func submitGenericItemSuggestion() {
        let item = saveEditsToGenericItem()
        Task {
            // Updating existing
            if let genericItemToChange = genericItemToChange {
                let updatedItem = UserUpdatedGenericItem(Original: genericItemToChange, Updated: item)
                await usvm.suggestGenericItemUpdateAsync(userUpdatedGenericItem: updatedItem)
            } else {
                // New item suggestion
                await usvm.suggestGenericItemAsync(genericItem: item)
            }
            // Enough time to display message
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0, execute: {
                self.usvm.showSuggestionAlert()
                self.resetFields()
            })
        }
    }
    
    func setTitle(newTitle: String) {
        self.title = newTitle
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
        self.genericItemToChange = genericItem
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
        
        let item = GenericItem(name: self.nameText, daysInFridge: self.daysInFridge, daysInFreezer: self.daysInFreezer, daysOnShelf: self.daysOnShelf, category: self.categorySelection, subcategory: self.subcategory, isCut: self.isCut, isCooked: self.isCooked, isOpened: self.isOpened, notes: "User Suggested", links: self.link)
        print("DEBUGGING >>>> SAVED ITEM: \(item)")
        return item
    }
    
    func resetFields() {
        self.genericItemToChange = nil
        self.nameText = ""
        self.category = .produce
        self.categorySelection = ""
        self.subcategory = ""
        self.daysInFridge = 0.0
        self.daysInFreezer = 0.0
        self.daysOnShelf = 0.0
        self.daysInFridgeText = ""
        self.daysInFreezerText = ""
        self.daysOnShelfText = ""
        self.isCut = false
        self.isCooked = false
        self.isOpened = false
    }
}
