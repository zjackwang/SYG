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
    
    var body: some View {
        ZStack(alignment: .center) {
            Color.green
                .ignoresSafeArea()
            HStack {
                Text(title)
                    .font(.headline)
                    .fontWeight(.semibold)
                    .padding()
                Text(message)
                    .font(.subheadline)
                    .fontWeight(.medium)
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

struct DateToEatPopup_Previews: PreviewProvider {
    static var previews: some View {
        PopupDisplay()
    }
}
