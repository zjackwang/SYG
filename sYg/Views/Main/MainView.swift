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

/*
 * MARK: Beta 2.2.
 *   - removed ConfirmationView
 *   - combined confirmation alerts and scanning alerts
 *   - replaced settings sheet with settings nav link
 *   - added generic item list view accessible via nav link in settings view
 *   - moved addSubscribedToEdit to vm
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
                    .ignoresSafeArea()
                
                // User prompt confirmation of Receipt photo
                ScannedReceiptPopover(showPopover: $mvm.showScannedReceipt)
                    .padding([.top], 2)
                    .offset(y: mvm.showScannedReceipt ? 0 : UIScreen.main.bounds.height)
                    .transition(.asymmetric(
                        insertion: .move(edge: .trailing),
                        removal: .move(edge: .leading)))
                
                // Manual edit
                EditSheetView(show: $mvm.showEdit)
                
                // "See more"
                RecentlyScannedNavLink
            }
            // Top toolbar
            .toolbar {
                ToolbarItemGroup(placement: .navigationBarLeading) { IconBrand }
                ToolbarItemGroup(placement: .navigationBarTrailing) { ToolbarButtons }
            }
            // User confirmation alert
            .alert(isPresented: $mvm.showAlert) {
                
                if mvm.showNavPrompt {
                    return Alert(
                        title: Text(mvm.alertTitle),
                        message: Text(getMessageString(error: mvm.error)),
                        primaryButton:
                                .destructive(Text("See More")) {
                                    mvm.navToRecentlyScanned.toggle()
                        },
                        secondaryButton: .cancel()
                        )
                } else {
                    return Alert(
                        title: Text(mvm.alertTitle),
                        message: Text(getMessageString(error: mvm.error)),
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
        }
        .navigationTitle("Main Page")
        // TODO: Change Beta2.3. when app start structure changes
        // MARK: iCloud auth
        .onAppear {
            // Request access for notifications if not given already
            EatByReminderManager.instance.requestAuthorization()
            
            // DEBUGGING
            print(EatByReminderManager.instance.getAllScheduledNotifications())
            
            // DEBUGGING
            CloudKitUtility.getiCloudStatus()
                .receive(on: DispatchQueue.main)
                .sink { completion in
                    switch completion {
                    case .failure(let error ):
                        print(error.localizedDescription)
                    case .finished:
                        break
                    }
                } receiveValue: { success in
                        print("Is signed in to icloud account!")
                }
                .store(in: &mvm.cancellables)

            
            // Request access to icloud
            CloudKitUtility.requestApplicationPermission()
                .receive(on: DispatchQueue.main)
                .sink { completion in
                    switch completion {
                    case .finished:
                        break
                    case .failure(let error):
                        print(error)
                    }
                } receiveValue: { success in
                    print("Successfully enabled iCloud in EatThat!")
                }
                .store(in: &mvm.cancellables)
            
            // DEBUGGING
            CloudKitUtility.discoverUserIdentity()
                .receive(on: DispatchQueue.main)
                .sink { completion in
                    switch completion {
                    case .finished:
                        break
                    case .failure(let error):
                        print(error)
                    }
                    
                } receiveValue: { name in
                    print(name)
                }
                .store(in: &mvm.cancellables)
            
            mvm.addSubscriberToEdit()
        }
    }
}

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        MainView()
    }
}

// MARK: Functions
extension MainView {
    func getMessageString(error: Error?) -> String {
        var msgString: String = ""
        if let error = mvm.error as? ReceiptScanningError {
            msgString = "Error: \(error.localizedDescription)"
        } else if let error = mvm.error as? EatByReminderError {
            msgString = "Error: \(error.localizedDescription)"
        } else if let error = mvm.error as? Selector.SelectorError {
            mvm.alertTitle = "Scanning Error"
            msgString = error.errorDescription ?? "Error while imaging receipt"
        } else if let error = mvm.error as? HTTPManager<URLSession>.HTTPError {
            msgString = "Error: \(error.localizedDescription)"
        } else if let error = mvm.error {
            msgString = "Error: \(error.localizedDescription)"
        } else {
            // No error, just alert
            msgString = mvm.alertText
        }
        return msgString
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
    
    private var RecentlyScannedNavLink: some View {
        NavigationLink(destination: RecentlyScannedView(), isActive: $mvm.navToRecentlyScanned) { }
    }
}
