//
//  SettingsView.swift
//  sYg
//
//  Created by Jack Wang on 3/1/22.
//

import SwiftUI

struct SettingsView: View {
    var svm = SettingsViewModel.shared

    var body: some View {
        
        List {
            InfoSection
            ReminderSettings
        }
        .listStyle(.insetGrouped)
        .toolbar {
            ToolbarItemGroup(placement: .navigationBarTrailing) {
                NavigationLink {
                    GenericItemsView()
                } label: {
                    Text("Go to database")
                }
            }
        }
        .navigationTitle("Settings")
    
    }
}

// MARK: COMPONENTS
extension SettingsView {
    
    private var InfoSection: some View {
        Section {
            HStack {
                Text("Name:")
                    .font(.headline)
                    .fontWeight(.semibold)
                Text(SettingsViewModel.shared.currentUserName)
            }
            HStack {
                Text("Scanned Items:")
                    .font(.headline)
                    .fontWeight(.semibold)
                Text("\(ScannedItemViewModel.shared.getNumberScannedItems())")
            }
            
            
        } header: {
            Text("Info")
        }
    }
    
    private var ReminderSettings: some View {
        Section {
            HStack {
                Text("Reminder hour:")
                    .font(.headline)
                    .fontWeight(.semibold)
                Text("\(date.getFormattedDate(format: TimeConstants.hourFormat))")
            }
            HStack {
                Text("Default expiration time interval:")
                    .font(.headline)
                    .fontWeight(.semibold)
                Text("\(SettingsViewModel.shared.defaultExpirationDays) days from purchase date")
            }
            HStack {
                Text("Red Clock Shown:")
                    .font(.headline)
                    .fontWeight(.semibold)
                Text("\(SettingsViewModel.shared.redClockDays) days prior")
            }
            HStack {
                Text("Yellow Clock Shown:")
                    .font(.headline)
                    .fontWeight(.semibold)
                Text("\(SettingsViewModel.shared.yellowClockDays) days prior")
            }
            
            
        } header: {
            Text("Reminder Settings")
        }

    }
    
    
    private var date: Date {
        let dateComponent = DateComponents(hour: SettingsViewModel.shared.reminderHour)
        return Calendar.current.date(from: dateComponent)!
    }
}
