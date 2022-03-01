//
//  SettingsView.swift
//  sYg
//
//  Created by Jack Wang on 3/1/22.
//

import SwiftUI

struct SettingsView: View {
    @AppStorage("name") var name: String?
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
                    BackButton(showSheet: $show)
                }
            }
        }
    }
}

extension SettingsView {
    
    private var InfoSection: some View {
        Section {
            HStack {
                Text("Name:")
                    .font(.headline)
                    .fontWeight(.semibold)
                Text(name ?? "?")
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
