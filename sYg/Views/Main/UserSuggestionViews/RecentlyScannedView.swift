//
//  RecentlyScannedView.swift
//  sYg
//
//  Created by Jack Wang on 6/16/22.
//

import SwiftUI


struct RecentlyScannedView: View {
    private let mvm = MainViewModel.shared
    private let usvm = UserSuggestionViewModel.shared
    private let misvm = MatchedItemSuggestionViewModel.shared

    @State var showGenericItemsView: Bool = false
    
    private let background: Color = Color.DarkPalette.background
    private let onBackground: Color = Color.DarkPalette.onBackground
    
    private let columns = [
                GridItem(.flexible()),
                GridItem(.fixed(75)),
            ]
    
    var body: some View {
        ZStack {
            // background
            background
                .ignoresSafeArea()
            
            // Generic Items 
            NavigationLink(isActive: $showGenericItemsView) {
                GenericItemsView()
            } label: {
                EmptyView()
            }
            
            // content
            List {
                Section {
                    ForEach(mvm.matchedItems, id: \.self) {
                        matchedItem in
                        LazyVGrid(columns: columns, spacing: 20) {
                            HStack(spacing: 20) {
                                Text(matchedItem.ScannedItemName)
                                    .font(.headline)
                                    .fontWeight(.semibold)
                                    .foregroundColor(onBackground)
                                Text(matchedItem.GenericItemObj?.Name ?? "N/A")
                                    .font(.headline)
                                    .fontWeight(.semibold)
                                    .foregroundColor(onBackground)
                            }
                            Image(systemName: "square.and.arrow.up")
                                .frame(maxWidth: 50)
                                .foregroundColor(onBackground)
                                .onTapGesture {
                                    misvm.setMatchedItem(matchedItem: matchedItem)
                                    usvm.setSuggestionType(suggestionType: .SuggestMatchedItem)
                                    showGenericItemsView.toggle()
                                }
                        }
                    }
                } header: {
                    Text("Scanned | Match | Suggest")
                        .foregroundColor(onBackground)
                }
            }
            .navigationTitle("Recently Scanned")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

struct RecentlyScannedView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            RecentlyScannedView()
        }
    }
}

// MARK: Components
extension RecentlyScannedView {
}
