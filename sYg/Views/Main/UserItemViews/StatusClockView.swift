//
//  StatusClock.swift
//  sYg
//
//  Created by Jack Wang on 1/31/22.
//

import SwiftUI

struct StatusClockView: View {
    @Binding var dateToRemind: Date?
    
    var svm = SettingsViewModel.shared
    
    @Binding var showPopup: Bool
    
    private let background : Color = Color.DarkPalette.background
    private let primary: Color = Color.DarkPalette.primary
    private let secondary: Color = Color.DarkPalette.secondary
    private let tertiary: Color = Color.DarkPalette.tertiary
    private let quaternary: Color = Color.DarkPalette.quaternary

    let today: Date = Date.now
    var body: some View {
        Image(systemName: "clock.arrow.circlepath")
            .font(.system(size: 15))
            .foregroundColor(
                timeToExpiration <= svm.redClockInterval ? quaternary : timeToExpiration <= svm.yellowClockInterval ? tertiary : secondary
            )
            .shadow(color: background, radius: 3)
            .overlay(
                Image(systemName: "exclamationmark.triangle.fill")
                    .foregroundColor(.orange)
                    .font(.system(size: 10))
                    .position(x: 15, y: 0)
                    .opacity(timeToExpiration < svm.expiredClockInterval ? 1.0 : 0.0)
            )
    }
}

// MARK: Components

extension StatusClockView {
    private var timeToExpiration: TimeInterval {
        today.distance(to: dateToRemind ?? Date.init(timeIntervalSinceNow: 3 * TimeConstants.dayTimeInterval))
    }
    
}

struct StatusClockViewDisplay: View {
    @State var showPopup: Bool = false
    @State var date: Date? = Date(timeIntervalSinceNow: 10000)
    
    var body: some View {
        ZStack {
            StatusClockView(dateToRemind: $date, showPopup: $showPopup)
        }
    }
}

struct StatusClock_Previews: PreviewProvider {
    
    static var previews: some View {
        StatusClockViewDisplay()
    }
}
