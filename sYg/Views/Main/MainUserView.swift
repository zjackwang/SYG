//
//  MainUserView.swift
//  SYG
//
//  Created by Jack Wang Dev Acc on 1/8/22.
//
//  https://peterfriese.dev/swiftui-listview-part2/
//

import SwiftUI

struct MainUserView: View {
    @StateObject private var mvm = MainViewModel.shared

    // For Popups
    @State private var selectReceipt: Bool = false
    @State private var showScannedReceipt: Bool = false

    private let columns = [
                GridItem(.flexible()),
                GridItem(.flexible()),
                GridItem(.flexible()),
            ]
    
    private let listRowBackgroundColor: Color = .green
    
    
    // Loading circle
    @State private var showProgressDialog = false
    @State private var progressMessage = ""
    
    var body: some View {
        NavigationView {
            // Foreground
            ZStack {
                // Produce Items
                UserItemListView()
                // Upper toolbar
                .toolbar {
                    ToolbarItemGroup(placement: .navigationBarLeading) {
                        HStack(spacing: 15) {
                            Image("icon")
                                .frame(maxWidth: 10)
                                .padding(20)
                            Text("EatThat!")
                                .font(.title)
                                .fontWeight(.bold)
                        }
                    }
                    ToolbarItemGroup(placement: .navigationBarTrailing) {
                        // Scan Receipts
                        Image(systemName: "plus.app")
                            .onTapGesture {
                                self.selectReceipt = true
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
                        
                        // For now a testing button
                        Image(systemName: "slider.horizontal.3")
                            .onTapGesture {
                                showProgressDialog.toggle()
                                progressMessage = "Progress Test"
                            }
                           .padding()
                    }
                }
                // Receipt Selector
                .sheet(isPresented: $mvm.showSelector) {} content: {
                    ReceiptSelector(receipt: $mvm.receipt, sourceType: mvm.source == .library ? .photoLibrary : .camera, showPopover: $showScannedReceipt)
                        .ignoresSafeArea()
                }
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
                    .padding(.top, 45)
                    .offset(y: showScannedReceipt ? 0 : UIScreen.main.bounds.height)
                    .animation(.spring(response: 0.5, dampingFraction: 1.0, blendDuration: 1.0))
                // Progress Dialog
                ProgressDialog(show: $showProgressDialog, message: $progressMessage)
            }
            // Confirmation of successful scan + item matching
            .alert(isPresented: $mvm.showConfirmationAlert) {
                var message: Text?
                if let error = mvm.error {
                    message = Text("Error: \(error.localizedDescription)")
                } else {
                    message = Text("Success!")
                }
                
                return Alert(
                        title: Text("Scanning Result"),
                        message: message!,
                        dismissButton:
                                .default(
                                    Text("Ok"),
                                    action: {
                                            mvm.showConfirmationAlert.toggle()
                                    }
                               )
                        )
            }
        }
    }
        
}

struct ScannedReceiptPopover: View {
    @Binding var showPopover: Bool
    @StateObject private var mvm = MainViewModel.shared
    @StateObject private var pvm = ProduceViewModel.shared

    var body: some View {
        ZStack {
            ZStack (alignment: .topLeading){
                // Background
                Color.gray
                    .ignoresSafeArea()
                // Foreground
                Button {
                    showPopover.toggle()
                } label: {
                    Image(systemName: "xmark")
                        .foregroundColor(.white)
                        .font(.largeTitle)
                        .padding(20)
                }
            }
            VStack {
                // Receipt
                Image (uiImage: mvm.receipt ?? UIImage(named: "placeholder")!)
                    .resizable()
                    .frame(width: 300, height: 300, alignment: .bottom)
                    .background(.gray)
                // Confirmation
                if let receipt = mvm.receipt{
                    Button {
                        if !mvm.analyzeImage(receipt: receipt) {
                            // Handle error, show popup TODO
                            mvm.imageAnalysisError()
                        }
                        showPopover.toggle()
                    } label: {
                        Text("Confirm Image")
                            .foregroundColor(.white)
                            .frame(width: 300, height: 100)
                            .cornerRadius(25)
                    }
                    
                }
            }
        }
    }
}

struct MainUserView_Previews: PreviewProvider {
    static var previews: some View {
        MainUserView()
    }
}
