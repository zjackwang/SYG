//
//  MainUserView.swift
//  SYG
//
//  Created by Jack Wang Dev Acc on 1/8/22.
//
//  https://peterfriese.dev/swiftui-listview-part2/
//

import SwiftUI
import Combine

struct MainUserView: View {
    // View Model
    @StateObject private var mvm = MainViewModel.shared
    @StateObject private var sivm = ScannedItemViewModel.shared

    // For Sheets
    @State private var selectReceipt: Bool = false
    @State private var showScannedReceipt: Bool = false
    @State private var showSettings: Bool = false
    
    // iCloud
    @State private var cancellables = Set<AnyCancellable>()
    
    private let columns = [
                GridItem(.flexible()),
                GridItem(.flexible()),
                GridItem(.flexible()),
            ]
    
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
                // Top toolbar
                .toolbar {
                    ToolbarItemGroup(placement: .navigationBarLeading) { IconBrand }
                    ToolbarItemGroup(placement: .navigationBarTrailing) { ToolbarButtons }
                }
                // Receipt Selector
                .sheet(isPresented: $mvm.showSelector) {} content: {
                    ReceiptSelector(receipt: $mvm.receipt, sourceType: mvm.source == .library ? .photoLibrary : .camera, showPopover: $showScannedReceipt)
                        .ignoresSafeArea()
                }
                // TODO: Merge with other error?
                .alert("Scanning Error",
                       isPresented: $mvm.showCameraAlert,
                       presenting: mvm.cameraError,
                       actions: {
                            cameraError in
                            cameraError.button
                        },
                       message: {
                            cameraError in
                            Text(cameraError.message)
                        }
                )
                // User prompt confirmation of Receipt photo
                ScannedReceiptPopover(showPopover: $showScannedReceipt)
                    .padding([.top], 2)
                    .offset(y: showScannedReceipt ? 0 : UIScreen.main.bounds.height)
                    .transition(.asymmetric(
                        insertion: .move(edge: .trailing),
                        removal: .move(edge: .leading)))
                    
                // Progress Dialog
                ProgressDialog(show: $mvm.showProgressDialog, message: $mvm.progressMessage)
                    .ignoresSafeArea()
                
                // Confirmation
                ConfirmationView(show: $mvm.showConfirmationView)
                    .ignoresSafeArea()
            }
            // User confirmation alert 
            .alert(isPresented: $mvm.showConfirmationAlert) {
                var msgString: String?
                if let error = mvm.error as? ReceiptScanningError {
                    msgString = "Error: \(error.localizedDescription)"
                } else if let error = mvm.error {
                    msgString = "Error: \(error.localizedDescription)"
                } else {
                    msgString = mvm.confirmationText
                }
                
                return Alert(
                        title: Text(mvm.confirmationTitle),
                        message: Text(msgString ?? ""),
                        dismissButton:
                                .default(
                                    Text("Ok"),
                                    action: {
                                            mvm.showConfirmationAlert.toggle()
                                    }
                               )
                        )
            }
            // Settings
            .sheet(isPresented: $showSettings,
                   content: {
                SettingsView(show: $showSettings)
            })
        }
        .onAppear {
            // Request access for notifications if not given already
            EatByReminderManager.instance.requestAuthorization()
            
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
                .store(in: &cancellables)

            
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
                .store(in: &cancellables)
            
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
                .store(in: &cancellables)
        }
    }
}

struct MainUserView_Previews: PreviewProvider {
    static var previews: some View {
        MainUserView()
    }
}

// MARK: ENUMS

extension MainUserView {
    enum MainViewStates {
        case home
    }
}


// MARK: Components

extension MainUserView {
    
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
                    self.selectReceipt.toggle()
                }
                .confirmationDialog(Text("Scan Receipt"), isPresented: $selectReceipt) {
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
                }
            // Settings
            Image(systemName: "slider.horizontal.3")
                .foregroundColor(onBackground)
                .onTapGesture {
                    showSettings.toggle()
                }
                .padding()
            
        }
    }
}

struct ScannedReceiptPopover: View {
    @Binding var showPopover: Bool
    @StateObject private var mvm = MainViewModel.shared
    @StateObject private var pvm = ProduceViewModel.shared
    
    // Color Palette
    private let background: Color = Color.DarkPalette.background
    private let onBackground: Color = Color.DarkPalette.onBackground
    private let primary: Color = Color.DarkPalette.primary
    private let secondary: Color = Color.DarkPalette.secondary

    var body: some View {
        ZStack {
            ZStack (alignment: .topLeading){
                // Background
                primary
                    .ignoresSafeArea()
                // Foreground
                BackButton(show: $showPopover)
                    .font(.largeTitle)
                    .foregroundColor(onBackground)
                    .frame(width: 100, height: 100)
            }
            VStack {
                // Receipt
                Image (uiImage: mvm.receipt ?? UIImage(named: "placeholder")!)
                    .resizable()
                    .frame(width: 300, height: 300, alignment: .center)
                    .background(
                        Rectangle()
                            .fill(secondary)
                            .frame(width: 315, height: 315)
                            .cornerRadius(5)
                    )
                    .padding([.bottom], 50)

                // Confirmation
                if let receipt = mvm.receipt{
                    Button {
                        mvm.analyzeImage(receipt: receipt) 
                        withAnimation {
                            showPopover.toggle()
                        }
                    } label: {
                        ConfirmButtonLabel(text: "Confirm Image", height: 50, width: 300)
                    }
                }
            }
        }
    }
}


