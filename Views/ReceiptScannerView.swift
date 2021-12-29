//
//  ReceiptScannerView.swift
//  sYg
//
//  Created by Jack Wang on 12/28/21.
//  https://www.youtube.com/watch?v=V-kSSjh1T74

import SwiftUI

struct ReceiptScannerView: View {
    
    @EnvironmentObject private var rvm: ReceiptViewModel
    @State private var selectReceipt: Bool = false
   
    var body: some View {
        NavigationView {
            VStack {
                Image (uiImage: rvm.receipt ?? UIImage(named: "placeholder")!)
                    .resizable()
                    .frame(width: 300, height: 300)
                    .background(.gray)
          
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
            .navigationTitle("Select Image")
            .sheet(isPresented: $rvm.showSelector) {

            } content: {
                ReceiptSelector(receipt: $rvm.receipt, sourceType: rvm.source == .library ? .photoLibrary : .camera)
                    .ignoresSafeArea()
            }

        }
    }
}

struct ReceiptScannerView_Previews: PreviewProvider {
    static var previews: some View {
        ReceiptScannerView()
            .environmentObject(ReceiptViewModel())
    }
}
