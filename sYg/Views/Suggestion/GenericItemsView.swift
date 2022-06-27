//
//  GenericItemView.swift
//  sYg
//
//  Created by Jack Wang on 4/19/22.
//

import SwiftUI

/*
 * Displays searchable list of generic items
 */

/*
 * Dev considerations
 *  1. Create generic item list row view => Done
 *  1.5. Create GneericItemViewModel DONE
 *  2. Add search bar (view for now) DONE
 
 *  4. Navigate via button in main view
 *  5. Swipe right to suggest edit
 */
struct GenericItemsView: View {
    @StateObject private var givm = GenericItemViewModel.shared
    @StateObject private var usvm = UserSuggestionViewModel.shared
    private var gisvm = GenericItemSuggestionViewModel.shared
    private var misvm = MatchedItemSuggestionViewModel.shared

    @State var rowNum: Int = 0
    
    private let background: Color = Color.DarkPalette.background
    private let onBackground: Color = Color.DarkPalette.onBackground
    private let primary: Color = Color.DarkPalette.primary
    private let secondary: Color = Color.DarkPalette.secondary
    
    @State private var popoverItem: GenericItem?
    @State private var showPopover: Bool = false
    
    var body: some View {
        ZStack {
            background
                .ignoresSafeArea()
            
            initialInfoMessage
            
            List {
                Section {
                    ForEach($givm.displayedGenericItems, id: \.self) {
                        $item in
                        GenericItemListRowView(item: $item)
                        .padding([.top, .bottom], 10)
                        // Suggest a match or a update to generic item
                        .swipeActions(edge: .leading, allowsFullSwipe: true) {
                            Button {
                                if usvm.suggestionType == .SuggestGenericItem {
                                    gisvm.setTitle(newTitle: "Suggest Changes")
                                    gisvm.setItemFields(from: item)
                                    usvm.showGenericItemSuggestionView.toggle()
                                } else {
                                    misvm.setGenericItem(genericItem: item)
                                    usvm.showMatchedItemSuggestionView.toggle()
                                }
                            } label: {
                                Label("Suggest", systemImage: "exclamationmark.bubble.fill")
                            }
                            .tint(.yellow)
                        }
                        .onTapGesture {
                            popoverItem = item
                            showPopover.toggle()
                        }
                    }
                } header: {
                    Text(givm.header)
                }
            }
            .onTapGesture {
                if givm.searchText.isEmpty && usvm.suggestionType == .SuggestGenericItem {
                    gisvm.setTitle(newTitle: "Suggest New Item")
                    usvm.showGenericItemSuggestionView.toggle()
                }
            }
            .listStyle(.insetGrouped)
            .searchable(text: $givm.searchText, placement: .navigationBarDrawer(displayMode: .always), prompt: givm.searchPrompt)
            .onChange(of: givm.searchText, perform: givm.userSearched) 
        }
        .navigationTitle("Generic Items")
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $usvm.showGenericItemSuggestionView) {
            GenericItemSuggestionView()
        }
        .sheet(isPresented: $usvm.showMatchedItemSuggestionView, content: {
            MatchedItemSuggestionView()
        })
        .popover(isPresented: $showPopover, attachmentAnchor: .rect(.bounds), arrowEdge: .top, content: {
            GenericItemView(genericItem: $popoverItem)
        })
        .alert(isPresented: $usvm.showAlert) {
            return Alert(
                title: Text("Suggestion result"),
                message: Text(usvm.error?.localizedDescription ?? usvm.alertText),
                dismissButton:
                    .default(
                        Text("Ok"),
                        action: {
                        }
                   )
            )

        }
    }

}

// MARK: Components
extension GenericItemsView {
    private var initialInfoMessage: some View {
        VStack {
            Text(givm.title)
                .font(.title2)
                .fontWeight(.medium)
            Text("Tap on item to see more info")
                .font(.subheadline)
                .fontWeight(.regular)
            Text(givm.message)
                .font(.subheadline)
                .fontWeight(.regular)
            // Suggest new Generic Item
            Text(givm.manualAddText)
                .font(.subheadline)
                .fontWeight(.regular)
                .opacity(usvm.suggestionType == .SuggestGenericItem ? 1.0 : 0.0)
            Text("For: \(misvm.matchedItem?.ScannedItemName ?? "NIL")")
                .font(.subheadline)
                .fontWeight(.regular)
                .opacity(usvm.suggestionType == .SuggestMatchedItem ? 1.0 : 0.0)
        }
        .opacity(givm.searchText.isEmpty ? 1.0 : 0.0)
    }
    
    

}

struct GenericItemsView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            GenericItemsView()
        }
    }
}

struct GenericItemView: View {
    @Binding var genericItem: GenericItem?
    
    var body: some View {
        Form {
            VStack {
                name
                category
                subcategory
                daysInFridge
                daysInFreezer
                daysOnShelf
                HStack {
                    isCut
                    isCooked
                    isOpened
                }
            }
        }
    }
}

extension GenericItemView {
    private var name: some View {
        HStack {
            Text("Name: ")
            Text(genericItem?.Name ?? "NIL")
                .foregroundColor(.white)
        }
    }
    
    private var category: some View {
        HStack {
            Text("Category: ")
            Text(genericItem?.Category ?? "NIL")
                .foregroundColor(.white)
        }
    }
    
    private var subcategory: some View {
        HStack {
            Text("Subcategory: ")
            Text(genericItem?.Subcategory ?? "NIL")
                .foregroundColor(.white)
        }
    }
    
    private var daysInFridge: some View {
        HStack {
            Text("Days In Fridge: ")
            Text(genericItem?.DaysInFridge.formatted ?? "N/A")
                .foregroundColor(.white)
        }
    }
    
    private var daysInFreezer: some View {
        HStack {
            Text("Days In Freezer: ")
            Text(genericItem?.DaysInFreezer.formatted ?? "N/A")
                .foregroundColor(.white)
        }
    }
    
    private var daysOnShelf: some View {
        HStack {
            Text("Days On Shelf: ")
            Text(genericItem?.DaysOnShelf.formatted ?? "N/A")
                .foregroundColor(.white)
        }
    }
    
    private var isCut: some View {
        HStack {
            Text("Is Cut: ")
            ZStack {
                Image(systemName: "xmark")
                    .foregroundColor(.red)
                    .opacity(
                        genericItem?.IsCut ?? false ? 0.0 : 1.0)
                
                Image(systemName: "checkmark")
                    .foregroundColor(.green)
                    .opacity(genericItem?.IsCut ?? false ? 1.0: 0.0)
            }
        }
    }
    
    private var isCooked: some View {
        HStack {
            Text("Is Cooked: ")
            ZStack {
                Image(systemName: "xmark")
                    .foregroundColor(.red)
                    .opacity(
                        genericItem?.IsCooked ?? false ? 0.0 : 1.0)
                
                Image(systemName: "checkmark")
                    .foregroundColor(.green)
                    .opacity(genericItem?.IsCooked ?? false ? 1.0: 0.0)
            }
        }
    }
    
    private var isOpened: some View {
        HStack {
            Text("Is Opened: ")
            ZStack {
                Image(systemName: "xmark")
                    .foregroundColor(.red)
                    .opacity(
                        genericItem?.IsCooked ?? false ? 0.0 : 1.0)
                
                Image(systemName: "checkmark")
                    .foregroundColor(.green)
                    .opacity(genericItem?.IsCooked ?? false ? 1.0: 0.0)
            }
        }
    }
}
