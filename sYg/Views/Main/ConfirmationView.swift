//
//  ConfirmationView.swift
//  sYg
//
//  Created by Jack Wang on 3/30/22.
//

import SwiftUI

struct ConfirmationView: View {
    @StateObject private var ckvm = CloudKitViewModel.shared
    @StateObject private var vm = EditViewModel.shared
    
    @State var showEdit = false
    @State var editID = ""
    @State var showAlert = false
    @State var alertText = ""
    
    var body: some View {
        
        ZStack {
            background
                .opacity(0.75)
            VStack {
                Spacer()
                Text("Scanned Items Results")
                    .font(.title)
                    .foregroundColor(titleColor)
                    .padding([.top], 50)
                    
                List {
                    ForEach(vm.itemsToConfirm, id: \.self) {
                        item in
                        ScannedItemRow(item: item)
                            .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                                Button("Edit") {
                                    // Edit sheet for this item
                                    showEdit.toggle()
                                    editID = item.id
                                }
                                .tint(.green)
                            }
                    }
                }
                .listStyle(.plain)

                Button {
                    // TODO: send over to main view model for saving to core data 
                } label: {
                    ConfirmButtonLabel(text: "Confirm", height: 50, width: 300)
                }
                .padding([.bottom], 50)

            }
            .overlay(EditSheetView(show: $showEdit, id: $editID))
            .alert(isPresented: $showAlert) {
                Alert(title: Text("Edit Alert"), message: Text(alertText), dismissButton: .default(Text("Ok"), action: {
                    showAlert.toggle()
                }))
            }
        }
    }
    
}

// MARK: Components
extension ConfirmationView {
    
    private var titleColor: Color {
        Color.DarkPalette.background
    }
    private var background: Color {
        Color.DarkPalette.onPrimary
    }
    
    struct ScannedItemRow: View {
        @State var item: UserItem
        
        // Controls
        @State private var editName: Bool = false
        @State private var editCategory: Bool = false
        @State private var editDateOfPurchase: Bool = false
        @State private var editDateToRemind: Bool = false

        @State private var newName: String = ""
        @State private var newCategory: String = ""
        @State private var newDateOfPurchase: Date = Date.now
        @State private var newDateToRemind: Date = Date.now
        
        // UI
        let columns = [
                    GridItem(.flexible()),
                    GridItem(.flexible()),
                    GridItem(.flexible()),
                ]
        
        let textColor = Color.DarkPalette.primary
        let background = Color.DarkPalette.onPrimary
        
        var body: some View {
            LazyVGrid(columns: columns, spacing: 15) {
                Text(item.Name)
                    .font(.headline)
                    .fontWeight(.semibold)
                    .padding(.leading, 10)
                    .foregroundColor(textColor)
                    .opacity(editName ? 0.0: 1.0)
                    .onLongPressGesture {
                        editName.toggle()
                    }
                
                Text(CategoryConverter.rawValue(given: item.Category))
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .padding(.leading, 10)
                    .foregroundColor(textColor)
                
                VStack {
                    Text("PUR: \(item.DateOfPurchase.getFormattedDate(format: TimeConstants.reminderDateFormat))"
                    )
                        .font(.subheadline)
                        .padding(.trailing, 20)
                        .foregroundColor(textColor)
                    Text("EXP: \(item.DateToRemind.getFormattedDate(format: TimeConstants.reminderDateFormat))"
                    )
                        .font(.subheadline)
                        .padding(.trailing, 20)
                        .foregroundColor(textColor)
                }
            }
            .listRowBackground(
                background
                    .opacity(0.5)
            )
        }
    }
}


struct DisplayConfirmationView: View {
    @State var showView = false

    var body: some View {
        VStack {
            Button {
                ScannedItemViewModel.shared.removeAllItems()
                ScannedItemViewModel.shared.addSampleItems()
                showView.toggle()
            } label: {
                Text("Show View")
            }
        }
        .sheet(isPresented: $showView) {
            ConfirmationView()
        }
    }
}
struct ConfirmationSheetView_Previews: PreviewProvider {
    static var previews: some View {
        DisplayConfirmationView()
    }
}
