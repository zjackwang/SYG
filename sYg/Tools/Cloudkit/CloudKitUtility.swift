//
//  CloudKitUtility.swift
//  sYg
//
//  Created by Jack Wang on 3/29/22.
//

import SwiftUI
import CloudKit
import Combine

/*
 * CloudKit interface
 */
class CloudKitUtility {
    
    enum CloudKitError: LocalizedError {
        case iCloudAccountNotFound
        case iCloudAccountNotDetermined
        case iCloudAccountRestricted
        case iCloudAccountUnknown
        case iCloudApplicationPermissionNotGranted
        case iCloudCouldNotFetchUserRecordID
        case iCloudCouldNotDiscoverUser
    }
}


// MARK: User Functions
extension CloudKitUtility {
    
    // Stateless, no need for class instance
    static private func getiCloudStatus(completionHandler: @escaping (Result<Bool, Error>) -> ()) {
        CKContainer.default().accountStatus {
            returnedStatus, returnedError in
                switch returnedStatus {
                case .couldNotDetermine:
                    completionHandler(.failure(CloudKitError.iCloudAccountNotDetermined))
                case .available:
                    completionHandler(.success(true))
                case .restricted:
                    completionHandler(.failure(CloudKitError.iCloudAccountRestricted))
                case .noAccount:
                    completionHandler(.failure(CloudKitError.iCloudAccountNotFound))
                case .temporarilyUnavailable:
                    completionHandler(.failure(CloudKitError.iCloudAccountUnknown))
                @unknown default:
                    completionHandler(.failure(CloudKitError.iCloudAccountUnknown))
                }
        }
    }
    
    static func getiCloudStatus() -> Future<Bool, Error> {
        Future {
            promise in
            CloudKitUtility.getiCloudStatus {
                result in
                promise(result)
            }
        }
    }
    
    static private func requestApplicationPermission(completionHandler: @escaping (Result<Bool, Error>) -> ()) {
        CKContainer.default().requestApplicationPermission([.userDiscoverability]) {
            returnedStatus, returnedError in
            DispatchQueue.main.async {
                if returnedStatus == .granted {
                    completionHandler(.success(true))
                } else {
                    completionHandler(.failure(CloudKitError.iCloudApplicationPermissionNotGranted))
                }
            }
        }
    }
    
    static func requestApplicationPermission() -> Future<Bool, Error> {
        Future {
            promise in
            CloudKitUtility.requestApplicationPermission {
                result in
                promise(result)
            }
        }
    }
    
    static private func fetchUserRecordID(completionHandler: @escaping (Result<CKRecord.ID, Error>) -> ()) {
        CKContainer.default().fetchUserRecordID {
            returnedID, returnedError in
            if let id = returnedID {
                completionHandler(.success(id))
            } else {
                completionHandler(.failure(CloudKitError.iCloudCouldNotFetchUserRecordID))
            }
        }
    }
    
    static private func discoverUserIdentity(id: CKRecord.ID, completionHandler: @escaping (Result<String, Error>) -> ()) {
        CKContainer.default().discoverUserIdentity(withUserRecordID: id) {
            returnedIdentity, returnedError in
            DispatchQueue.main.async {
                if let name = returnedIdentity?.nameComponents?.givenName {
                    completionHandler(.success(name))
                } else {
                    completionHandler(.failure(CloudKitError.iCloudCouldNotDiscoverUser))
                }
            }
        }
    }
    
    static private func discoverUserIdentity(completionHandler: @escaping (Result<String, Error>) -> ()) {
        fetchUserRecordID {
            fetchCompletion in
            switch fetchCompletion {
            case .success(let recordID):
                CloudKitUtility.discoverUserIdentity(id: recordID, completionHandler: completionHandler)
            case .failure(let error):
                completionHandler(.failure(error))
            }
        }
    }
    
    static func discoverUserIdentity() -> Future<String, Error> {
        Future {
            promise in
            CloudKitUtility.discoverUserIdentity {
                result in
                promise(result)
            }
        }
    }
}


// MARK: CRUD Public Functions
extension CloudKitUtility {
    
    static func fetch<T: CloudKitableProtocol>(
        predicate: NSPredicate,
        recordType: CKRecord.RecordType,
        sortDescriptors: [NSSortDescriptor]? = nil,
        resultsLimit: Int? = nil
    ) -> Future<[T], Error> {
        Future {
            promise in
            CloudKitUtility.fetch(predicate: predicate, recordType: recordType, sortDescriptors: sortDescriptors, resultsLimit: resultsLimit) {
                (items: [T]) in
                promise(.success(items))
            }
        }
    }
    
    static func add<T: CloudKitableProtocol>(item: T) -> Future<Bool, Error> {
        Future {
            promise in
            CloudKitUtility.add(item: item) {
                result in
                promise(result)
            }
        }
    }
    
    static func update<T: CloudKitableProtocol>(item: T) -> Future<Bool, Error> {
        Future {
            promise in
            CloudKitUtility.update(item: item) {
                result in
                promise(result)
            }
        }
    }
    
    static func delete<T: CloudKitableProtocol>(item: T) -> Future<Bool, Error> {
        Future {
            promise in
            CloudKitUtility.delete(item: item) {
                result in
                promise(result)
            }
        }
    }
}

// MARK: CRUD Private Functions
extension CloudKitUtility {
    static private func fetch<T: CloudKitableProtocol>(
        predicate: NSPredicate,
        recordType: CKRecord.RecordType,
        sortDescriptors: [NSSortDescriptor]? = nil,
        resultsLimit: Int? = nil,
        completionHandler: @escaping (_ items: [T]) -> ()
    ) {
        
        // Create operation
        let operation = createOperation(predicate: predicate, recordType: recordType, sortDescriptors: sortDescriptors, resultsLimit: resultsLimit)
        
        // Get items in query
        var returnedItems: [T] = []

        // Record matched block
        addRecordMatchedBlock(operation: operation) {
            item in
            returnedItems.append(item)
        }
        
        // Query Completion
        addQueryResultBlock(operation: operation) {
            finished in
            completionHandler(returnedItems)
        }
        
        // Execute operation
        addOperation(operation: operation)
    }
    
    static private func createOperation(
        predicate: NSPredicate,
        recordType: CKRecord.RecordType,
        sortDescriptors: [NSSortDescriptor]? = nil,
        resultsLimit: Int? = nil
    ) -> CKQueryOperation {
            let query = CKQuery(recordType: recordType, predicate: predicate)
            query.sortDescriptors = sortDescriptors
            
            let queryOperation = CKQueryOperation(query: query)
            if let resultsLimit = resultsLimit {
                queryOperation.resultsLimit = resultsLimit
            }
            return queryOperation
    }
    
    static private func addRecordMatchedBlock<T: CloudKitableProtocol>(operation: CKQueryOperation, completionBlock: @escaping (_ item: T) -> ()) {
        if #available(iOS 15.0, *) {
            operation.recordMatchedBlock = {
                returnedRecordID, returnedResult in
                switch returnedResult {
                case .success(let record):
                    guard
                        let item = T(record: record)
                    else {
                        return
                    }
                    completionBlock(item)
                case .failure(let error):
                    print("Error recordMatchedBlock: \(error)")
                }
            }
        } else {
            operation.recordFetchedBlock = {
                record in
                guard
                    let item = T(record: record)
                else {
                    return
                }
                completionBlock(item)
            }
        }
    }
    
    static private func addQueryResultBlock(operation: CKQueryOperation, completionBlock: @escaping (_ finished: Bool) -> ()) {
        if #available(iOS 15.0, *) {
            operation.queryResultBlock = {
                _ in
                completionBlock(true)
            }
        } else {
            operation.queryCompletionBlock = {
                _, _ in
                completionBlock(true)
            }
        }
    }
    
    static private func addOperation(operation: CKDatabaseOperation) {
        CKContainer.default().publicCloudDatabase.add(operation)
    }
    
    static private func add<T: CloudKitableProtocol>(item: T, completionHandler: @escaping (Result<Bool, Error>) -> ()) {
        
        // Will have record
        let record = item.record

        // Save to iCloud
        CloudKitUtility.save(record: record, completionHandler: completionHandler)
    }
    
    static private func update<T: CloudKitableProtocol>(item: T, completionHandler: @escaping (Result<Bool, Error>) -> ()) {
        
        CloudKitUtility.add(item: item, completionHandler: completionHandler)
    }
    
    static private func save(record: CKRecord, completionHandler: @escaping (Result<Bool, Error>) -> ()) {
        CKContainer.default().publicCloudDatabase.save(record) {
            returnedRecord, returnedError in
            if let returnedError = returnedError {
                completionHandler(.failure(returnedError))
            } else {
                completionHandler(.success(true))
            }
        }
    }
    
    static private func delete<T: CloudKitableProtocol>(item: T, completionHandler: @escaping (Result<Bool, Error>) -> ()) {
        CloudKitUtility.delete(record: item.record, completionHandler: completionHandler)
    }
    
    static private func delete(record: CKRecord, completionHandler: @escaping (Result<Bool, Error>) -> ()) {
        CKContainer.default().publicCloudDatabase.delete(withRecordID: record.recordID) {
            returnedRecordID, returnedError in
            if let returnedError = returnedError {
                completionHandler(.failure(returnedError))
            } else {
                completionHandler(.success(true))
            }
        }
    }
}

// MARK: Push Notification Functions
extension CloudKitUtility {
    
    static func requestNotificationPermissions() -> Future<Bool, Error> {
        Future {
            promise in
            CloudKitUtility.requestNotificationPermissions {
                success, error in
                if let error = error {
                    promise(.failure(error))
                } else {
                    promise(.success(success))
                }
            }
        }
    }
    
    static private func requestNotificationPermissions(completionHandler: @escaping (Bool, Error?) -> ()) {
        let options: UNAuthorizationOptions = [.alert, .sound, .badge]
        UNUserNotificationCenter.current().requestAuthorization(options: options, completionHandler: completionHandler)
    }

    static func subscribeToNotifications(subscription: CKQuerySubscription) -> Future<Bool, Error> {
        Future {
            promise in
            CloudKitUtility.subscribeToNotifications(subscription: subscription) {
                result in
                promise(result)
            }
        }
    }
    
    static private func subscribeToNotifications(subscription: CKQuerySubscription, completionHandler: @escaping (Result<Bool, Error>) -> ()) {
        CKContainer.default().publicCloudDatabase.save(subscription) {
            returnedSubscription, returnedError in
            if let returnedError = returnedError {
                completionHandler(.failure(returnedError))
            } else {
                completionHandler(.success(true))
            }
        }
    }
    
    static func unsubscribeToNotifiations(id: CKSubscription.ID) -> Future<String, Error> {
        Future {
            promise in
            CloudKitUtility.unsubscribeToNotifications(id: id) {
                result in
                promise(result)
            }
        }
    }
    
    static private func unsubscribeToNotifications(id: CKSubscription.ID, completionHandler: @escaping (Result<String, Error>) -> ()) {
        CKContainer.default().publicCloudDatabase.delete(withSubscriptionID: id) {
            returnedID, returnedError in
            if let returnedError = returnedError {
                completionHandler(.failure(returnedError))
            } else if let returnedID = returnedID {
                completionHandler(.success(returnedID))
            }
        }
    }
    
}

