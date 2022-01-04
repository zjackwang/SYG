//
//  ReceiptScannerView.swift
//  sYg
//
//  Created by Jack Wang on 12/28/21.
//  https://www.youtube.com/watch?v=V-kSSjh1T74
//  https://www.youtube.com/watch?v=d6eTXQfAKJM

import SwiftUI

struct ReceiptScannerView: View {
    
    @EnvironmentObject private var rvm: ReceiptViewModel
    @State private var selectReceipt: Bool = false
    
    var body: some View {
        NavigationView {
            VStack {
                // Temp. for visibility
                if let workingLocation = rvm.workingLocation {
                    Text("Working from \(workingLocation)")
                        .font(.largeTitle)
                        .fontWeight(.semibold)
                        .padding()
                }
                Image (uiImage: rvm.receipt ?? UIImage(named: "placeholder")!)
                    .resizable()
                    .frame(width: 300, height: 300)
                    .background(.gray)
          
                if let receipt = rvm.receipt{
                    Button {
                        rvm.analyzeImage(receipt: receipt)
                        // TODO pop over
                    } label: {
                        Text("Confirm Image")
                    }
                    .padding()
                    .frame(width: 300, height: 100)
                    .cornerRadius(25)
                    
                } else {
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
                }
            }
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
            .navigationTitle("Select Image")
        }
    }
}

struct ReceiptScannerView_Previews: PreviewProvider {
    static var previews: some View {
        ReceiptScannerView()
            .environmentObject(ReceiptViewModel())
    }
}
