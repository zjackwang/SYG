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
    
    private var nameFromAnalysis: String = ""
    @Published var nameText: String = ""
    @Published var nameTextIsValid: Bool = false
    @Published var nameTextCount: Int = 0
    
    @Published var category: Category = .produce
    @Published var purchaseDate: Date = Date.now
    @Published var remindDate: Date = Date.now
    
    @Published var showConfirmButton: Bool = false
    
    // Let listeners know when edits have finished
    @Published var confirmed: Bool = false
    
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
    
    func setItemFields(nameFromAnalysis: String, name: String, purchaseDate: Date, remindDate: Date, category: Category) {
        self.nameText = name
        self.nameTextCount = name.count
        self.purchaseDate = purchaseDate
        self.remindDate = remindDate
        self.category = category
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
        print(self.nameText)
        print(self.purchaseDate)
        print(self.remindDate)
        print(self.category)
        return UserItem(NameFromAnalysis: self.nameFromAnalysis, Name: self.nameText, DateOfPurchase: self.purchaseDate, DateToRemind: self.remindDate, Category: self.category)
    }
    
    func resetFields(for id: String) {
        self.nameText = ""
        self.category = .produce
        self.purchaseDate = Date.now
        self.remindDate = Date.now
        self.confirmed = false
    }
}
