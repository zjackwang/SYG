//
//  RecentlyScannedView.swift
//  sYg
//
//  Created by Jack Wang on 6/16/22.
//

import SwiftUI


struct RecentlyScannedView: View {
    private let mvm = MainViewModel.shared

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
                                Text(matchedItem.GenericItemName)
                                    .font(.headline)
                                    .fontWeight(.semibold)
                                    .foregroundColor(onBackground)
                            }
                            Image(systemName: "square.and.arrow.up")
                                .frame(maxWidth: 50)
                                .foregroundColor(onBackground)
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
