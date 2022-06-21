//
//  sYgApp.swift
//  sYg
//
//  Created by Jack Wang on 11/27/21.
//

import SwiftUI

@main
struct sYgApp: App {
    /*
     * MARK: Initialization
     */

    // Item View Models
    var givm = GenericItemViewModel.shared
    
    // Core Data Persistent Local Storage
    //  Managed object context within environment
    let sivm = ScannedItemViewModel.shared
    
    // Track application state
    @Environment(\.scenePhase) var scenePhase
    
    init() {
        // Notification Handling
        UNUserNotificationCenter.current().delegate = EatByReminderManager.instance
        // Log for future
        UserDefaults.standard.setValue(false, forKey: "_UIConstraintBasedLayoutLogUnsatisfiable")

        // Background Color
        // Set the default to clear
        UITableView.appearance().backgroundColor = .clear
        
        // Navbar background color 
        if #available(iOS 15.0, *) {
            let navigationBarAppearance = UINavigationBarAppearance()
            navigationBarAppearance.configureWithDefaultBackground()
            navigationBarAppearance.backgroundColor = UIColor(Color.DarkPalette.background)
            UINavigationBar.appearance().standardAppearance = navigationBarAppearance
            UINavigationBar.appearance().compactAppearance = navigationBarAppearance
            UINavigationBar.appearance().scrollEdgeAppearance = navigationBarAppearance
        } else {
            UINavigationBar.appearance().isTranslucent = false
            UINavigationBar.appearance().backgroundColor = UIColor(Color.DarkPalette.background)
            UINavigationBar.appearance().barTintColor = UIColor(Color.DarkPalette.background)
            UINavigationBar.appearance().tintColor = UIColor(Color.DarkPalette.background)
        }
    }
    
    var body: some Scene {
        WindowGroup {
            // TODO: Change Beta2.3. when app start structure changes
            if
                let currentUserSignedIn = SettingsViewModel.shared.isUserSignedIn,
                currentUserSignedIn
            {
                MainView()
                    // Our core data managed object context into env.
                    .environment(\.managedObjectContext, sivm.container.viewContext)
                    .onAppear {
                        // request access for notifications if not given already
//                        EatByReminderManager.instance.requestAuthorization()
                        EatByReminderManager.instance.updateIconBadge()
                    }
            } else {
                OnboardingView()
            }
        }
        // App States 
        .onChange(of: scenePhase) { newScenePhase in
            switch(newScenePhase) {
            case .background:
                print("INFO: Scene is in background")
                // save core data container
                sivm.saveScannedItems {
                    result in
                    switch (result) {
                    case .failure(let error):
                        print("Error saving scanned items! \(error.localizedDescription)")
                    case .success(_):
                        break
                    }
                }
            case .inactive:
                print("INFO: Scene is inactive")
            case .active:
                print("INFO: Scene is active")
            @unknown default:
                print("FAULT: Unexpected key, Apple updated scene phase")
            }
        }
    }

  
}
