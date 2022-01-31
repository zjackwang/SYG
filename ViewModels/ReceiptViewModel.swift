//
//  ReceiptViewModel.swift
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
class ReceiptViewModel: ObservableObject {
    @Published var receipt: UIImage?
    @Published var showSelector = false
    @Published var source: Selector.Source = .library
    @Published var showCameraAlert = false
    @Published var cameraError: Selector.CameraErrorType?
    
    private let azureHTTPManager: AzureHTTPManager = AzureHTTPManager(session: URLSession.shared)
    private let endpoint: String = "https://\(ProcessInfo.processInfo.environment["Azure_Endpoint"]!).cognitiveservices.azure.com/"
    private let key: String = ProcessInfo.processInfo.environment["Azure_Key"]!
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
     * Upload receipt image to Azure for analysis
     * Upon upload via POST request,
     * Must continuously send GET request for analyzed result as Azure model works
     * Azure Endpoint docs: https://docs.microsoft.com/en-us/azure/applied-ai-services/form-recognizer/how-to-guides/try-sdk-rest-api?pivots=programming-language-rest-api#analyze-receipts
     */
    func analyzeImage(receipt: UIImage?) {
        guard let postUrl = URL(string: "\(self.endpoint)formrecognizer/v2.1/prebuilt/receipt/analyze")
        else {
            print("Invalid URL endpoint!")
            return
        }
        
        let group = DispatchGroup()
        group.enter()
        
        azureHTTPManager.post(url: postUrl, image: receipt!, key: self.key) {
            result in
            DispatchQueue.main.async {
                // Update UI
                // TODO prob don't need this in future views 
                self.workingLocation = String(decoding: try! result.get(), as: UTF8.self)
                self.receipt = nil
            }
            group.leave()
        }
        
        
        var status: String = ""
        var count = 0
        
        group.notify(queue: DispatchQueue.global()) {
            print("Waiting for working location to update")
            while self.workingLocation == nil {}
            while status != "succeeded" {
                print("Attempting to get results... try \(count)")
                DispatchQueue.global().sync {
                    self.azureHTTPManager.get(url: URL(string: self.workingLocation!)!, key: self.key) {
                        result in
                        do {
                            let data = try result.get()

                            // DEBUGGING
//                            print(self.decodeAnalyzedReceiptDataToJSON(data))
                            // DONE DEBUGGING
                            
                            let analyzedReceiptResponse = self.decodeAnalyzedReceipt(data)
                            
                            // Bad JSON or Bad response
                            guard let analyzedReceipt = analyzedReceiptResponse else {
                                return
                            }
                            
                            status = analyzedReceipt.status
                            if status == "succeded" {
                                print(analyzedReceipt)
                                DispatchQueue.main.async {
                                    self.scannedReceipt = analyzedReceipt
                                }
                            }
                        } catch let error as NSError{
                            print(error)
                        }
                    }
                    count += 1
                }
                usleep(1000000)
            }
        }
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
}
