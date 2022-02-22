//
//  ContentView.swift
//  sYg
//
//  Based off tutorial from "Rebeloper" 
//
//  Created by Jack Wang on 2/18/22.
//

import SwiftUI

struct ContentView: View {
    
    @Environment(\.managedObjectContext) var managedObjectContext
    
    // Fetch core data entity with parameters
    @FetchRequest(
        entity: Item.entity(),
        sortDescriptors: [NSSortDescriptor(keyPath: \Item.name, ascending: true)],
        predicate: NSPredicate(format: "name == %@", "Shirt")
    ) var items: FetchedResults<Item>
    
    @FetchRequest(
        entity: ItemCategory.entity(),
        sortDescriptors: [NSSortDescriptor(keyPath: \ItemCategory.name, ascending: true)]
    ) var categories: FetchedResults<ItemCategory>
    
    @State private var isActionSheetPresented: Bool = false
    @State private var isAlertPresented: Bool = false
    
    var body: some View {
        VStack {
            Button {
                let category = ItemCategory(context: managedObjectContext)
                category.name = "Clothes"
                ScannedItemViewModel.shared.saveScannedItems()
            } label: {
                Text("Add Category")
            }
            Spacer()
            Button {
                if categories.count == 0 {
                    isAlertPresented.toggle()
                } else {
                    isActionSheetPresented.toggle()
                }
            } label: {
                Text("Add Item")
            }
            .actionSheet(isPresented: $isActionSheetPresented) {
                var buttons = [ActionSheet.Button]()
                categories.forEach { category in
                    let button = ActionSheet.Button.default(
                        Text("\(category.name ?? "unknown")")) {
                            // create item
                            let item = Item(context: managedObjectContext)
                            item.name = "Shirt"
                            print(category)
                            item.toCategory = category
                            // save item
                            ScannedItemViewModel.shared.saveScannedItems()
                        }
                    buttons.append(button)
                    }
                buttons.append(.cancel())
                return ActionSheet(
                    title: Text("Please select a category"),
                    message: nil,
                    buttons: buttons
                )
            }
            .alert("Please add a category", isPresented: $isAlertPresented) {
                Button("Ok", role: .cancel) {}
            }

            List {
                ForEach(items, id:\.self) {
                    item in
                    Text("\(item.name ?? "Unknown") - \(item.toCategory?.name ?? "Unknown")")
                }
                .onDelete(perform: removeItem)
            }
        }
    }
    
    func removeItem(at offsets: IndexSet) {
        for index in offsets {
            let item = items[index]
            ScannedItemViewModel.shared.deleteScannedItem(item)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
