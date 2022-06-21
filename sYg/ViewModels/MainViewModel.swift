//
//  MainViewModel.swift
//  sYg
//
//  Created by Jack Wang on 12/29/21.
//

import SwiftUI
import UIKit
import Combine

/*
 * Encapsulates objs and actions required to get UIKit ImagePicker Functionality
 * Once image is confirmed, sends to Azure for analysis and returns results 
 */

// TODO: Beta 2.3. Split into two vm, mainvm and scannervm 
class MainViewModel: ObservableObject {
    
    /*
     * MARK: Initialization
     */

    static var shared = MainViewModel()
    private init() {}
    
    // View models
    private var sivm = ScannedItemViewModel.shared
    private var evm = EditViewModel.shared

    // To make requests to Azure Receipt Analyzer
    private let azureHTTPManager = AzureHTTPManager(session: URLSession.shared)
    
    // Receipt popovers
    @Published var selectReceipt: Bool = false
    @Published var showScannedReceipt: Bool = false
    
    // Receipt to display for confirmation
    @Published var receipt: UIImage?
    
    // Variables for camera / photo library
    @Published var showSelector = false
    @Published var source: Selector.Source = .library
    @Published var showCameraAlert = false
    @Published var cameraError: Selector.CameraErrorType?
    
    // Loading circle
    @Published var showProgressDialog: Bool = false
    @Published var progressMessage = "Working..."

    // Alerts on MainView
    @Published var showAlert: Bool = false
    @Published var alertTitle: String = ""
    @Published var alertText: String = ""
    @Published var error: Error?
    @Published var showNavPrompt: Bool = false
    @Published var navToRecentlyScanned: Bool = false

    // For editing items on MainView
    @Published var showEdit: Bool = false
    
    // iCloud Storage
    @Published var cancellables = Set<AnyCancellable>()
    
}

// MARK: View functions
extension MainViewModel {
    
    func addSubscriberToEdit() {
        evm.$confirmed
            .combineLatest(evm.$viewToEdit)
            .sink {
                [weak self]
                (isSuccessful, viewToEdit) in
                
                guard let self = self else { return }
                
                if isSuccessful,
                   viewToEdit == .manualAddView {

                    let newItem = self.evm.saveEditsToUserItem()

                    print("DEBUGGING >>> CONFIRM MANUAL ADD IN LIST VIEW")

                    self.sivm.addScannedItem(userItem: newItem) {
                        result in
                            switch result {
                            case .success(let item):
                                // Schedule notification
                                let _ = EatByReminderManager.instance.scheduleReminderAtTime(for: item)
                                print("INFO: Successfully saved item")
                            case .failure(let error):
                                self.error = error
                                print("FAULT: Item not added")
                            
                            DispatchQueue.main.async {
                                self.alertText = "Edit Saved!"
                                self.alertTitle = "Add Result"
                                self.showAlert.toggle()
                                
                                // DEBUG
                                print("DEBUGGING: ALL SCHEDULED NOTIFICATIONS ***")
                                print(EatByReminderManager.instance.getAllScheduledNotifications())
                            }
                        }
                    }
          
                    
                   
                }
            }
            .store(in: &cancellables)
    }
    
    /*
     * Brings up camera to scan receipt
     */
    func showReceiptSelector () {
        do {
            if source == .camera {
                try Selector.checkPermissions()
            }
            showSelector = true
        } catch {
            handleError(error: error)
        }
    }
    
    func resetAlert() {
        self.alertTitle = ""
        self.alertText = ""
        self.showNavPrompt = false
    }
    
    func showError(error: Error) {
        self.handleError(error: error)
    }
    
    /*
     * Display API Request failure
     */
    private func handleError(error: Error?) {
        DispatchQueue.main.async {
            self.showAlert.toggle()
            self.showProgressDialog.toggle()
            self.error = error
        }
    }
}

// MARK: Receipt Analysis Functions
extension MainViewModel {
    /*
     * Analyze Scanned Image and Retrieve Receipt Info
     * INPUT: UIImage optional, the scanned receipt
     */
    func analyzeReceiptAndStore(receipt: UIImage) async {
        self.toggleProgressDialog()
        do {
            let workingLocation = try await self.azureHTTPManager.postReceiptImage(receipt: receipt)
            let analyzedReceipt = try await self.azureHTTPManager.getAnalyzedReceipt(workingLocation: workingLocation)
                
            let (analyzedItems, transactionDateString) = try self.extractReceiptInfo(analyzedReceipt: analyzedReceipt)
            let transactionDate: Date = self.formatToDate(dateString: transactionDateString)
            let (scannedItems, matchedItems, numMatchDefaults) = self.convertAndMatchAnalyzedItems(analyzedItems: analyzedItems, at: transactionDate)

            DispatchQueue.main.async {
                self.storeAndScheduleScannedItems(scannedItems: scannedItems)

                /*
                 * SUCCESS!
                 */
                self.alertTitle = "Scanning Result"
                self.alertText = "Successfully scanned!"
                if !matchedItems.isEmpty {
                    self.showNavPrompt.toggle()
                    self.alertText += "\n \(matchedItems.count - numMatchDefaults) items were matched to a generic item and \(numMatchDefaults) used the default eat-by interval."
                    UserSuggestionViewModel.shared.matchedItems = matchedItems
                }
                self.showAlert.toggle()
                self.showProgressDialog.toggle()
            }
        } catch {
            self.handleError(error: error)
        }
    }
    
    /*
     * Input: AnalyzedReceipt json
     * Output: List of scanned AnalzyedItems
     *        String transaction date extracted or default
     */
    func extractReceiptInfo(analyzedReceipt: AnalyzedReceipt) throws -> ([AnalyzedItem], String) {
        guard
            let analyzeResults = analyzedReceipt.analyzeResult
        else {
            throw ReceiptScanningError("Invalid receipt! Please scan again!")
        }
        
        let documentResults = analyzeResults.documentResults
        let fields: [String: Field] = documentResults[0].fields
        
        guard
            let items = fields["Items"],
            let itemsArray = items.valueArray
        else {
            throw ReceiptScanningError("Invalid receipt! Please scan again!")
        }
    
        let transactionDateString: String = fields["TransactionDate"]?.valueDate ?? DateFormatter.localizedString(from: Date.now, dateStyle: .medium, timeStyle: .medium)
        return (itemsArray, transactionDateString)
    }
    
    func formatToDate(dateString: String) -> Date {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        dateFormatter.dateFormat = "YYYY-MM-DD"
        dateFormatter.timeZone = TimeZone(abbreviation: "UTC-6") // TODO: Update to be local
        
        return dateFormatter.date(from: dateString) ?? Date.now
    }
    
    func convertAndMatchAnalyzedItems(analyzedItems: [AnalyzedItem], at dateOfPurchase: Date) -> ([UserItem], [MatchedItem], Int){
        // Get expiration time interval
        let itemMatcher = ItemMatcher.matcher
        var scannedItems: [UserItem] = []
        var matchedItems: [MatchedItem] = []
        var numMatchDefaults: Int = 0
        
        for item in analyzedItems {
            let name = item.valueObject["Name"]?.valueString ?? "Unknown"
            var dateToRemind: Date = dateOfPurchase
            
            // Look up existing matches
            if let eatByInterval = itemMatcher.getEatByInterval(for: name) {
                dateToRemind += eatByInterval
            } else {
                // Otherwise find best match and record
                var matchedItem = MatchedItem(scannedItemName: name, genericItem: nil)
                if let genericItem = itemMatcher.matchScannedItem(for: name) {
                    matchedItem.GenericItemObj = genericItem
                    
                    // Currently default to days in fridge
                    dateToRemind += genericItem.DaysInFridge
                } else {
                    numMatchDefaults += 1
                }
                matchedItems.append(matchedItem)
            }

            scannedItems.append(
                UserItem(
                    NameFromAnalysis: name,
                    Name: name,
                    DateOfPurchase: dateOfPurchase,
                    DateToRemind: dateToRemind,
                    Category: .unknown,
                    Storage: .unknown
                )
            )
        }
        print("INFO: \(scannedItems.count) items scanned and matched.")
        return (scannedItems, matchedItems, numMatchDefaults)
    }
    
    func storeAndScheduleScannedItems(scannedItems: [UserItem]) {
        print("INFO: Scheduling scanned items.")
        // Add to user's displayed list
        sivm.addScannedItems(userItems: scannedItems) {
            results in
            // Schedule reminders for each added item
            EatByReminderManager.instance.bulkScheduleReminders(for: ScannedItemViewModel.shared.scannedItems)
            
            // Check for error saving items
//            if let results = results {
//                var errors: [(String, Error)] = []
//                for (result, name) in results {
//                    switch result {
//                    case .failure(let error):
//                        errors.append((name, error))
//                    case .success:
//                        break
//                    }
//                }
//                if !errors.isEmpty {
//                    DispatchQueue.main.async {
//                        var errorMsg = "Could not save/schedule these items\n"
//                        for (name, error) in errors {
//                            errorMsg += "\t\(name): \(error.localizedDescription)"
//                        }
//                        self.error = EatByReminderError(errorMsg)
//                    }
//                }
            }
    }
    
    func toggleProgressDialog() {
        // Display progress dialog
        DispatchQueue.main.async {
            self.showProgressDialog.toggle()
        }
    }
}
