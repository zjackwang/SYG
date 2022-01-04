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
    @Published var scannedItemsDictionary: [String: Any]?
    
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
    func analyzeImage(receipt: UIImage?){
        
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
                            let jsonRes = try JSONSerialization.jsonObject(with: try result.get(), options: [])
                            print("The response is \n \(jsonRes)")
                            
                            if let dictionary = jsonRes as? [String: Any] {
                                if let s = dictionary["status"] as? String, s == "succeeded" {
                                    status = s
                                    // Update UI
                                    DispatchQueue.main.async {
                                        self.scannedItemsDictionary = dictionary
                                    }
                                }
                            }
                        } catch {
                            print(error)
                        }
                    }
                    count += 1
                }
                usleep(500000)
            }
        }
    }
}
