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
    @StateObject var givm = GenericItemViewModel.shared
    @StateObject var usvm = UserSuggestionViewModel.shared

    @State var rowNum: Int = 0
    
    private let background: Color = Color.DarkPalette.background
    private let onBackground: Color = Color.DarkPalette.onBackground
    private let primary: Color = Color.DarkPalette.primary
    private let secondary: Color = Color.DarkPalette.secondary
    
    @State private var popoverItem: GenericItem?
    @State private var showPopover: Bool = false
    
    var body: some View {
        ZStack {
            VStack {
                Text("Pull down and search Generic Items")
                    .font(.title2)
                    .fontWeight(.medium)
//                Text("Tap to see more info")
//                    .font(.subheadline)
//                    .fontWeight(.regular)
                Text(givm.editMessage)
                    .font(.subheadline)
                    .fontWeight(.regular)
                
                
            }
            .opacity(givm.searchText.isEmpty ? 1.0 : 0.0)
            
            List {
                Section {
                    ForEach($givm.displayedGenericItems, id: \.self) {
                        $item in
                        GenericItemListRowView(item: $item)
                        .padding([.top, .bottom], 10)
                        .popover(isPresented: $showPopover,
                                 attachmentAnchor: .point(.bottom) ,
                                 arrowEdge: .bottom) {
//                            genericItemInfoPopover
                            Rectangle().frame(height: 100).foregroundColor(Color.blue)
                        }
                        // Send Update
                        .swipeActions(edge: .leading, allowsFullSwipe: true) {
                            Button {
                                usvm.setItemFields(from: item)
                                usvm.showSuggestionView.toggle()
                            } label: {
                                Label("Report", systemImage: "exclamationmark.bubble.fill")
                            }
                            .tint(.yellow)
                        }
                        .onTapGesture {
                            popoverItem = item
                            showPopover.toggle()
                        }
                    }
                } header: {
                    Text("Days: Fridge | Freezer | Shelf")
                }
            }
            .listStyle(.inset)
            .searchable(text: $givm.searchText, placement: .toolbar, prompt: givm.searchPrompt)
            .onChange(of: givm.searchText, perform: givm.userSearched)
        }
        .navigationTitle("Generic Items")
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $usvm.showSuggestionView) {
            GenericItemSuggestionView()
        }
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
    
    private var genericItemInfoPopover: some View {
        ZStack {
            Rectangle()
                .foregroundColor(.gray)
            Text("Generic Item")
        }
        .frame(width: 100, height: 100)
    }
}

struct GenericItemsView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            GenericItemsView()
        }
    }
}
