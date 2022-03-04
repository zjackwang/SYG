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
    @AppStorage("numUrgent") private var numUrgentToEats = 0
    
    public func updateIconBadge() {
        UIApplication.shared.applicationIconBadgeNumber = numUrgentToEats
    }
    
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
        for item in items {
            do {
                let _ = try scheduleReminder(for: item)
            } catch (let error) {
                print("FAULT: Could not schedule item \(item.description) bc: \((error as! EatByReminderError).localizedDescription)")
            }
        }
    }
    
    /*
     * Schedule an individual new notification for current user some time in the future
     * Input: ScannedItem item - the to-be-eaten item
     *        DateComponents timeComponents
     * Output: UNNotificationRequest request, the newly scheduled notification request
     * Pre-condition: item MUST have a eat-by reminder date
     */
    func scheduleReminder(for item: ScannedItem, at time: DateComponents = DateComponents(hour: 8)) -> UNNotificationRequest? {
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
    
    /*
     * MARK: Internal Functions
     */
    
    /*
     * Schedule an individual new notification for current user at a specified time in the day
     *  IF the day doesn't have a notification scheduled yet.
     * Note: Synchronized
     *       throws EatByReminderError,
     * Input: ScannedItem item - the to-be-eaten item
     * Output: UNNotificationRequest request, the newly scheduled notification request
     * Pre-condition: item MUST have a eat-by reminder date
     */
    private func scheduleReminder(for item: ScannedItem) throws -> UNNotificationRequest {
        // Lock
        mutex.lock()
        
        let existingRequestDateDict: [String: UNNotificationRequest] = retrieveExistingRequestsDict()

        guard
            let dateToEat = item.dateToRemind
        else {
            mutex.unlock()
            throw EatByReminderError("ScannedItem does not have a reminder date.")
        }
        let formattedDateToEat = dateToEat.getFormattedDate(format: TimeConstants.reminderDateFormat)
        var request: UNNotificationRequest?
        
        // Request date doesn't exist
        if !existingRequestDateDict.keys.contains(formattedDateToEat) {
            // Create new request for item
            let content = createNotificationContentForItem(item: item.name ?? "unknown")
            var dateComponents = Calendar.current.dateComponents(
                [.year, .month, .day, .hour, .minute, .second],
                from: dateToEat
            )
            dateComponents.timeZone = TimeZone.current
            print("INFO: Local time zone is \(TimeZone.current.description)")

            let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)
            let newRequest = UNNotificationRequest(
                // Use yyyy-MM-dd format to intersect with future scanned items
                // NOTE: only ONE request per day
                identifier: formattedDateToEat,
                content: content,
                trigger: trigger
            )
            
            UNUserNotificationCenter.current().add(newRequest)
            print("INFO: Added item \(item.name ?? "unknown") scheduled with request \(newRequest.identifier) triggering at \(newRequest.trigger.debugDescription)")
            
            request = newRequest
        }
        // Request date does exist
        else {
            let existingRequest = existingRequestDateDict[formattedDateToEat]
            updateRequestWithItem(request: existingRequest!, item: item)
            request = existingRequest
        }
        
        // Unlock
        mutex.unlock()
        return request!
    }
    
    /*
     * Delete a scheduled notification when item has been eaten AND no other item is scheduled
     *  for that date
     * Note: Synchronized
     *       throws EatByReminderError
     * Input: ScannedItem item, item eaten and taken off notification schedule
     * Pre-conditions: item id must exist in requests
     */
    private func removeScheduledReminder(for item: ScannedItem) throws {
        guard
            let identifier = item.dateToRemind?.getFormattedDate(format: TimeConstants.reminderDateFormat)
        else {
            throw EatByReminderError("FAULT: Error retrieving scanned item reminder date")
        }
        // Lock
        mutex.lock()
        
        let existingRequestDateDict: [String: UNNotificationRequest] = retrieveExistingRequestsDict()
        
        guard
            let existingRequest = existingRequestDateDict[identifier]
        else {
            // Not here!
            mutex.unlock()
            return
        }
        let userInfo = existingRequest.content.userInfo
        let numItems = userInfo["numItems"] as! Int
        
        if (numItems > 1) {
            updateRequestWithoutItem(request: existingRequest, item: item)
        } else {
            print("INFO: Removing request with id \(identifier)!")
            UNUserNotificationCenter.current().removePendingNotificationRequests(
                withIdentifiers: [identifier]
            )
        }
        
        // Unlock
        mutex.unlock()
    }
    
    /*
     * Update Notification Request with new item
     * Input: UNNotificationRequest request
     *        ScannedItem item
     */
    private func updateRequestWithItem(request: UNNotificationRequest, item: ScannedItem) {
        let newContent = updateRequestContentWithItem(content: request.content, item: item)
        let newRequest = UNNotificationRequest(
            identifier: request.identifier,
            content: newContent,
            trigger: request.trigger
        )
        updateScheduledReminder(for: request.identifier, updatedRequest: newRequest)
    }
    
    /*
     * Update Notification Request with new item
     * Input: UNNotificationRequest request
     *        ScannedItem item
     */
    private func updateRequestWithoutItem(request: UNNotificationRequest, item: ScannedItem) {
        let newContent = updateRequestContentWithoutItem(content: request.content, item: item)
        let newRequest = UNNotificationRequest(
            identifier: request.identifier,
            content: newContent,
            trigger: request.trigger
        )
        updateScheduledReminder(for: request.identifier, updatedRequest: newRequest)
    }
    
    /*
     * Update mutable request content
     * Input: ScannedItem item, new item to update with
     *        UNMutableNotificationContent content
     */
    private func updateRequestContentWithItem(content: UNNotificationContent, item: ScannedItem) -> UNMutableNotificationContent{
        var items = content.userInfo["itemNames"] as! [String]
        items.append(item.name ?? "unknown")
        return createNotificationContentForItems(items: items)
    }
    
    /*
     * Update mutable request content to be without item
     * Input: ScannedItem item, new item to update with
     *        UNMutableNotificationContent content
     */
    private func updateRequestContentWithoutItem(content: UNNotificationContent, item: ScannedItem) -> UNMutableNotificationContent{
        let name = item.name ?? "unknown"
        var items = content.userInfo["itemNames"] as! [String]
        items.removeAll(where: {$0 == name})
        return createNotificationContentForItems(items: items)
    }

    /*
     * Create the reminder notification content for one item
     * Input: String item, name of item to remind via this notification
     * Output: UNMutableNotificationContent content
     */
    private func createNotificationContentForItem(item: String) -> UNMutableNotificationContent {
        return createNotificationContentForItems(items: [item])
    }
    
    /*
     * Create the reminder notification content for several items
     * Input: [String] items, items to remind via this notification
     * Output: UNMutableNotificationContent content
     */
    private func createNotificationContentForItems(items: [String]) -> UNMutableNotificationContent {
        let title = "Eat Yo Shit"
        var body = "You have items to eat. Don't let them rot and die!!! - 🥺🥦\n"
        
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
        let dateToEat = item.dateToRemind!

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
}
