//
//  EatByReminder.swift
//  sYg
//
//  Created by Jack Wang on 2/22/22.
//

import Foundation
import UserNotifications

/*
 * Local Notification Reminder
 *  Conducts all local notification scheduling for reminders
 *  to eat a certain produce at a certain date.
 */
class EatByReminderManager {
    
    // Singleton
    static let instance = EatByReminderManager()
    
    private init() {}
    
    // Settings
    let reminderDateFormat = "yyyy-MM-dd"
    
    /*
     * Ask for permission to send notifications
     */
    func requestAuthorization(completionHandler: @escaping (Result<Data?, Error>) -> () = {_ in }) {
        // Notification alert, notification sound, and app icon badge
        let options: UNAuthorizationOptions = [.alert, .sound, .badge]
    
        UNUserNotificationCenter.current().requestAuthorization(options: options) {
            isSuccessful, error in
            if let error = error {
                print("UNAuthorization Error: \(error.localizedDescription)")
                completionHandler(.failure(error))
            }
            print("Successfully authorized user notifications!")
        }
    }
    
    /*
     * Schedule one or more new notifications for a list of scanned items
     * Input: [ScannedItem] items - the list of to-be-eaten items
     */
    func bulkScheduleReminders(for items: [ScannedItem]) {
        /*
         * TODO: Later, creating more meaningful notification messages?
         * 1. Retrieve identifying dates from
         * 2. Find items whose eat-by dates intersect with existing request dates
         * 3. Add # to existing request's badge
         */
        let existingRequests = retrieveExistingRequests()
        // Create new requests for non-intersecting items
        // TODO: NOW, convert to dictionary. Have to track # of eat-bys on a certain day.
        var existingRequestDateDict: [String: UNNotificationRequest] = [:]
        for request in existingRequests {
            existingRequestDateDict.updateValue(request, forKey: request.identifier)
        }
        for item in items {
            guard
                let dateToEat = item.dateToRemind
            else {
                // TODO: Error handling
                print("ERROR: no reminder date exists, not scheduling reminder")
                continue
            }
            let formattedDateToEat = dateToEat.getFormattedDate(format: reminderDateFormat)
            // Request date doesn't exist
            if existingRequestDateDict.keys.contains(formattedDateToEat) {
                let scheduledRequest: UNNotificationRequest = scheduleReminder(for: item)
                existingRequestDateDict.updateValue(scheduledRequest, forKey: scheduledRequest.identifier)
            }
            // Request date does exist
            else {
                // Add 1 to existing request badge
                let existingRequest = existingRequestDateDict[formattedDateToEat]
                guard
                    let requestContent = existingRequest?.content,
                    let existingBadgeNumber = requestContent.badge?.intValue,
                    let trigger = existingRequest?.trigger
                else {
                    print("Error retrieving existing request content, badge, or trigger")
                    return
                }
                let updatedBadgeNumber: Int = existingBadgeNumber + 1
                let updatedContent = createNotificationContent(badge: updatedBadgeNumber as NSNumber)

                let updatedRequest = UNNotificationRequest(
                    identifier: formattedDateToEat,
                    content: updatedContent,
                    trigger: trigger
                )
                updateScheduledReminder(for: formattedDateToEat, updatedRequest: updatedRequest)
            }
        }
    }
    
    private func createNotificationContent(badge: NSNumber) -> UNMutableNotificationContent {
        let content = UNMutableNotificationContent()
        content.title = "Eat Yo Shit"
        content.subtitle = "You have items to eat. Don't let them rot and die!!! - 🥦"
        content.sound = .default
        content.badge = badge
        
        return content
    }
    
    /*
     * Schedule an individual new notification for current user some time in the future
     * Input: ScannedItem item - the to-be-eaten item
     * Output: UNNotificationRequest request, the newly scheduled notification request
     * Pre-condition: item MUST have a eat-by reminder date
     */
    func scheduleReminder(for item: ScannedItem) -> UNNotificationRequest {
        let content = createNotificationContent(badge: 1)
        
        let dateToEat = item.dateToRemind!
        
        let dateComponents = Calendar.current.dateComponents([.year, .month, .day], from: dateToEat)
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)
            
        let request = UNNotificationRequest(
            // Use yyyy-MM-dd format to intersect with future scanned items
            // NOTE: only ONE request per day
            identifier: dateToEat.getFormattedDate(format: reminderDateFormat),
            content: content,
            trigger: trigger
        )
        
        UNUserNotificationCenter.current().add(request)
        return request
    }
        
    
    /*
     * Delete a scheduled notification when item has been eaten (deleted)
     * Input: ScannedItem item, the item eaten and taken off notification schedule
     * Pre-conditions: item MUST exist in core data
     */
    func removeScheduledReminder(for item: ScannedItem) {
        guard
            let identifier = item.dateToRemind?.getFormattedDate(format: reminderDateFormat)
        else {
            print("Error retriveing scanned item reminder date")
            return
        }
        UNUserNotificationCenter.current().removePendingNotificationRequests(
            withIdentifiers: [identifier]
        )
    }
        
    /*
     * Retrieve all existing scheduled reminders synchronously
     * Output: [UNNotificationRequest] requests
     */
    func retrieveExistingRequests() -> [UNNotificationRequest]{
        let group = DispatchGroup()
        group.enter()
        // Retrieve existing notification requests
        var existingRequests: [UNNotificationRequest] = []
        UNUserNotificationCenter.current().getPendingNotificationRequests {
            requests in
            existingRequests.append(contentsOf: requests)
            group.leave()
        }
        group.wait()
        return existingRequests
    }
    
    /*
     * Update a given scheduled request with its new iteration
     * Input: String identifier, of the legacy request
     *        Request newRequest, the new request
     * Note: if old request does not exist, we just schedule the new request
     */
    func updateScheduledReminder(for identifier: String, updatedRequest: UNNotificationRequest) {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [identifier])
        UNUserNotificationCenter.current().add(updatedRequest)
    }
    
    func cancelAllNotifications() {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
        UNUserNotificationCenter.current().removeAllDeliveredNotifications()
    }
}
