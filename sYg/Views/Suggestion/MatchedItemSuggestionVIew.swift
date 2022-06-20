//
//  MatchedItemSuggestionView.swift
//  sYg
//
//  Created by Jack Wang on 6/19/22.
//

import SwiftUI

struct MatchedItemSuggestionView: View {
    
    private let misvm = MatchedItemSuggestionViewModel.shared
    private let usvm = UserSuggestionViewModel.shared
    
    var body: some View {
        ZStack {
            Form {
                Text(misvm.title)
                    .font(.title)
                
                // Scanned Item Name
                HStack {
                    Text("Scanned Item: ")
                        .foregroundColor(.gray)
                    Text("\(misvm.matchedItem?.ScannedItemName ?? "NIL")")
                        .foregroundColor(.white)
                }
                Text("Generic Item to match: ")
                    .foregroundColor(.gray)
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
                .foregroundColor(.gray)
                
                Button {
                    usvm.showMatchedItemSuggestionView.toggle()
                } label: {
                    Text("Cancel")
                }
                
                Button {
                    // save form
                    misvm.submitMatchedItemSuggestion()
                    usvm.showMatchedItemSuggestionView.toggle()
                } label: {
                    Text("Save")
                }
            }
        }
    }
}

// MARK: Components
extension MatchedItemSuggestionView {
    private var name: some View {
        HStack {
            Text("Name: ")
            Text("\(misvm.genericItem?.Name ?? "NIL")")
                .foregroundColor(.white)
        }
    }
    
    private var category: some View {
        HStack {
            Text("Category: ")
            Text("\(misvm.genericItem?.Category ?? "NIL")")
                .foregroundColor(.white)
        }
    }
    
    private var subcategory: some View {
        HStack {
            Text("Subcategory: ")
            Text("\(misvm.genericItem?.Subcategory ?? "NIL")")
                .foregroundColor(.white)
        }
    }
    
    private var daysInFridge: some View {
        HStack {
            Text("Days In Fridge: ")
            Text("\(misvm.genericItem?.DaysInFridge.formatted ?? "N/A")")
                .foregroundColor(.white)
        }
    }
    
    private var daysInFreezer: some View {
        HStack {
            Text("Days In Freezer: ")
            Text("\(misvm.genericItem?.DaysInFreezer.formatted ?? "N/A")")
                .foregroundColor(.white)
        }
    }
    
    private var daysOnShelf: some View {
        HStack {
            Text("Days On Shelf: ")
            Text("\(misvm.genericItem?.DaysOnShelf.formatted ?? "N/A")")
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
                        misvm.genericItem?.IsCut ?? false ? 0.0 : 1.0)
                
                Image(systemName: "checkmark")
                    .foregroundColor(.green)
                    .opacity(misvm.genericItem?.IsCut ?? false ? 1.0: 0.0)
            }
        }
        .opacity(misvm.genericItem?.IsCut ?? nil == nil ? 0.0 : 1.0)
    }
    
    private var isCooked: some View {
        HStack {
            Text("Is Cooked: ")
            ZStack {
                Image(systemName: "xmark")
                    .foregroundColor(.red)
                    .opacity(
                        misvm.genericItem?.IsCooked ?? false ? 0.0 : 1.0)
                
                Image(systemName: "checkmark")
                    .foregroundColor(.green)
                    .opacity(misvm.genericItem?.IsCooked ?? false ? 1.0: 0.0)
            }
        }
        .opacity(misvm.genericItem?.IsCooked ?? nil == nil ? 0.0 : 1.0)
    }
    
    private var isOpened: some View {
        HStack {
            Text("Is Opened: ")
            ZStack {
                Image(systemName: "xmark")
                    .foregroundColor(.red)
                    .opacity(
                        misvm.genericItem?.IsOpened ?? false ? 0.0 : 1.0)
                
                Image(systemName: "checkmark")
                    .foregroundColor(.green)
                    .opacity(misvm.genericItem?.IsOpened ?? false ? 1.0: 0.0)
            }
        }
        .opacity(misvm.genericItem?.IsOpened ?? nil == nil ? 0.0 : 1.0)
    }
}
