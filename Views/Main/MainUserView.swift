//
//  MainUserView.swift
//  SYG
//
//  Created by Jack Wang Dev Acc on 1/8/22.
//

import SwiftUI

struct MainUserView: View {
    
    @State private var exampleItemJSON: [UserItem] = UserItem.samples
    @EnvironmentObject private var rvm: ReceiptViewModel
    @State private var selectReceipt: Bool = false

   private let columns = [
                GridItem(.flexible()),
                GridItem(.flexible()),
                GridItem(.flexible()),
            ]
    
    private let listRowBackgroundColor: Color = .green
    
    var body: some View {
        NavigationView {
            // Foreground
            VStack {
                // https://peterfriese.dev/swiftui-listview-part2/
                UserItemListView(itemsList: UserItem.samples)
            }
//            .ignoresSafeArea()
            .sheet(isPresented: $rvm.showSelector) {} content: {
                ReceiptSelector(receipt: $rvm.receipt, sourceType: rvm.source == .library ? .photoLibrary : .camera)
                    .ignoresSafeArea()
            }
            .alert("Error",
                   isPresented: $rvm.showCameraAlert,
                   presenting: rvm.cameraError,
                   actions: {
                        cameraError in
                        cameraError.button
                    },
                   message: {
                        cameraError in
                        Text(cameraError.message)
                    }
            )
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
                                rvm.source = .camera
                                rvm.showReceiptSelector()
                            } label: {
                                Text("Scan Receipt")
                            }
                            Button  {
                                rvm.source = .library
                                rvm.showReceiptSelector()
                            } label: {
                                Text("Choose From Library")
                            }
                        }
                    
                    // Settings TODO
                    Button(action: {
                         print("Edit")
                       }) {
                         Label("Edit", systemImage: "slider.horizontal.3")
                       }
                       .foregroundColor(.black)
                }
            }
        }
 
    }
}

struct MainUserView_Previews: PreviewProvider {
    static var previews: some View {
        MainUserView()
            .environmentObject(ReceiptViewModel())

    }
}
