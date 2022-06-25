//
//  ScannedReceiptPopover.swift
//  sYg
//
//  Created by Jack Wang on 4/19/22.
//

import SwiftUI

struct ScannedReceiptPopover: View {
    @Binding var showPopover: Bool
    @StateObject private var mvm = MainViewModel.shared
    
    // Color Palette
    private let background: Color = Color.DarkPalette.background
    private let onBackground: Color = Color.DarkPalette.onBackground
    private let primary: Color = Color.DarkPalette.primary
    private let secondary: Color = Color.DarkPalette.secondary

    var body: some View {
        ZStack {
            ZStack (alignment: .topLeading){
                // Background
                background
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
                            .fill(onBackground)
                            .frame(width: 305, height: 305)
                            .cornerRadius(5)
                    )
                    .padding([.bottom], 50)

                // Confirmation
                if let receipt = mvm.receipt{
                    Button {
                        Task {
                            await mvm.analyzeReceiptAndStore(receipt: receipt)
                        }
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
