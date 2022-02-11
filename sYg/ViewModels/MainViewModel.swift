//
//  MainViewModel.swift
//  sYg
//
//  Created by Jack Wang on 12/29/21.
//

import SwiftUI
import UIKit

/*
 * Encapsulates objs and actions required to get UIKit ImagePicker Functionality
 * Once image is confirmed, sends to Azure for analysis and returns results 
 */
class MainViewModel: ObservableObject {
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
    private let endpoint: String = "https://\(ProcessInfo.processInfo.environment["Azure_Endpoint"]!).cognitiveservices.azure.com/"
    private let key: String = ProcessInfo.processInfo.environment["Azure_Key"]!
    
    // Returned from Azure
    @Published var workingLocation: String?
    @Published var scannedReceipt: AnalyzedReceipt?
    
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
            showCameraAlert = true
            cameraError = Selector.CameraErrorType(error: error as! Selector.SelectorError)
        }
    }
    
    /*
     * Callback for the analyzeImage function, upon success
     *  - converts AnalyzedReceipt struct into list of UserItem structs
     *  - adds to user defaults via scanned items view model
     */
    func imageAnalyzedSuccesfully(pvm: ProduceViewModel, svm: ScannedItemsViewModel) {
        print("Image analyzed successfully. Now adding to user defaults...")
        // Should have legit receipt
        guard let scannedReceipt = scannedReceipt else {
            print("NO SCANNED RECEIPT")
            return
        }
    
        let results: [DocumentResult]? = scannedReceipt.analyzeResult?.documentResults
        let fields: [String: Field]? = results?[0].fields
//            let merchantNameString: String? = fields?["MerchantName"]?.valueString
        let transactionDateString: String = fields?["TransactionDate"]?.valueDate ?? DateFormatter.localizedString(from: Date.now, dateStyle: .medium, timeStyle: .medium)
        let itemsArray: [AnalyzedItem]? = fields?["Items"]?.valueArray
        
        guard let itemsArray = itemsArray else {
            print("NO ITEMSARRAY")
            return
        }  
        
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        dateFormatter.dateFormat = "YYYY-MM-DD"
        dateFormatter.timeZone = TimeZone(abbreviation: "UTC-6")
        // Reminder date from API
        let dateOfPurchase: Date = dateFormatter.date(from: transactionDateString) ?? Date.now
        print("transaction date: \(dateOfPurchase)")
      
        // Get expiration time interval
        let itemMatcher = ItemMatcher.factory

        var scannedItems: [UserItem] = []
        for item in itemsArray {
            let name: String? = item.valueObject["Name"]?.valueString
            
            guard let name = name else {
                // TODO when no name... won't happen idt 
                self.handleError(error: nil)
                return
            }
           
            var dateToRemind: Date = dateOfPurchase
            let produceInfo: ProduceItem? = pvm.getProduceInfo(for: name)
            if let produceInfo = produceInfo {
                // perfect match
                dateToRemind += produceInfo.DaysInFridge * 24 * 60 * 60
            } else {
                // find best match
                dateToRemind += itemMatcher.getExpirationTimeInterval(for: name, using: pvm)
            }
            // DEBUGGING
            print("name: \(name)")
            print("- date to remind: \(dateToRemind)")
            
            scannedItems.append(
                UserItem(
                    Name: name,
                    DateOfPurchase: dateOfPurchase,
                    DateToRemind: dateToRemind
                )
            )
        }
        // Add to user's displayed list
        DispatchQueue.main.async {
            svm.addItems(scannedItems)
        }
    }
    
    /*
     * Callback for the analyzeImage function, upon error
     *  - popover in mainuser view
     * INPUT: error
     */
    func imageAnalysisError() {
        
    }
    
    /*
     * Upload receipt image to Azure for analysis
     * Upon upload via POST request,
     * Must continuously send GET request for analyzed result as Azure model works
     * Azure Endpoint docs: https://docs.microsoft.com/en-us/azure/applied-ai-services/form-recognizer/how-to-guides/try-sdk-rest-api?pivots=programming-language-rest-api#analyze-receipts
     * INPUT: UIImage optional, the scanned receipt
     * OUTPUT: Boolean, whether the subroutine validated the URL
     */
    func analyzeImage(receipt: UIImage?, pvm: ProduceViewModel, svm: ScannedItemsViewModel) -> Bool {
        // Validate URL
        guard let postUrl = URL(string: "\(self.endpoint)formrecognizer/v2.1/prebuilt/receipt/analyze")
        else {
            print("Invalid URL endpoint!")
            return false
        }
        
        // Async pool
        let group = DispatchGroup()
        group.enter()
        
        // Upload Receipt via POST
        azureHTTPManager.post(url: postUrl, image: receipt!, key: self.key) {  [weak self]
            result in
            
            switch result {
            case .success(let data):
                DispatchQueue.main.async {
                    // Update UI
                    // TODO prob don't need this in future views (TESTING)
                    self?.workingLocation = String(decoding: data, as: UTF8.self)
                    self?.receipt = nil
                }
                break
            case .failure(let error):
                self?.handleError(error: error)
                break
            }
            group.leave()
        }
        
        // GET Request for analyzed receipt
        var status: String = ""
        var count = 0
        group.notify(queue: DispatchQueue.global()) {
            print("Waiting for working location to update")
            while self.workingLocation == nil {}
            // Loop GET requests, every second. 100 tries allowed
            while status != "succeeded" && count < 100 {
                print("Attempting to get results... try \(count)")
                DispatchQueue.global().sync {
                    self.azureHTTPManager.get(url: URL(string: self.workingLocation!)!, key: self.key) {
                        [weak self]
                        result in
                        switch result {
                        case .success(let data):
                            // DEBUGGING
//                            print(self?.decodeAnalyzedReceiptDataToJSON(data))
                            // DONE DEBUGGING
                            
                            let analyzedReceiptResponse = self?.decodeAnalyzedReceipt(data)
                            
                            // Bad JSON or Bad response
                            guard let analyzedReceipt = analyzedReceiptResponse else {
                                return
                            }
                            
                            // Update status, exit if successful
                            status = analyzedReceipt.status
                            if status == "succeeded" {
                                print("Succeeded")
//                                print(analyzedReceipt)
                                DispatchQueue.main.async {
                                    self?.scannedReceipt = analyzedReceipt
                                    self?.imageAnalyzedSuccesfully(pvm: pvm, svm: svm)
                                }
                                return
                            }
                            break
                        case .failure(let error):
                            self?.handleError(error: error)
                            break
                        }
                        
                    }
                    count += 1
                }
                usleep(1000000)
            }
        }
        
        return true
    }
    
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
    
    /*
     * What happens when API Request returns failure?
     */
    private func handleError(error: Error?) {
//        print(error) // TODO
    }
}
