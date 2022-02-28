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
    
    // Mutex for synchronization, NOT spam tolerant (can starve threads)
    private let mutex = UnfairLock()
    
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
    
//    /*
//     * Do we have permissions?
//     * Output: [Bool] authorizationStatus, whether alerts, sounds, and badges are enabled
//     */
//    func getAuthorizationStatuses() -> [Bool] {
//        var authorizationStatus: [Bool] = []
//        UNUserNotificationCenter.current().getNotificationSettings(completionHandler: {
//            settings in
//
//            authorizationStatus.append(settings.alertSetting == UNNotificationSetting.enabled)
//            authorizationStatus.append(settings.soundSetting == UNNotificationSetting.enabled)
//            authorizationStatus.append(settings.badgeSetting == UNNotificationSetting.enabled)
//        })
//        return authorizationStatus
//    }
    
    
    /*
     * Schedule one or more new notifications for a list of scanned items
     * Note: Synchronized
     * Input: [ScannedItem] items - the list of to-be-eaten items
     */
    func bulkScheduleReminders(for items: [ScannedItem]) {
        for item in items {
            do {
                let _ = try scheduleReminder(for: item)
            } catch (let error) {
                print("FAULT: could not schedule item \(item.description) bc error \(error.localizedDescription)")
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
            print("FAULT: could not schedule item \(item.description) bc error \(error.localizedDescription)")
            return nil
        }
       
    }
        
    /*
     * Delete a scheduled notification when item has been eaten AND no other item is scheduled
     *  for that date
     * Input: ScannedItem item, the item eaten and taken off notification schedule
     * Pre-conditions: item MUST exist in core data
     */
    func removeScheduledReminder(for item: ScannedItem) {
        guard
            let identifier = item.dateToRemind?.getFormattedDate(format: TimeConstants.reminderDateFormat)
        else {
            print("FAULT: Error retrieving scanned item reminder date")
            return
        }
        print("DEBUG >>> Removing item \(item.debugDescription)")
        
        do {
            try removeScheduledReminder(for: identifier)
        } catch (let error) {
            print("FAULT: Error \(error.localizedDescription)")
        }
    }
    
    /*
     * Delete a scheduled notification when item has been eaten AND no other item is scheduled
     *  for that date
     * Input: String identifier, the id of the item eaten and taken off notification schedule
     * Pre-conditions: id must exist in requests
     */
    func removeScheduledReminderID(for identifier: String) {
        do {
            try removeScheduledReminder(for: identifier)
        } catch (let error) {
            print("FAULT: Error \(error.localizedDescription)")
        }
    }
    
    /*
     * Update existing request to a different date
     * Note: synchronized
     * Input: String oldIdentifier, the old date id
     *        String newIdentiifer, the new date id
     */
    func updateRequestDate(oldIdentifier: String, newIdentifier: String) {
        // Lock
        mutex.lock()

        // TODO: TODO

        // Unlock
        mutex.unlock()
    }
    
    /*
     * TODO: Later, creating more meaningful notification messages?
     * 1. Retrieve identifying dates from
     * 2. Find items whose eat-by dates intersect with existing request dates
     * 3. Add # to existing request's badge
     */
    
    private func createNotificationContent(badge: NSNumber) -> UNMutableNotificationContent {
        let content = UNMutableNotificationContent()
        content.title = "Eat Yo Shit"
        content.subtitle = "You have items to eat. Don't let them rot and die!!! - 🥦"
        content.sound = .default
        content.badge = badge
        
        return content
    }
    
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
     * Schedule an individual new notification for current user at a specified time in the day
     *  IF the day doesn't have a notification scheduled yet.
     * Note: Synchronized
     * Input: ScannedItem item - the to-be-eaten item
     * Output: UNNotificationRequest request, the newly scheduled notification request
     * Pre-condition: item MUST have a eat-by reminder date
     */
    private func scheduleReminder(for item: ScannedItem) throws -> UNNotificationRequest {
        // Lock
        mutex.lock()
        
        // Create new requests for non-intersecting items
        let existingRequestDateDict: [String: UNNotificationRequest] = retrieveExistingRequestsDict()

        guard
            let dateToEat = item.dateToRemind
        else {
            mutex.unlock()
            throw EatByReminderErrors("ScannedItem does not have a reminder date.")
        }
        let formattedDateToEat = dateToEat.getFormattedDate(format: TimeConstants.reminderDateFormat)
        print("DEBUG >>> Requests outstanding: \(existingRequestDateDict.debugDescription)")
        print("DEBUG >>> Date to schedule: \(formattedDateToEat.debugDescription)")
        
        var request: UNNotificationRequest?
        
        // Request date doesn't exist
        if !existingRequestDateDict.keys.contains(formattedDateToEat) {
            let content = createNotificationContent(badge: 1)
            
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
            print("INFO: Added item \(item.name ?? "") scheduled with request \(newRequest.identifier) triggering at \(newRequest.trigger.debugDescription)")
            
            request = newRequest
        }
        // Request date does exist
        else {
            // Add 1 to existing request badge
            let existingRequest = existingRequestDateDict[formattedDateToEat]
            do {
                request = try updateRequestBadge(request: existingRequest, update: 1)
            } catch (let error) {
                mutex.unlock()
                throw error
            }
        }
        
        // Unlock
        mutex.unlock()
        return request!
    }
    
    /*
     * Delete a scheduled notification when item has been eaten AND no other item is scheduled
     *  for that date
     * Note: Synchronized
     * Input: String identifier, the id of the item eaten and taken off notification schedule
     * Pre-conditions: id must exist in requests
     */
    private func removeScheduledReminder(for identifier: String) throws {
        // Lock
        mutex.lock()

        let existingRequestDateDict: [String: UNNotificationRequest] = retrieveExistingRequestsDict()
        
        // Get # of items via badges
        let existingRequest = existingRequestDateDict[identifier]
        guard
            let requestContent = existingRequest?.content,
            let existingBadgeNumber = requestContent.badge?.intValue
        else {
            mutex.unlock()
            throw EatByReminderErrors("FAULT: Error retrieving existing request content or badge")
        }
        
        print("DEBUG >>> Removing item \(identifier)")
        
        if (existingBadgeNumber > 1) {
            do {
                let _ = try updateRequestBadge(request: existingRequest, update: -1)
            } catch (let error) {
                mutex.unlock()
                throw error
            }
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
     * Update request badge number
     * Input: UNNotificationRequest request,
     *        Int update, positive: add, negative: subtract
     */
    private func updateRequestBadge(request: UNNotificationRequest?, update: Int) throws -> UNNotificationRequest{
        guard
            let requestContent = request?.content,
            let existingBadgeNumber = requestContent.badge?.intValue,
            let trigger = request?.trigger,
            let formattedDateToEat = request?.identifier
        else {
            // TODO: Update error handling - need to down cast to get actual description.
            // EatByReminderErrors -> EatByReminderError
            // Also account for UNNotification errors
            // ALso change SIVM error handling to be in external SIVIM functions, shouldn't handle in view. 
            throw EatByReminderErrors("Could not retrieve request content, badge, or trigger.")
        }
        let updatedBadgeNumber: Int = existingBadgeNumber + update
        let updatedContent = createNotificationContent(badge: updatedBadgeNumber as NSNumber)
        
        let updatedRequest = UNNotificationRequest(
            identifier: formattedDateToEat,
            content: updatedContent,
            trigger: trigger
        )

        print("INFO: Updating badge for \(formattedDateToEat) by \(update). Total: \(updatedBadgeNumber)!")
        updateScheduledReminder(for: formattedDateToEat, updatedRequest: updatedRequest)
        return updatedRequest
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
    
    /*
     * MARK: TESTING
     */
    func getNumExistingRequests() -> Int {
        print("DEBUG >>> fetching number of existing requests")

        let reqs = retrieveExistingRequests()
        return reqs.capacity
    }
    
    func scheduleReminderSecFromNow(timeFromNow: TimeInterval) {
        let testDate = Date(timeIntervalSinceNow: timeFromNow)
        let scannedItem = ScannedItemViewModel.shared.createScannedItem(name: "TEST1", dateToRemind: testDate)
        
        do {
            let _ = try scheduleReminder(for: scannedItem)
        } catch (let error) {
            print("FAULT: Error \(error.localizedDescription)")
        }
    }

    func cancelAllNotifications() {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
        UNUserNotificationCenter.current().removeAllDeliveredNotifications()
    }
}
