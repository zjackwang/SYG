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
 *  1.5. Create GneericItemViewModel
 *  2. Add search bar (view for now)
 *  3. Color it the same as main list for now
 *  4. Navigate via button in settings view
 *  5.
 */
struct GenericItemsView: View {
    @StateObject var givm = GenericItemViewModel.shared

    @State var rowNum: Int = 0
    let columns = [
            GridItem(.flexible(maximum: 100)), // Category
            GridItem(.flexible(maximum: 100)), // Name
            GridItem(.flexible(maximum: 100)), // Times
//                GridItem(.flexible()),
        ]
    
    private let background: Color = Color.DarkPalette.background
    private let onBackground: Color = Color.DarkPalette.onBackground
    private let primary: Color = Color.DarkPalette.primary
    

    var body: some View {
        VStack {
            headers
            
            List {
                ForEach($givm.genericItems, id: \.self) {
                    $item in
                    GenericItemListRowView(item: $item)
                    // Send Update
                    .swipeActions(edge: .leading, allowsFullSwipe: true) {
                        Button {
                            // TODO:
                        } label: {
                            Label("Report", systemImage: "exclamationmark.bubble.fill")
                        }
                        .tint(.yellow)
                    }
                }
                
            }
            .listStyle(.insetGrouped)
            .navigationTitle("Generic Items")
        }
        .searchable(text: $givm.searchText, prompt: givm.searchPrompt)
        .navigationBarTitleDisplayMode(.inline)
    }

}



struct GenericItemsView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            GenericItemsView()
        }
    }
}


extension GenericItemsView {
    // TODO:
    private var headers: some View {
        LazyVGrid(columns: columns, spacing: 30) {
            Text("Category")
                .font(.headline)
                .fontWeight(.semibold)
                .padding(.leading, 20)
                .foregroundColor(background)
            Text("Name")
                .font(.headline)
                .fontWeight(.semibold)
                .padding(.leading, 20)
                .foregroundColor(background)
            Text("Frg/Frzr/Slf")
                .font(.headline)
                .fontWeight(.semibold)
                .padding(.trailing, 10)
                .foregroundColor(background)
        }
    }
}
