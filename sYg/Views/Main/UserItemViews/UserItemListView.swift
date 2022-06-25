//
//  UserItemListView.swift
//  SYG
//
//  Created by Jack Wang Dev Acc on 1/10/22.
//

import SwiftUI
import Combine
import UIKit

struct UserItemListView: View {
    @StateObject var evm = EditViewModel.shared
    @StateObject var mvm = MainViewModel.shared
    @StateObject var sivm = ScannedItemViewModel.shared

    @State var rowNum: Int = 0
    let columns = [
                GridItem(.flexible()),
                GridItem(.flexible()),
            ]
    
    private let background: Color = Color.DarkPalette.background
    private let onBackground: Color = Color.DarkPalette.onBackground
    private let primary: Color = Color.DarkPalette.primary
    
    // Shown Category
    @State var showCategoryPicker: Bool = false
    @State var shownCategory: String = "Produce"
    @State var itemsInCategory: Int = 0
    
    // Edit
    @State var showEdit = false
    @State var cancellables = Set<AnyCancellable>()
    
    var body: some View {
        ZStack {
            GeometryReader { reader in
                VStack(spacing: 0) {
                    categorySelector
                        .frame(width: reader.size.width - 80, alignment: .leading)
                        .padding([.top], 5)
                    
                    List {
                        Section {
                            ForEach($sivm.scannedItems) {
                                $item in
                                if item.category == shownCategory {
                                    UserItemView(
                                        item: $item,
                                        background: primary
                                    )
                                    .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                                        Button(role: .destructive) {
                                            EatByReminderManager.instance.removeScheduledReminderByName(for: item)
                                            // TODO: Handle error
                                            let _ =  sivm.removeScannedItem(item: item)
                                        } label: {
                                            Label("Eat", systemImage: "trash.fill")
                                        }
                                    }
                                    .swipeActions(edge: .leading, allowsFullSwipe: false) {
                                        // Edit Button
                                        Button {
                                            // Save item fields
                        //                            print("DEBUGGIN >>> item to edit: \(item)")
                                            let nameFromAnalysis = item.nameFromAnalysis ?? "unknown"
                                            evm.setItemFields(nameFromAnalysis: nameFromAnalysis, name: item.name ?? nameFromAnalysis, purchaseDate: item.dateOfPurchase ?? Date.now, remindDate: item.dateToRemind ?? Date.now, category: CategoryConverter.fromRawValue(for: item.category ?? "unknown"), storage: StorageConverter.fromRawValue(for: item.storage ?? "unknown"))
                                            
                                            // print("DEBUGGGING >>> cat picker: \(evm.category) storage picker: \(evm.storage)")
                                            // Edit sheet for this item
                                            evm.viewToEdit = .userItemListView
                                            evm.title = "Edit Item Info"
                                            showEdit.toggle()
                                            print("showEdit: \(showEdit)")
                                        } label: {
                                            Label("Edit", systemImage: "pencil.circle")
                                        }
                                        .tint(.yellow)
                                        
                                        // Flag Button
                                        Button {
                                            mvm.showIsGroceryItemAlert(item: item)
                                        } label: {
                                            Label("Flag", systemImage: "flag")
                                        }
                                        .tint(.orange)
                                    }
                                }
                            }
                            .listStyle(.insetGrouped)
                            .onAppear {
                                addSubscriberToEdit()
                                countItemsInCategory()
                            }
                        } header: {
                            Text("Item Name | Purchase Date | Eat-By Clock")
                                .font(.caption)
                                .fontWeight(.semibold)
                                .foregroundColor(onBackground)
                                .frame(width: reader.size.width - 80, alignment: .leading)
                        }
                    }
                }
            }
            emptyMessage
            
            EditSheetView(show: $showEdit)
        }
    }
}

struct UserItemListView_Previews: PreviewProvider {
    static var previews: some View {
        UserItemListView()
    }
}

// MARK: Functions
extension UserItemListView {
    func changeViewedCategory(newCategory: String) {
        // update displayed category
        shownCategory = newCategory
        countItemsInCategory()
    }
    
    func countItemsInCategory() {
        itemsInCategory = 0
        for item in sivm.scannedItems {
            if item.category == shownCategory {
                itemsInCategory += 1
            }
        }
    }

    func addSubscriberToEdit() {
        evm.$confirmed
            .combineLatest(evm.$viewToEdit)
            .sink { (isSuccessful, viewToEdit) in
                if isSuccessful,
                   viewToEdit == .userItemListView {

                    let newItem = evm.saveEditsToUserItem()
                  
//                    print("DEBUGGING >>> CONFIRM EDIT IN LIST VIEW")
                    
                    let result = sivm.updateScannedItem(newItem: newItem)
//                    print("DEBUGGING >>> new item: \(result)")
                    switch result {
                    case .success(let item):
                        // Update notification
                        EatByReminderManager.instance.updateScheduledNotification(for: item, at: newItem.DateToRemind)
                        print("INFO: Successfully updated item")
                        
                        // DEBUG
//                        print("DEBUGGING: ALL SCHEDULED NOTIFICATIONS ***")
//                        print(EatByReminderManager.instance.getAllScheduledNotifications())
                        
                    case .failure(let error):
                        mvm.error = error
                        print("FAULT: Item not updated")
                    }
                    DispatchQueue.main.async {
                        mvm.alertText = "Edit Saved!"
                        mvm.alertTitle = "Edit Result"
                        mvm.showAlert.toggle()
                    }
                }
            }
            .store(in: &cancellables)
    }
}

// MARK: Components
extension UserItemListView {
    private var categorySelector: some View {
        HStack {
           
            Text("Viewing: \(shownCategory)")
                .foregroundColor(onBackground)
                .contextMenu {
                    Button("Produce") {
                        changeViewedCategory(newCategory:"Produce")
                    }
                    Button("Meat, Poultry, Seafood") {
                        changeViewedCategory(newCategory:"Meat, Poultry, Seafood")
                    }
                    Button("Dairy") {
                        changeViewedCategory(newCategory: "Dairy")
                    }
                    Button("Condiments") {
                        changeViewedCategory(newCategory: "Condiments")
                    }
                    Button("Drinks") {
                        changeViewedCategory(newCategory: "Drinks")
                    }
                    Button("Cooked") {
                        changeViewedCategory(newCategory: "Cooked")
                    }
                    Button("Unknown") {
                        changeViewedCategory(newCategory: "Unknown")
                    }
                }
        }

    }
    
    private var headers: some View {
        LazyVGrid(columns: columns, spacing: 30) {
            Text("Item Name")
                .font(.headline)
                .fontWeight(.semibold)
                .padding(.leading, 20)
                .foregroundColor(onBackground)
            HStack(spacing: 14) {
                Text("Bought On")
                    .font(.subheadline)
                    .padding(.trailing, 10)
                    .foregroundColor(onBackground)
                Text("Eat By")
                    .font(.subheadline)
                    .padding(.trailing, 10)
                    .foregroundColor(onBackground)
            }
        }
    }
    
    private var emptyMessage: some View {
        Group {
            if sivm.scannedItems.isEmpty {
                VStack {
                    Text("Scan your first receipt to get started!")
                        .foregroundColor(onBackground)
                        .bold()
                        .padding()
                    Text("1. Use the 'Plus' button on the top right\n2. Swipe left on items to eat\n3. Swipe right to edit or flag as non-grocery\n4. Hold 'Viewing' to switch categories")
                        .foregroundColor(onBackground)
                        .frame(alignment: .center)
                    // MARK: TESTING
                        .onTapGesture(count: 2) {
                            // Populate with dummy data
                            //                        ScannedItemViewModel.shared.addSampleItems()
                        }
                }
            } else if itemsInCategory == 0 {
                Text("No items in this category.")
                    .foregroundColor(onBackground)
            }
            
        }
    }
}
