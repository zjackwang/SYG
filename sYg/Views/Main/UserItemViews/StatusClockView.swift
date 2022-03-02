//
//  StatusClock.swift
//  sYg
//
//  Created by Jack Wang on 1/31/22.
//

import SwiftUI

struct StatusClockView: View {
    var dateToRemind: Date
    // reminder settings
    // default is 2 days
    var redStatus: TimeInterval = Settings.User.redClockInterval
    var yellowStatus: TimeInterval = Settings.User.yellowClockInterval
    
    @Binding var showPopup: Bool
    
    private let background : Color = Color.DarkPalette.background
    private let primary: Color = Color.DarkPalette.primary
    private let secondary: Color = Color.DarkPalette.secondary
    private let tertiary: Color = Color.DarkPalette.tertiary
    private let quaternary: Color = Color.DarkPalette.quaternary

    let today: Date = Date.now
    var body: some View {
        let timeToExpiration: TimeInterval = today.distance(to: dateToRemind)
        Button {
            print("DEBUG >>> Toggling!")
            showPopup.toggle()
        } label: {
            Image(systemName: "clock.arrow.circlepath")
                .font(.system(size: 15))
                .foregroundColor(
                    timeToExpiration <= redStatus ? quaternary : timeToExpiration <= yellowStatus ? tertiary : secondary
                )
                .shadow(color: background, radius: 3)
        }
    }
}

struct StatusClockViewDisplay: View {
    @State var showPopup: Bool = false
    
    var body: some View {
        ZStack {
            StatusClockView(dateToRemind: Date(timeIntervalSinceNow: 10000), showPopup: $showPopup)
        }
    }
}

struct StatusClock_Previews: PreviewProvider {
    
    static var previews: some View {
        StatusClockViewDisplay()
    }
}
