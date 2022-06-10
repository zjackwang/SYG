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
    private var cvm = ConfirmationViewModel.shared
    
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
    
    // Analysis status variable
    @Published var analysisResult: Result<[String: Any], Error>?
    
    // Azure variables
    private let azureHTTPManager: AzureHTTPManager = AzureHTTPManager(session: URLSession.shared)
    private let endpoint: String = "https://\(Info.envVars?["Azure_Endpoint"] ?? "").cognitiveservices.azure.com/"
    private let key: String = Info.envVars?["Azure_Key"] ?? ""
    
    // Returned from Azure
    @Published var scannedReceipt: AnalyzedReceipt?
    
    // Loading circle
    @Published var showProgressDialog: Bool = false
    @Published var progressMessage = "Working..."

    // Confirmation View
    @Published var showConfirmationView: Bool = false
    
    // DEPRECATED Confirmation of success
    @Published var showConfirmationAlert: Bool = false
    @Published var confirmationTitle: String = ""
    @Published var confirmationText: String = ""
    
    // Alerts on MainView
    @Published var showAlert: Bool = false
    @Published var alertTitle: String = ""
    @Published var alertText: String = ""
    @Published var error: Error?
    
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
                                self.confirmationText = "Edit Saved!"
                                self.confirmationTitle = "Add Result"
                                self.showConfirmationAlert.toggle()
                                
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
    
    func showError(error: Error) {
        self.handleError(error: error)
    }
    
    /*
     * Display API Request failure
     */
    private func handleError(error: Error?) {
        DispatchQueue.main.async {
            self.showAlert.toggle()
//            self.showProgressDialog.toggle()
            self.error = error
        }
    }
}

// MARK: Receipt Analysis Functions

extension MainViewModel {
    
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
    
    /*
     * Callback for the analyzeImage function, upon success
     *  - converts AnalyzedReceipt struct into list of UserItem structs
     *  - adds to user defaults via scanned items view model
     */
    func imageAnalyzedSuccesfully() {
        print("INFO: Image analyzed successfully. Now validating receipt.")
        
        /*
         * Validate returned receipt
         */
        
        guard
            let scannedReceipt = scannedReceipt,
            let analyzeResults = scannedReceipt.analyzeResult
        else {
            handleError(error: ReceiptScanningError("Invalid receipt! Please scan again!"))
            return
        }
        
        let documentResults = analyzeResults.documentResults
        let fields: [String: Field] = documentResults[0].fields
        
        guard
            let items = fields["Items"],
            let itemsArray = items.valueArray
        else {
            handleError(error: ReceiptScanningError("Invalid receipt! Please scan again."))
            return
        }
    
        let transactionDateString: String = fields["TransactionDate"]?.valueDate ?? DateFormatter.localizedString(from: Date.now, dateStyle: .medium, timeStyle: .medium)
        
        print("INFO: Receipt validated. Now calculating expiration dates...")
        
        /*
         * Matching Items with respective expiration dates
         */
        
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        dateFormatter.dateFormat = "YYYY-MM-DD"
        dateFormatter.timeZone = TimeZone(abbreviation: "UTC-6")
        
        // Reminder date from API
        let dateOfPurchase: Date = dateFormatter.date(from: transactionDateString) ?? Date.now
        print("INFO: Transaction date: \(dateOfPurchase)")
        
        // Get expiration time interval
        let itemMatcher = ItemMatcher.matcher
        var scannedItems: [UserItem] = []
        
        for item in itemsArray {
            let name = item.valueObject["Name"]?.valueString ?? "Unknown"
            var dateToRemind: Date = dateOfPurchase
            
            // Find best match
            dateToRemind += itemMatcher.getEatByInterval(for: name)

            
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
        
        DispatchQueue.main.async {
            self.cvm.setItemsToConfirm(itemsToConfirm: scannedItems)
            self.showProgressDialog.toggle()
            self.showConfirmationView.toggle()
            self.alertTitle = "Read Me!"
            self.alertText = "Help EatThat! be more accurate by editing your purchase/expiration dates to the correct times and setting the category and the place of storage. Swipe right to edit and swipe left to remove unwanted items. \nThanks! 🥳🥑"
            self.showAlert.toggle()
            
        }
    }
    
    func addConfirmedUserItems(confirmedItems: [UserItem]) {
        print("INFO: \(confirmedItems.count) confirmed. Scheduling now")
        // Add to user's displayed list
        sivm.addScannedItems(userItems: confirmedItems) {
            results in
            // Schedule reminders for each added item
            EatByReminderManager.instance.bulkScheduleReminders(for: ScannedItemViewModel.shared.scannedItems)
            
            // Check for error saving items
            if let results = results {
                var errors: [(String, Error)] = []
                for (result, name) in results {
                    switch result {
                    case .failure(let error):
                        errors.append((name, error))
                    case .success:
                        break
                    }
                }
                if !errors.isEmpty {
                    DispatchQueue.main.async {
                        var errorMsg = "Could not save/schedule these items\n"
                        for (name, error) in errors {
                            errorMsg += "\t\(name): \(error.localizedDescription)"
                        }
                        self.error = EatByReminderError(errorMsg)
                    }
                }
            }
        }
        
        /*
         * SUCCESS!
         */
        DispatchQueue.main.async {
            self.alertTitle = "Scanning Result"
            self.alertText = "Successfully scanned!"
            self.showAlert.toggle()
        }
    }

    /*
     * Upload receipt image to Azure for analysis
     *  Upon upload via POST request,
     *  Must continuously send GET request for analyzed result as Azure model works
     *  Azure Endpoint docs: https://docs.microsoft.com/en-us/azure/applied-ai-services/form-recognizer/how-to-guides/try-sdk-rest-api?pivots=programming-language-rest-api#analyze-receipts
     * INPUT: UIImage optional, the scanned receipt
     */
    func analyzeImage(receipt: UIImage?) {
        DispatchQueue.main.async {
            self.showProgressDialog.toggle()
        }
        
        // Validate URL
        guard let postUrl = URL(string: "\(self.endpoint)formrecognizer/v2.1/prebuilt/receipt/analyze")
        else {
            handleError(error: ReceiptScanningError("Bad URL endpoint for Receipt Scanner!"))
            return
        }
        
        // Async pool
        var group: DispatchGroup? = DispatchGroup()
        
        /*
         * POST Request
         *  Uploading receipt
         *  Asynchronous
         *  TIMEOUT: 5s
         */
        let TIMEOUT: DispatchTime = .now() + 10  // 5s
        
        var workingLocation: String?
        var postError: Error? = ReceiptScanningError("POST request timeout")
        
        print("INFO: Image POST Request to Azure")
        group?.enter()
        self.azureHTTPManager.post(url: postUrl, image: receipt!, key: self.key) {
            [weak self] result in
            
            switch result {
            case .success(let data):
                print("INFO: Image POST success")
                workingLocation = String(decoding: data, as: UTF8.self)
                
                // POST finished successfully => no error
                postError = nil
                DispatchQueue.main.async {
                    // Update UI
                    self?.receipt = nil
                }
            case .failure(let error):
                print("DEBUG >>> POST error: \(error)")
                // POST finished unsuccessfully => set error
                postError = error
            }
            // POST completionHandler finished async
            group?.leave()
        }
        
        // Timeout Check
        DispatchQueue.main.asyncAfter(deadline: TIMEOUT) {
            // No GET after TIMEOUT seconds
            group = nil
            
            // If POST did not finish
            if let postError = postError {
                self.handleError(error: postError)
            }
        }
        
        /*
         * GET Request
         *  Retrieve receipt analysis.
         *  Asynchronous, triggers after POST Request
         *  TIMEOUT: 25 maximum requests
         *              5s each request
         */
        let MAX_TRIES = 50
        let REQ_INTERVAL: UInt32 = 1000000 // 1000000us = 1s
        let SUCCESS = "succeeded"

        var status: String = ""
        var count = 0
        group?.notify(queue: DispatchQueue.global()) {
        
            // POST returned error
            if let postError = postError {
                self.handleError(error: postError)
                return
            }

            // Must have valid analysis URL in Azure (redundant)
            guard
                let workingLocation = workingLocation
            else {
                self.handleError(error: ReceiptScanningError("No Azure working location found"))
                return
            }
            
            guard
                let url = URL(string: workingLocation)
            else {
                self.handleError(error: ReceiptScanningError("Invalid Azure working location"))
                return
            }
            
            // Loop GET requests, every second. 50 tries allowed
            while status != SUCCESS && count < MAX_TRIES {
                print("INFO: Attempting to get results... try \(count)")
                
                DispatchQueue.global().sync {
                    self.azureHTTPManager.get(url: url, key: self.key) {
                        [weak self] result in
                        
                        switch result {
                        case .success(let data):
                            let analyzedReceiptResponse = self?.decodeAnalyzedReceipt(data)
                            
                            // Bad JSON or Bad response
                            guard
                                let analyzedReceipt = analyzedReceiptResponse
                            else {
                                self?.handleError(error: ReceiptScanningError("Bad response from scanning API"))
                                return
                            }
                            
                            // Update status, exit if successful
                            status = analyzedReceipt.status
                            if status == SUCCESS {
                                print("INFO: Analysis succeeded")
                                print("\tAnalyzed receipt: \(analyzedReceipt)")
                                DispatchQueue.main.async {
                                    self?.scannedReceipt = analyzedReceipt
                                    self?.imageAnalyzedSuccesfully()
                                }
                                return
                            }
                        case .failure(let error):
                            DispatchQueue.main.async {
                                print("DEBUG >>> GET error: \(error.localizedDescription)")
                                self?.handleError(error: error)
                            }
                        }
                    }
                    count += 1
                }
                usleep(REQ_INTERVAL)
            }
        }
        if count >= MAX_TRIES {
            self.handleError(error: ReceiptScanningError("Request TIMEOUT"))
        }
    }
}

// MARK: JSON Functions

extension MainViewModel {
    /* Decode JSON Response. */
    private func decodeAnalyzedReceipt(_ jsonData: Data?) -> AnalyzedReceipt? {
        var analyzedReceiptObj: AnalyzedReceipt?
        do {
            if let jsonData = jsonData {
                analyzedReceiptObj = try JSONDecoder().decode(AnalyzedReceipt.self, from: jsonData)
            } else {
                print("Bad JSON, could not be read!")
            }
        } catch let error as NSError{
            print(error)
        }
        return analyzedReceiptObj
    }
    
    private func decodeAnalyzedReceiptDataToJSON(_ jsonData: Data?) -> Any {
        var jsonRes: Any?
        do {
            if let jsonData = jsonData {
                jsonRes = try JSONSerialization.jsonObject(with: jsonData, options: [])
            } else {
                print("Bad JSON!")
            }
        } catch let error as NSError {
            print(error)
        }
        return jsonRes!
    }
    /* Encode JSON Response. For logging/debugging purposes */
    private func encodeAnalyzedReceiptToString(_ analyzedReceipt: AnalyzedReceipt?) -> String? {
        var analyzedReceiptString: String?
        do {
            let encoder = JSONEncoder()
            encoder.outputFormatting = .prettyPrinted
            if let analyzedReceiptObj = analyzedReceipt {
                analyzedReceiptString = String(data: try encoder.encode(analyzedReceiptObj), encoding: .utf8)
            }
        } catch let error {
            print(error)
        }
        return analyzedReceiptString
    }
    
    private func encodeAnalyzedReceiptJSONToString(_ jsonData: Data?) -> String? {
        var analyzedReceiptString: String?
        
        if let jsonData = jsonData {
            analyzedReceiptString = String(data: jsonData, encoding: .utf8)
        } else {
            print("Invalid JSON Data!")
        }
        
        return analyzedReceiptString
    }
}
