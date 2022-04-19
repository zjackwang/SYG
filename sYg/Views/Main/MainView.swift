//
//  MainViw.swift
//  sYg
//
//  Created by Jack Wang on 4/19/22.
//

import SwiftUI
import Combine

/*
 * Landing View
 *
 * Roles:
 *  - Display (Multiple) Scanned Item View(s)
 *  - Navigation Hub
 *  - (for now) Adds Items
 *  - Displays Alerts
 */
struct MainView: View {
    // View Models
    @StateObject private var mvm = MainViewModel.shared
    @StateObject private var sivm = ScannedItemViewModel.shared
    @StateObject private var evm = EditViewModel.shared
    @StateObject var givm = GenericItemViewModel.shared
    
    // Color Palette
    private let background: Color = Color.DarkPalette.background
    private let surface: Color = Color.DarkPalette.surface
    private let onBackground: Color = Color.DarkPalette.onBackground
    private let primary: Color = Color.DarkPalette.primary
    private let secondary: Color = Color.DarkPalette.secondary
    
    var body: some View {
        NavigationView {
            ZStack {
                // Background
                background
                    .ignoresSafeArea()
             
                // Content
                UserItemListView(scannedItems: $sivm.scannedItems)
                    .sheet(isPresented: $mvm.showSelector) {
                        // Receipt Selector
                        ReceiptSelector(receipt: $mvm.receipt, sourceType: mvm.source == .library ? .photoLibrary : .camera, showPopover: $mvm.showScannedReceipt)
                            .ignoresSafeArea()
                    }
                // Progress Dialog
                ProgressDialog(show: $mvm.showProgressDialog, message: $mvm.progressMessage)
                
                // User prompt confirmation of Receipt photo
                ScannedReceiptPopover(showPopover: $mvm.showScannedReceipt)
                    .padding([.top], 2)
                    .offset(y: mvm.showScannedReceipt ? 0 : UIScreen.main.bounds.height)
                    .transition(.asymmetric(
                        insertion: .move(edge: .trailing),
                        removal: .move(edge: .leading)))
                
            }
            // Top toolbar
            .toolbar {
                ToolbarItemGroup(placement: .navigationBarLeading) { IconBrand }
                ToolbarItemGroup(placement: .navigationBarTrailing) { ToolbarButtons }
            }
            // User confirmation alert
            .alert(isPresented: $mvm.showAlert) {
                var msgString: String?
                if let error = mvm.error as? ReceiptScanningError {
                    msgString = "Error: \(error.localizedDescription)"
                } else if let error = mvm.error as? EatByReminderError {
                    msgString = "Error: \(error.localizedDescription)"
                } else if let error = mvm.error {
                    msgString = "Error: \(error.localizedDescription)"
                } else if let error = mvm.error as? Selector.SelectorError {
                    mvm.alertTitle = "Scanning Error"
                    msgString = error.errorDescription
                } else {
                    msgString = mvm.confirmationText
                }
                
                return Alert(
                        title: Text(mvm.alertTitle),
                        message: Text(msgString ?? ""),
                        dismissButton:
                                .default(
                                    Text("Ok"),
                                    action: {
                                            mvm.showAlert.toggle()
                                    }
                               )
                        )
            }
        }
        .navigationTitle("Main Page")
    }
}

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        MainView()
    }
}

// MARK: Components

extension MainView {
    private var IconBrand: some View {
        HStack(spacing: 15) {
            Image("icon")
                .frame(maxWidth: 10)
                .padding(20)
            Text("EatThat!")
                .font(.title)
                .fontWeight(.bold)
                .foregroundColor(onBackground)
        }
    }
    
    private var ToolbarButtons: some View {
        HStack {
            // Scan Receipts
            Image(systemName: "plus.app")
                .foregroundColor(onBackground)
                .onTapGesture {
                    mvm.selectReceipt.toggle()
                }
                .confirmationDialog(Text("Scan Receipt"), isPresented: $mvm.selectReceipt) {
                    Button {
                        mvm.source = .camera
                        mvm.showReceiptSelector()
                    } label: {
                        Text("Scan Receipt")
                    }
                    Button  {
                        mvm.source = .library
                        mvm.showReceiptSelector()
                    } label: {
                        Text("Choose From Library")
                    }
                    
                    // Manual add
                    Button {
                        evm.viewToEdit = .manualAddView
                        evm.title = "Add New Item"
                        mvm.showEdit.toggle()
                    } label: {
                        Text("Add Item Manually")
                    }
                }
            // Settings
            NavigationLink {
                SettingsView()
            } label: {
                Image(systemName: "slider.horizontal.3")
                    .foregroundColor(onBackground)
                    .padding()
            }

            
        }
    }
}
