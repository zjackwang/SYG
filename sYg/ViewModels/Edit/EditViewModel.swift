//
//  EditViewModel.swift
//  sYg
//
//  Created by Jack Wang on 3/31/22.
//

import SwiftUI
import Combine

class EditViewModel: ObservableObject {
    static let shared = EditViewModel()
    
    // Saved items
    @Published var scannedItems: [ScannedItem] = []
    
    // Unsaved unconfirmed items. subject to change
    @Published var itemsToConfirm: [UserItem] = UserItem.samples //[]
    
    @Published var nameText: String = ""
    @Published var nameTextIsValid: Bool = false
    @Published var nameTextCount: Int = 0
    
    @Published var category: Category = .produce
    @Published var purchaseDate: Date = Date.now
    @Published var remindDate: Date = Date.now
    
    @Published var showConfirmButton: Bool = false
    
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
    
    /*
     * Save
     *  - Name
     *  - Category
     *  - Purchase Date
     *  - Remind Date
     */
    func saveEditsToUserItem() -> UserItem {
        return UserItem(Name: nameText, DateOfPurchase: purchaseDate, DateToRemind: remindDate, Category: category)
    }
    
    /*
     * String id: id of item to be updated
     * UserItem newItem: new item with updated info
     */
    func updateUserItem(for id: String) {
        let i = itemsToConfirm.firstIndex(where: {$0.id == id})
        guard let i = i else { return }

        itemsToConfirm[i] = saveEditsToUserItem()
    }
    
    func resetFields(for id: String) {
        nameText = ""
        category = .produce
        purchaseDate = Date.now
        remindDate = Date.now
    }
}
