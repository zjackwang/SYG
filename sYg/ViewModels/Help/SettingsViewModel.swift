//
//  SettingsViewModel.swift
//  sYg
//
//  Created by Jack Wang on 3/7/22.
//

import SwiftUI
import Combine

/*
 * Stores and updates settings and statistics of user
 * Keys in User Defaults storage
 *  1. "username": String
 *  2. "signed_in": Bool
 *  3. "default_eat_by_days": Int
 *  4. "red_clock_days": Int
 *  5. "yellow_clock_days": Int
 *  6. "lifetime_items_scanned": Int
 *  7. "lifetime_items_eaten": Int
 */
class SettingsViewModel: ObservableObject {

    // MARK: Initialization
    static let shared = SettingsViewModel()
    private init() {
        displayedUsername = defaults.string(forKey: "username") ?? ""
        displayedDefaultEatByDays = defaults.integer(forKey: "default_eat_by_days")
        displayedRedClockDays = defaults.integer(forKey: "red_clock_days")
        displayedYellowClockDays = defaults.integer(forKey: "yellow_clock_days")

        displayedScannedItemsLifetime = 0
        displayedEatenItemsLifetime = 0
        
        defaultEatByDateTextFieldInt = defaults.integer(forKey: "default_eat_by_days")
        redClockDaysTextFieldInt = defaults.integer(forKey: "red_clock_days")
        yellowClockDaysTextFieldInt = defaults.integer(forKey: "yellow_clock_days")
        
        subscribeToDefaultEatByDays()
        subscribeToRedClockDays()
        subscribeToYellowClockDays()
    }
    
    private let defaults = UserDefaults.standard
    
    @Published var displayedUsername: String
    @Published var displayedScannedItemsLifetime: Int
    @Published var displayedEatenItemsLifetime: Int
    @Published var displayedDefaultEatByDays: Int
    @Published var displayedRedClockDays: Int
    @Published var displayedYellowClockDays: Int
    
    @Published var defaultEatByDateTextFieldInt: Int
    @Published var redClockDaysTextFieldInt: Int
    @Published var yellowClockDaysTextFieldInt: Int
    
    private var cancellables = Set<AnyCancellable>()
    
    var integer: NumberFormatter {
       let formatter = NumberFormatter()
        formatter.numberStyle = .none
        formatter.minimum = 1
        return formatter
    }
    
    func getUsername() -> String {
        return defaults.string(forKey: "username") ?? ""
    }
    
    func isUserSignedIn() -> Bool {
        return defaults.bool(forKey: "signed_in")
    }
    
    func getScannedItemsLifetime() -> Int {
        return defaults.integer(forKey: "lifetime_items_scanned")
    }
    
    func getDefaultEatByDays() -> Int {
        return defaults.integer(forKey: "default_eat_by_days")
    }
    
    func getRedClockDays() -> Int {
        return defaults.integer(forKey: "red_clock_days")
    }
    
    func getYellowClockDays() -> Int {
        return defaults.integer(forKey: "yellow_clock_days")
    }
    
    func setInitialDefaults(username: String) {
        defaults.set(username, forKey: "username")
        defaults.set(4, forKey: "default_eat_by_days")
        defaults.set(4, forKey: "red_clock_days")
        defaults.set(2, forKey: "yellow_clock_days")
    }
    
    func setDisplayedDefaults() {
        
    }
    
    func toggleSignIn() {
        if defaults.bool(forKey: "signed_in") {
            defaults.set(false, forKey: "signed_in")
        } else {
            defaults.set(true, forKey: "signed_in")
        }
    }
    
    func updateUsername(username: String) {
        defaults.set(username, forKey: "username")
    }
    
    func updateDefaultEatByDays(days: Int) {
        displayedDefaultEatByDays = days
        defaults.set(days, forKey: "default_eat_by_days")
    }
    
    func updateRedClockDays(days: Int) {
        displayedRedClockDays = days
        defaults.set(days, forKey: "red_clock_days")
    }
    
    func updateYellowClockDays(days: Int) {
        displayedYellowClockDays = days
        defaults.set(days, forKey: "yellow_clock_days")
    }
    
    func updateLifeTimeItemsScanned(update: Int) {
        let previousAmount = defaults.integer(forKey: "lifetime_items_scanned")
        defaults.set(previousAmount + update, forKey: "lifetime_items_scanned")
    }
    
    func updateLifeTimeItemsEaten(update: Int) {
        let previousAmount = defaults.integer(forKey: "lifetime_items_eaten")
        defaults.set(previousAmount + update, forKey: "lifetime_items_eaten")
    }
    
    func subscribeToUsername() {
        $displayedUsername
            .sink { [weak self] name in
                self?.updateUsername(username: name)
            }
            .store(in: &cancellables)
    }
    
    func subscribeToDefaultEatByDays() {
        $defaultEatByDateTextFieldInt
            .sink { [weak self] eatByDays in
                if eatByDays > 0 {
                    self?.updateDefaultEatByDays(days: eatByDays)
                }
            }
            .store(in: &cancellables)
    }
    
    func subscribeToRedClockDays() {
        $redClockDaysTextFieldInt
            .sink { [weak self] redClockDays in
                if redClockDays > 0 {
                    self?.updateRedClockDays(days: redClockDays)
                }
            }
            .store(in: &cancellables)
    }
    
    func subscribeToYellowClockDays() {
        $yellowClockDaysTextFieldInt
            .sink { [weak self] yellowClockDays in
                if yellowClockDays > 0 {
                    self?.updateYellowClockDays(days: yellowClockDays)
                }
            }
            .store(in: &cancellables)
    }
    
    
    var defaultExpirationInterval: TimeInterval {
        return Double(getDefaultEatByDays()) * TimeConstants.dayTimeInterval
    }
    var redClockInterval: TimeInterval {
        return Double(getRedClockDays()) * TimeConstants.dayTimeInterval
    }
    var yellowClockInterval: TimeInterval {
        return Double(getYellowClockDays()) * TimeConstants.dayTimeInterval
    }
    var expiredClockInterval: TimeInterval {
        return Double(0)
    }

}
