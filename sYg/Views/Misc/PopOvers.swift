//
//  DateToEatPopup.swift
//  sYg
//
//  Created by Jack Wang on 2/28/22.
//

import SwiftUI

struct PopOverScreen: View {
    var title: String
    var message: String
    
    private let secondary: Color = Color.DarkPalette.secondary
    private let onSecondary: Color = Color.DarkPalette.onSecondary

    var body: some View {
        ZStack(alignment: .center) {
            secondary
                .ignoresSafeArea()
            HStack {
                Text(title)
                    .font(.headline)
                    .fontWeight(.semibold)
                    .padding()
                    .foregroundColor(onSecondary)
                Text(message)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(onSecondary)
            }
        }
        .cornerRadius(10)
    }
}


struct Popup: View {
    var title: String
    var message: String
    var buttonText: String
    
    @Binding var show: Bool
    
    var body: some View {
        if show {
            ZStack {
                Color.white
                VStack {
                    Text(title)
                    Spacer()
                    Text(message)
                    Spacer()
                    Button(action: {
                        show.toggle()
                    }, label: {
                        Text(buttonText)
                    })
                }.padding()
            }
            .frame(width: 300, height: 200)
            .cornerRadius(20).shadow(radius: 20)
        }
    }
}

struct PopupDisplay: View {
    @State var showPopup: Bool = false
    
    var body: some View {
        ZStack {
            Button {
                showPopup.toggle()
            } label: {
                Text("Show popup")
                    .foregroundColor(.black)
            }
            Popup(title: "Poppppy", message: "POPO", buttonText: "WHAT", show: $showPopup)
        }

    }
}

struct PopOvers_Previews: PreviewProvider {
    static var previews: some View {
        PopupDisplay()
    }
}
