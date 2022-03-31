//
//  ConfirmButton.swift
//  sYg
//
//  Created by Jack Wang on 3/30/22.
//

import SwiftUI

struct ConfirmButtonLabel: View {
    var text: String
    var height: CGFloat
    var width: CGFloat
    
    // Color Palette
    private let textColor: Color = Color.DarkPalette.onBackground
    private let background: Color = Color.DarkPalette.secondary
    
    var body: some View {
        Text(text)
            .foregroundColor(textColor)
            .background(
                Rectangle()
                    .fill(background)
                    .frame(width: width, height: height, alignment: .bottom)
                    .cornerRadius(15)
            )
    }
}

//struct ConfirmButton_Previews: PreviewProvider {
//    static var previews: some View {
//        ConfirmButtonLabel()
//    }
//}
