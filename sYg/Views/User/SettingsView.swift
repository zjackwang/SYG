//
//  SettingsView.swift
//  sYg
//
//  Created by Jack Wang on 3/1/22.
//

import SwiftUI

struct SettingsView: View {
    @StateObject private var svm = SettingsViewModel.shared

    private let background: Color = Color.DarkPalette.background
    private let onBackground: Color = Color.DarkPalette.onBackground

    var body: some View {
        ZStack {
            background
                .ignoresSafeArea()
            Text(svm.displayedUsername)
                .font(.headline)
            List {
                StatsSection
                ReminderSettings
                DatabaseSection
            }
            .listStyle(.insetGrouped)
            .navigationTitle("Settings")
        }
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}

// MARK: COMPONENTS
extension SettingsView {
    
    private var StatsSection: some View {
        Section {
            HStack {
                Text("Scanned Items (lifetime):")
                    .font(.headline)
                    .fontWeight(.semibold)
                    .frame(maxWidth: .infinity, alignment: .leading)
                Text("\(ScannedItemViewModel.shared.getNumberScannedItems())")
                    .frame(maxWidth: 50, alignment: .trailing)
            }
            
            HStack {
                Text("Scanned Items (current):")
                    .font(.headline)
                    .fontWeight(.semibold)
                    .frame(maxWidth: .infinity, alignment: .leading)
                Text("\(ScannedItemViewModel.shared.getNumberScannedItems())")
                    .frame(maxWidth: 50, alignment: .trailing)
            }
            
        } header: {
            Text("Stats")
        }
    }
    
    private var ReminderSettings: some View {
        Section {
            HStack {
                Text("Default Days to Eat By:")
                    .font(.headline)
                    .fontWeight(.semibold)
                    .frame(maxWidth: .infinity, alignment: .leading)
                TextField("\(svm.displayedRedClockDays)", value: $svm.defaultEatByDateTextFieldInt, formatter: svm.integer)
                    .multilineTextAlignment(.trailing)
                    .frame(maxWidth: 25)
            }
            HStack {
                Text("Days Before Red Clock Shown:")
                    .font(.headline)
                    .fontWeight(.semibold)
                    .frame(maxWidth: .infinity, alignment: .leading)
                TextField("\(svm.displayedRedClockDays)", value: $svm.redClockDaysTextFieldInt, formatter: svm.integer)
                    .multilineTextAlignment(.trailing)
                    .frame(maxWidth: 25)
            }
            HStack {
                Text("Days Before Yellow Clock Shown:")
                    .font(.headline)
                    .fontWeight(.semibold)
                    .frame(maxWidth: .infinity, alignment: .leading)
                TextField("\(svm.displayedYellowClockDays)", value: $svm.yellowClockDaysTextFieldInt, formatter: svm.integer)
                    .multilineTextAlignment(.trailing)
                    .frame(maxWidth: 25)
            }
        } header: {
            Text("Reminder Settings")
        }

    }
    
    private var DatabaseSection: some View {
        Section {
            NavigationLink {
                GenericItemsView()
            } label: {
                Text("Generic Item Database")
                    .font(.headline)
                    .fontWeight(.semibold)
            }
        } header: {
            Text("Database")
        }
    }
}
