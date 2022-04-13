//
//  ConfirmationView.swift
//  sYg
//
//  Created by Jack Wang on 3/30/22.
//

import SwiftUI
import Combine

struct ConfirmationView: View {
    @StateObject private var ckvm = CloudKitViewModel.shared
    @StateObject private var sivm = ScannedItemViewModel.shared
    @StateObject private var mvm = MainViewModel.shared
    @StateObject private var evm = EditViewModel.shared
    @StateObject private var cvm = ConfirmationViewModel.shared
    
    @Binding var show: Bool
    
    @State var showEdit = false
    @State var editID = ""
    @State var cancellables = Set<AnyCancellable>()
    
    var body: some View {
        ZStack {
            background
            VStack {
                Spacer()
                title
                List {
                    ForEach(cvm.itemsToConfirm, id: \.self) {
                        item in
                        ToConfirmItemRow(item: item)
                            .swipeActions(edge: .trailing, allowsFullSwipe: true, content: {
                                Button(role: .destructive) {
                                    cvm.deleteItem(item: item)
                                } label: {
                                    Label("Delete", systemImage: "trash.fill")
                                }
                            })
                            .swipeActions(edge: .leading, allowsFullSwipe: true) {
                                Button{
                                    editID = item.id
                                    // set attributes in the edit view model
                                    evm.setItemFields(nameFromAnalysis: item.NameFromAnalysis, name: item.Name, purchaseDate: item.DateOfPurchase, remindDate: item.DateToRemind, category: item.Category, storage: item.Storage)
                                    // Edit sheet for this item
                                    evm.title = "Edit Item Info"
                                    showEdit.toggle()
                                } label: {
                                    Label("Edit", systemImage: "pencil.circle")
                                }
                                .tint(.green)
                            }
                    }
                }
                .listStyle(.plain)

                Button {
                    ckvm.updateCloudDatabase(confirmedItems: cvm.itemsToConfirm)
                    mvm.addConfirmedUserItems(confirmedItems: cvm.itemsToConfirm)
                    show.toggle()
                } label: {
                    ConfirmButtonLabel(text: "Confirm", height: 50, width: 300)
                }
                .padding([.bottom], 50)
            }
            .overlay(overlay)
        }
        .onAppear(perform: {
            evm.viewToEdit = .confirmationView
            // create publisher and subscribe to edits
            addEditViewSubscriber()
            testAddPickerSubscriber()
        })
        .opacity(show ? 1.0 : 0.0)
        .navigationBarHidden(show)
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
    
    private var title: some View {
        Text("Scanned Items Results")
            .font(.title)
            .foregroundColor(titleColor)
            .padding([.top], 50)
    }
    
    private var overlay: some View {
        Group {
            Spacer()
            EditSheetView(show: $showEdit)
        }
    }
    
    struct ToConfirmItemRow: View {
        @State var item: UserItem

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

// MARK: Functions
extension ConfirmationView {
    func addEditViewSubscriber() {
        evm.$confirmed
            .combineLatest(evm.$viewToEdit)
            .sink { (isConfirmed, viewToEdit) in
                if viewToEdit == .confirmationView,
                   isConfirmed {
                    print("DEBUGG >>> CONFIRM EDIT IN CONFIRMATION VIEW")
                    cvm.updateUserItem(for: editID)
                }
            }
            .store(in: &cancellables)
    }
    
    func testAddPickerSubscriber() {
        evm.$category
            .sink { category in
                print(CategoryConverter.rawValue(given: category))
            }
            .store(in: &cancellables)
    }
}

struct DisplayConfirmationView: View {
    @State var showView = false

    var body: some View {
        ZStack {
            VStack {
                Button {
                    ScannedItemViewModel.shared.removeAllItems()
                    ScannedItemViewModel.shared.addSampleItems()
                    showView.toggle()
                } label: {
                    Text("Show View")
                }
            }
                
            ConfirmationView(show: $showView)
        }
        
        
    }
}
struct ConfirmationSheetView_Previews: PreviewProvider {
    static var previews: some View {
        DisplayConfirmationView()
    }
}
