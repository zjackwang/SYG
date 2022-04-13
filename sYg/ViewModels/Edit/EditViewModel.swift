//
//  EditViewModel.swift
//  sYg
//
//  Created by Jack Wang on 3/31/22.
//

import SwiftUI
import Combine

class EditViewModel: ObservableObject {
    enum ViewToEdit {
        case confirmationView
        case userItemListView
        case manualAddView
    }
    
    static let shared = EditViewModel()
    
    // used to update reminder
    @Published var scannedItemToEdit: ScannedItem?
    
    @Published var title: String = "Edit Item Info"
    
    @Published var nameFromAnalysis: String = ""
    @Published var nameText: String = ""
    @Published var nameTextIsValid: Bool = false
    @Published var nameTextCount: Int = 0
    
    @Published var category: Category = .produce
    @Published var storage: Storage = .fridge
    @Published var categorySelection: String = ""
    @Published var storageSelection: String = ""
    
    @Published var purchaseDate: Date = Date.now
    @Published var remindDate: Date = Date.now
    
    @Published var showConfirmButton: Bool = false
    
    // Let listeners know when edits have finished
    @Published var confirmed: Bool = false
    @Published var viewToEdit: ViewToEdit = .confirmationView
    
    var cancellables = Set<AnyCancellable>()
    
    init() {
        addButtonSubscriber()
        addTextFieldSubscriber()
    }
    
    func addButtonSubscriber() {
        $nameTextIsValid
            .combineLatest($purchaseDate, $remindDate)
            .sink {
                [weak self]
                (isValid, purDate, remDate) in
                guard let self = self else { return }
                let now = Date.now
                if isValid && purDate <= now && remDate >= now {
                    self.showConfirmButton = true
                } else {
                    self.showConfirmButton = false
                }
            }
            .store(in: &cancellables)
    }
    
    func addTextFieldSubscriber() {
        $nameText
            .debounce(for: .seconds(0.5), scheduler: DispatchQueue.main)
            .map({ $0.count > 3 })
            .sink {
                [weak self]
                isValid in
                self?.nameTextIsValid = isValid
            }
            .store(in: &cancellables)
    }
    
    func setItemFields(nameFromAnalysis: String, name: String, purchaseDate: Date, remindDate: Date, category: Category, storage: Storage) {
        self.nameFromAnalysis = nameFromAnalysis
        self.nameText = name
        self.nameTextCount = name.count
        self.purchaseDate = purchaseDate
        self.remindDate = remindDate
        self.category = category
        self.storage = storage
        self.confirmed = false
    }
    
    /*
     * Save
     *  - Name
     *  - Category
     *  - Purchase Date
     *  - Remind Date
     */
    func saveEditsToUserItem() -> UserItem {
        print("DEBUGGING >>> SAVING EDITS")
        self.category = CategoryConverter.fromRawValue(for: self.categorySelection)
        self.storage = StorageConverter.fromRawValue(for: self.storageSelection)
        let item = UserItem(NameFromAnalysis: self.nameFromAnalysis, Name: self.nameText, DateOfPurchase: self.purchaseDate, DateToRemind: self.remindDate, Category: self.category, Storage: self.storage)
        print("DEBUGGING >>>> SAVED ITEM: \(item)")
        return item
    }
    
    func resetFields(for id: String) {
        self.nameText = ""
        self.category = .produce
        self.storage = .fridge
        self.purchaseDate = Date.now
        self.remindDate = Date.now
        self.confirmed = false
    }
}
