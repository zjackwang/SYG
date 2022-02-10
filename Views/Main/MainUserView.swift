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
    // For testing
    @State private var exampleItemJSON: [UserItem] = UserItem.samples
    
    @EnvironmentObject private var mvm: MainViewModel

    // For Popups
    @State private var selectReceipt: Bool = false
    @State private var showScannedReceipt: Bool = false

   private let columns = [
                GridItem(.flexible()),
                GridItem(.flexible()),
                GridItem(.flexible()),
            ]
    
    private let listRowBackgroundColor: Color = .green
    
    var body: some View {
        NavigationView {
            // Foreground
            ZStack {
                UserItemListView()
                // Upper toolbar
                .toolbar {
                    ToolbarItemGroup(placement: .navigationBarLeading) {
                        Text("Save Your Groceries")
                            .font(.title)
                            .fontWeight(.bold)
                    }
                    ToolbarItemGroup(placement: .navigationBarTrailing) {
                        // Scan Receipts
                        Image(systemName: "plus.app")
                            .onTapGesture {
                                self.selectReceipt = true
                            }
                            .padding()
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
                        
                        // Settings TODO
                        Button(action: {
                             showScannedReceipt.toggle()
                             print("Edit")
                           }) {
                             Label("Edit", systemImage: "slider.horizontal.3")
                           }
                           .foregroundColor(.black)
                           .padding()
                    }
                }
                // Receipt Selector
                .sheet(isPresented: $mvm.showSelector) {} content: {
                    ReceiptSelector(receipt: $mvm.receipt, sourceType: mvm.source == .library ? .photoLibrary : .camera, showPopover: $showScannedReceipt)
                        .ignoresSafeArea()
                }
                .alert("Error",
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
                // Confirmation of Receipt
                ScannedReceiptPopover(showPopover: $showScannedReceipt)
                    .padding(.top, 45)
                    .offset(y: showScannedReceipt ? 0 : UIScreen.main.bounds.height)
                    .animation(.spring(response: 0.5, dampingFraction: 1.0, blendDuration: 1.0))
            }
            
        }

    }
}

struct ScannedReceiptPopover: View {
    @Binding var showPopover: Bool
    @EnvironmentObject private var mvm: MainViewModel
    @EnvironmentObject private var pvm: ProduceViewModel
    @EnvironmentObject private var svm: ScannedItemsViewModel

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
                        if !mvm.analyzeImage(receipt: receipt, pvm: pvm, svm: svm) {
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
            .environmentObject(MainViewModel())
            .environmentObject(ScannedItemsViewModel())
    }
}
