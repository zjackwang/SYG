//
//  EatByReminder.swift
//  sYg
//
//  Created by Jack Wang on 2/22/22.
//

import SwiftUI
import UserNotifications

/*
 * Local Notification Reminder
 *  Conducts all local notification scheduling for reminders
 *  to eat a certain produce at a certain date.
 *
 * Notifications 1.0
 *  1. Notifications id marked by exp date
 *  2. One notification per day for all items exp on that date
 * Notifications 2.0
 *  Supports these features
 *  1. Creates notification to trigger
        @ a date and time to the minute
        w/ a message
    2. One notification per day?
        or one notification per item
        or both
        - daily notification: rounds up exp items
        - per item notification: triggers when it exp
        -> eventually have bfast/lunch/dinner notifs
    3. Shows # exp items on icon badge
    4. Notifications id marked by uuid (TODO: )
        -> Add id in data model
        -> Create id during instantiation
        -> Update id retrieving and handling
            what is identifier?
    5. Expired notfications upon update can trigger again
        
 */


/*
 * EatByReminderManager
 * Function roll call; * means synchronized
 * Attributes; ? means private
 *  - ? mutex: UnfairLock
 *  - numUrgentsToEat: Int
 *      => IDEALLY shows how many exp items you have
 *
 * Public Functions
 *  - requestAuthorization: () -> ()
 *      => KEEP
 *  - updateIconBadge (items expired)
 *      => KEEP TODO: Does it work?
 *  - bulkScheduleReminders: [ScannedItem] -> ()
 *      -> Called by main view model to schedule receipt's worth of reminders
 *      => TODO: Handle error when item is not scheduled ->
 *  - scheduleReminderAtTime: ScannedItem, DateComponents -> UNNotificationRequest
 *      -> Called by bulk schedule and by main view when item added manuualy
 *      => TODO: Return result<UNNotificationRequest, error>
 *  - removeScheduledReminderByName: ScannedItem -> ()
 *      -> Called by UserItemListView when item deleted
 *      => TODO: Return result
 *  - updateScheduledNotification: ScannedItem, Date -> ()
 *      -> Called by UserItemListView when item dates updated
 *      => KEEP
 *  - getAllScheduledNotifications: () -> [UNNotificationRequest]
 *      => KEEP for debugging purposes
 *
 * TODO: TEST
 * Private Functions
 *  - *scheduleReminder: ScannedItem -> UNNotificationRequest
 *      => TODO: schedule individual notification for each item -> DONE
 *  - *removeScheduledReminder: ScannedItem -> ()
        => TODO: remove notification from request dict; remove "updateRequestWithoutItem" -> DONE
 *  - updateRequestWithItem: UNNotificationRequest, ScannedItem -> ()
        => SCUTTLE
 *  - updateRequestWithoutItem: UNNotificationRequest, ScannedItem -> ()
        => SCUTTLE
 *  - updateRequestContentWithItem: UNNotificationContent, ScannedItem -> UNMutableNotificationContent
        => SCUTTLE
 *  - updateRequestContentWithoutItem: UNNotificationContent, ScannedItem -> UNMutableNotificationContent
        => SCUTTLE
 *  - createNotificationContentForItem: String -> UNMutableNotificationContent
        => TODO: Make it individual -> DONE
 *  - createNotificationContentForItems: [String] -> UNMutableNotificationContent
        => TODO: Update message for daily message -> DONE
 *  - addTimeComponentToItem: ScannedItem, DateComponents
        => KEEP; TODO: TEST workind condition
 *  - updateBadge: Int
        => KEEP
 *  - updateScheduledReminder: String, UNNotificationRequest
        => KEEP
 *  UTILITY; KEEP
 *  - retrieveExistingRequestsDict: () -> [String : UNNotificationRequest]
 *  - retrieveExistingRequests: () -> [UNNotificationRequest]
 */

class EatByReminderManager: NSObject {
    /*
     * MARK: Initialization
     */

    // Mutex for synchronization, NOT spam tolerant (can starve threads)
    private let mutex = UnfairLock()
    
    // Singleton
    static let instance = EatByReminderManager()
    private override init() {}

    // Track urgent to-eats
    @AppStorage("numUrgent") var numUrgentToEats: Int = 0
    
    private var svm = SettingsViewModel.shared
    
    /*
     * Ask for permission to send notifications
     * Input: completionHandler, relays success or failure of request
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
            print("INIT: Successfully authorized user notifications!")
        }
    }
    
    /*
     * Called by UNNotificationCenterDelegate functions to update badge
     */
    public func updateIconBadge() {
        UIApplication.shared.applicationIconBadgeNumber = numUrgentToEats
    }
}

// MARK: User External Functions
extension EatByReminderManager {
    /*
     * Schedule one or more new notifications for a list of scanned items
     * Input: [ScannedItem] items - the list of to-be-eaten items
     */
    func bulkScheduleReminders(for items: [ScannedItem]) {
        for item in items {
            let _ = scheduleReminderAtTime(for: item)
        }
    }
    
    /*
     * Schedule an individual new notification for current user some time in the future
     * Input: ScannedItem item - the to-be-eaten item
     *        DateComponents timeComponents
     * Output: UNNotificationRequest request, the newly scheduled notification request
     * Pre-condition: item MUST have a eat-by reminder date
     */
    func scheduleReminderAtTime(for item: ScannedItem, at time: DateComponents = DateComponents(hour: 8)) -> UNNotificationRequest? {
        // Default 8:00 AM
        print("INFO: Scheduling reminder at time \(time.description)")
        
        do {
            let request = try scheduleReminder(for: addTimeComponentToItem(for: item, at: time))
            return request
        } catch (let error) {
            print("FAULT: Could not schedule item \(item.description) bc: \((error as! EatByReminderError).localizedDescription)")
            return nil
        }
       
    }
        
    /*
     * Delete a scheduled notification when item has been eaten AND no other item is scheduled
     *  for that date
     * Input: ScannedItem item, the item eaten and taken off notification schedule
     * Pre-conditions: item MUST exist in core data
     */
    func removeScheduledReminderByName(for item: ScannedItem) {
        do {
            try removeScheduledReminder(for: item)
        } catch (let error) {
            print("FAULT: \((error as! EatByReminderError).localizedDescription)")
        }
    }
    
    func removeAllScheduledReminders() {
        clearScheduledReminders()
    }
    
    /*
     * Update an item's scheduled notification by deleting the old one and replacing
     *  it with the new notification
     * Input: ScannedItem item
     *        Date newDate
     * Pre-conditions: item MUST exist in core data
     */
    func updateScheduledNotification(for item: ScannedItem, at newDate: Date) {
        removeScheduledReminderByName(for: item)
        let _ = scheduleReminderAtTime(for: item, at: Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: newDate)
)
    }
    
    func getAllScheduledNotifications() -> [UNNotificationRequest] {
        return retrieveExistingRequests()
    }
}

// MARK: Internal Functions
extension EatByReminderManager {
    /*
     * Schedule an individual new notification for current user at a specified time in the day
     * Note: Synchronized
     *       throws EatByReminderError,
     * Input: ScannedItem item - the to-be-eaten item
     * Output: UNNotificationRequest request, the newly scheduled notification request
     * Pre-condition: item MUST have a eat-by reminder date
     */
    private func scheduleReminder(for item: ScannedItem) throws -> UNNotificationRequest {
        // Guards
        guard
            let dateToEat = item.dateToRemind
        else {
            throw EatByReminderError("ScannedItem does not have a reminder date.")
        }
        
        guard
            let id = item.id
        else {
            throw EatByReminderError("ScannedItem does not have an id.")
        }
        let name = item.name ?? "unknown"

        // Lock
        mutex.lock()
        var request: UNNotificationRequest?
        
        // Create new request for item
        let content = createNotificationContentForItem(item: name)
        var dateComponents = Calendar.current.dateComponents(
            [.year, .month, .day, .hour, .minute, .second],
            from: dateToEat
        )
        dateComponents.timeZone = TimeZone.current
        print("INFO: Local time zone is \(TimeZone.current.description)")

        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)
        let newRequest = UNNotificationRequest(
            identifier: id.uuidString,
            content: content,
            trigger: trigger
        )
        
        UNUserNotificationCenter.current().add(newRequest)
        print("INFO: Added item \(item.name ?? "unknown") scheduled with request \(newRequest.identifier) triggering at \(newRequest.trigger.debugDescription)")
        
        request = newRequest
        
        // Unlock
        mutex.unlock()
        return request!
    }
    
    /*
     * Delete a scheduled notification when item has been eaten
     * Note: Synchronized
     *       throws EatByReminderError
     * Input: ScannedItem item, item eaten and taken off notification schedule
     * Pre-conditions: item id must exist in requests
     */
    private func removeScheduledReminder(for item: ScannedItem) throws {
        guard
            let identifier = item.id
        else {
            throw EatByReminderError("FAULT: Error retrieving scanned item id")
        }
        // Lock
        mutex.lock()
        
        print("INFO: Removing request with id \(identifier)!")
        UNUserNotificationCenter.current().removePendingNotificationRequests(
            withIdentifiers: [identifier.uuidString]
        )
        
        // Unlock
        mutex.unlock()
    }
    
    
    /*
     * Deletes all scheduled reminders from notification center
     * Note: Synchronized
     */
    private func clearScheduledReminders() {
        // Lock
        mutex.lock()
        
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
        // Unlock
        mutex.unlock()
    }

    /*
     * Update a given scheduled request with its new iteration
     * Input: String identifier, of the legacy request
     *        Request newRequest, the new request
     * Note: if old request does not exist, we just schedule the new request
     */
    private func updateScheduledReminder(for identifier: String, updatedRequest: UNNotificationRequest) {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [identifier])
        UNUserNotificationCenter.current().add(updatedRequest)
    }
    
    /*
     * Create the reminder notification content for one item
     * Input: String item, name of item to remind via this notification
     * Output: UNMutableNotificationContent content
     */
    private func createNotificationContentForItem(item: String) -> UNMutableNotificationContent {
        let title = "Eat Your Stuff!"
        let body = "\(item).\nDon't let it rot and die!!! - 🥺🥦\n"
        let sound: UNNotificationSound = .default
        
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = sound
        
        return content
    }
    
    /*
     * Create the reminder notification content for several items
     * Input: [String] items, items to remind via this notification
     * Output: UNMutableNotificationContent content
     */
    private func createNotificationContentForItems(items: [String]) -> UNMutableNotificationContent {
        let title = "Eat Your Stuff"
        var body = "You have items to eat.\nDon't let them rot and die!!! - 🥺🥦\n"
        
        for item in items {
            body += "\t\(item)\n"
                    }
        let userInfo: [String: Any] = [
            "numItems": items.count, // track whether to have a notification on this day
            "itemNames": items
        ]
        let sound: UNNotificationSound = .default

        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.userInfo = userInfo
        content.sound = sound
        
        return content
    }
    
    /*
     * Add hour, minute, and second to a scanned item's Date struct
     * Input: ScannedItem item, the item in question
     *        DateComponents time, the DateComponent containing the hour, minute, and second
     * Output: ScannItem item, the item with the added hour, minute, and second
     */
    private func addTimeComponentToItem(for item: ScannedItem, at time: DateComponents) -> ScannedItem {
        let dateToEat = item.dateToRemind ?? Date.now
        
        var dateComponents = Calendar.current.dateComponents(
            [.year, .month, .day],
            from: dateToEat
        )
        
        dateComponents.hour = time.hour
        dateComponents.minute = time.minute
        dateComponents.second = time.second
        
        item.dateToRemind = Calendar.current.date(from: dateComponents)!
        
        return item
    }
    
    /*
     * Update Overall badge number
     * Input: Int update, positive: add, negative: subtract
     */
    public func updateBadge(update: Int) {
        numUrgentToEats += update
        print("INFO: Updating shown badge by \(update). Total is \(numUrgentToEats)!")
        UIApplication.shared.applicationIconBadgeNumber = numUrgentToEats
    }
    
    /*
     * Retrieve existing reminders, returned in hash table
     *  where key is the identifying date
     * Output: Dict<String, UNNotificationRequest> existingRequestDict
     */
    private func retrieveExistingRequestsDict() -> [String : UNNotificationRequest] {
        let existingRequests = retrieveExistingRequests()
        var existingRequestDateDict: [String: UNNotificationRequest] = [:]
        for request in existingRequests {
            existingRequestDateDict.updateValue(request, forKey: request.identifier)
        }
        return existingRequestDateDict
    }
        
    /*
     * Retrieve all existing scheduled reminders synchronously
     * Output: [UNNotificationRequest] requests
     */
    private func retrieveExistingRequests() -> [UNNotificationRequest] {
        let group = DispatchGroup()
        group.enter()
        // Retrieve existing notification requests
        var existingRequests: [UNNotificationRequest] = []
        UNUserNotificationCenter.current().getPendingNotificationRequests {
            requests in
            existingRequests.append(contentsOf: requests)
            DispatchQueue.global(qos: .default).async {
                group.leave()
            }
        }
        group.wait()
        return existingRequests
    }
}


// MARK: Deprecated
//extension EatByReminderManager {
//    /*
//     * Update Notification Request with new item
//     * Input: UNNotificationRequest request
//     *        ScannedItem item
//     */
//    private func updateRequestWithItem(request: UNNotificationRequest, item: ScannedItem) {
//        let newContent = updateRequestContentWithItem(content: request.content, item: item)
//        let newRequest = UNNotificationRequest(
//            identifier: request.identifier,
//            content: newContent,
//            trigger: request.trigger
//        )
//        updateScheduledReminder(for: request.identifier, updatedRequest: newRequest)
//    }
//
//    /*
//     * Update Notification Request with new item
//     * Input: UNNotificationRequest request
//     *        ScannedItem item
//     */
//    private func updateRequestWithoutItem(request: UNNotificationRequest, item: ScannedItem)  {
//        let newContent = updateRequestContentWithoutItem(content: request.content, item: item)
//        let newRequest = UNNotificationRequest(
//            identifier: request.identifier,
//            content: newContent,
//            trigger: request.trigger
//        )
//        updateScheduledReminder(for: request.identifier, updatedRequest: newRequest)
//    }
//
//    /*
//     * Update mutable request content
//     * Input: ScannedItem item, new item to update with
//     *        UNMutableNotificationContent content
//     */
//    private func updateRequestContentWithItem(content: UNNotificationContent, item: ScannedItem) -> UNMutableNotificationContent{
//        var items = content.userInfo["itemNames"] as! [String]
//        items.append(item.name ?? "unknown")
//        return createNotificationContentForItems(items: items)
//    }
//
//    /*
//     * Update mutable request content to be without item
//     * Input: ScannedItem item, new item to update with
//     *        UNMutableNotificationContent content
//     */
//    private func updateRequestContentWithoutItem(content: UNNotificationContent, item: ScannedItem) -> UNMutableNotificationContent{
//        let name = item.name ?? "unknown"
//        var items = content.userInfo["itemNames"] as! [String]
//        items.removeAll(where: {$0 == name})
//        return createNotificationContentForItems(items: items)
//    }
//}
