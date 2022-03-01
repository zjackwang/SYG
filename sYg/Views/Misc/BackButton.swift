//
//  BackButton.swift
//  sYg
//
//  Created by Jack Wang on 3/1/22.
//

import SwiftUI

struct BackButton: View {
    
    @Binding var showSheet: Bool
    
    var body: some View {
        Image(systemName: "arrowshape.turn.up.left")
            .font(.headline)
            .onTapGesture {
                showSheet.toggle()
            }
    }
}
