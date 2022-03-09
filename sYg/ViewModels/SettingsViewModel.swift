//
//  SettingsViewModel.swift
//  sYg
//
//  Created by Jack Wang on 3/7/22.
//

import SwiftUI

class SettingsViewModel {
    // Singleton
    static let shared = SettingsViewModel()
    private init() {}
    
    @AppStorage("name") var currentUserName: String = ""
    @AppStorage("signed_in") var isUserSignedIn: Bool = false
    @AppStorage("default_expire_days") var defaultExpirationDays: Int = 4
    @AppStorage("red_clock_days") var redClockDays: Int = 2
    @AppStorage("yellow_clock_days") var yellowClockDays: Int = 4
    @AppStorage("reminder_hour") var reminderHour: Int = 8 // Default 8 AM
    
    
    var defaultExpirationInterval: TimeInterval {
        return Double(defaultExpirationDays) * TimeConstants.dayTimeInterval
    }
    var redClockInterval: TimeInterval {
        return Double(redClockDays) * TimeConstants.dayTimeInterval
    }
    var yellowClockInterval: TimeInterval {
        return Double(yellowClockDays) * TimeConstants.dayTimeInterval
    }

}
