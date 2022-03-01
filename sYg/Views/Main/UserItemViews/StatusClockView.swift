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
    
    let today: Date = Date.now
    var body: some View {
        let timeToExpiration: TimeInterval = today.distance(to: dateToRemind)
        Button {
            print("DEBUG >>> Toggling!")
            showPopup.toggle()
        } label: {
            Image(systemName: "clock.arrow.circlepath")
                .foregroundColor(
                    timeToExpiration <= redStatus ? .red : timeToExpiration <= yellowStatus ? .yellow : .green
            )
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
