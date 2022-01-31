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
    var redStatus: TimeInterval = Settings.DefaultSettings.redClockInterval
    var yellowStatus: TimeInterval = Settings.DefaultSettings.yellowClockInterval
    
    let today: Date = Date.now
    var body: some View {
        let timeToExpiration: TimeInterval = today.distance(to: dateToRemind)

        Image(systemName: "clock.arrow.circlepath")
            .foregroundColor(
                timeToExpiration <= redStatus ? .red : timeToExpiration <= yellowStatus ? .yellow : .green
            )
            .onTapGesture {
                // TODO
                // Bring up Item selection menu
            }
    }
}

struct StatusClock_Previews: PreviewProvider {
    static var previews: some View {
        StatusClockView(dateToRemind: Date(timeIntervalSinceNow: 10000))
    }
}
