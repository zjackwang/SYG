//
//  SettingsView.swift
//  sYg
//
//  Created by Jack Wang on 3/1/22.
//

import SwiftUI

struct SettingsView: View {
    @Binding var show: Bool
    var body: some View {
        NavigationView {
            List {
                InfoSection
                ValuesSection
            }
            .listStyle(.insetGrouped)
            .navigationTitle("Settings")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    BackButton(show: $show)
                }
            }
        }
    }
}

class SettingsViewModel {
    // Singleton
    static let shared = SettingsViewModel()
    private init() {}
    
    // User Defaults
    @AppStorage("name") var currentUserName: String = ""
    @AppStorage("signed_in") var isUserSignedIn: Bool = false
}

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
    
    private var ValuesSection: some View {
        Section {
            HStack {
                Text("Red Clock Interval:")
                    .font(.headline)
                    .fontWeight(.semibold)
                Text("\(Int(Settings.User.redClockInterval / TimeConstants.dayTimeInterval)) days prior")
            }
            HStack {
                Text("Yellow Clock Interval:")
                    .font(.headline)
                    .fontWeight(.semibold)
                Text("\(Int(Settings.User.yellowClockInterval / TimeConstants.dayTimeInterval)) days prior")
            }
            
            
        } header: {
            Text("Values")
        }

    }
}
