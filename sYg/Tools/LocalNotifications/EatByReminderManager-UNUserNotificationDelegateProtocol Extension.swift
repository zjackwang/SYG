//
//  EatByReminderManager-UNUserNotificationDelegateProtocol Extension.swift
//  sYg
//
//  Created by Jack Wang on 3/3/22.
//

import SwiftUI

extension EatByReminderManager: UNUserNotificationCenterDelegate {
    // Engagement with notification (tap notification)
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        EatByReminderManager.instance.updateIconBadge()
        completionHandler()
    }
    
    // Foreground notification
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        EatByReminderManager.instance.updateIconBadge()
        completionHandler([.alert, .sound, .badge])
    }
}
