//
//  HTTPManager.swift
//  sYg
//
//  Created by Jack Wang on 1/3/22.
//

import Foundation
import UIKit

/*
 * Azure analysis
 *  Upon upload receipt image via POST request,
 *  Must continuously send GET request for analyzed result as Azure model works
 *  Azure Endpoint docs: https://docs.microsoft.com/en-us/azure/applied-ai-services/form-recognizer/how-to-guides/try-sdk-rest-api?pivots=programming-language-rest-api#analyze-receipts
 */
class AzureHTTPManager <T: URLSessionProtocol>: HTTPManager<T> {
    // App must have this endpoint to work
    private let azureEndpoint: URL = URL(string: "https://\(Info.envVars?["Azure_Endpoint"] ?? "").cognitiveservices.azure.com/formrecognizer/v2.1/prebuilt/receipt/analyze")!
    private let azureKey: String = Info.envVars?["Azure_Key"] ?? ""

    
    /*
     * POST Request
     *  Uploading receipt
     *  Asynchronous
     *  TIMEOUT: whatever datatask timeout is
     */
    func postReceiptImage(receipt: UIImage) async throws -> String {
        let returnedData = try await self.postAsync(url: self.azureEndpoint, image: receipt, key: self.azureKey)
        return String(decoding: returnedData, as: UTF8.self)
    }

    /*
     * GET Request
     *  Retrieve receipt analysis.
     *  Asynchronous, triggers after POST Request
     *  TIMEOUT: 50 maximum requests
     *              0.5s between each request
     */
    
    func getAnalyzedReceipt(workingLocation: String) async throws -> AnalyzedReceipt{
        let MAX_TRIES = 50
        let REQ_INTERVAL = 0.5 // 500 ms
        let SUCCESS_STATUS = "succeeded"
        
        let workingLocationURL = try self.validateURL(urlString: workingLocation)
        
        var tries = 0
        var hasSucceeded = false
        
        while !hasSucceeded && tries < MAX_TRIES {
            let returnedReceipt = try await requestAnalyzedReceipt(from: workingLocationURL)
            
            // Exit if successful
            if returnedReceipt.status == SUCCESS_STATUS {
                print("INFO: Analysis succeeded")
                hasSucceeded.toggle()
                return returnedReceipt
            }
            
            tries += 1
            Thread.sleep(forTimeInterval: REQ_INTERVAL)
        }
        throw ReceiptScanningError("GET analyzed image request timed out.")
    }
    
    func requestAnalyzedReceipt(from workingLocationURL: URL) async throws -> AnalyzedReceipt{
        let returnedData = try await self.getAsync(url: workingLocationURL, key: self.azureKey)
        return try JSONDecoder().decode(AnalyzedReceipt.self, from: returnedData)
    }
    
    func get(url: URL, key: String, completionBlock: @escaping (Result<Data, Error>) -> Void) {
        
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "GET"
        urlRequest.setValue(key, forHTTPHeaderField: "Ocp-Apim-Subscription-Key")
        
        self.makeRequest(request: urlRequest) {
            result, response in
            completionBlock(result)
        }
    }
    
    func post(url: URL, image: UIImage, key: String, completionBlock: @escaping (Result<Data, Error>) -> Void) {
        
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "POST"
        urlRequest.setValue("image/jpeg", forHTTPHeaderField: "Content-Type")
        urlRequest.setValue(key, forHTTPHeaderField: "Ocp-Apim-Subscription-Key")
        urlRequest.httpBody = image.jpegData(compressionQuality: 1.0)
        
        self.makeRequest(request: urlRequest) {
            result, response in
            // get operation location
                switch(result) {
                case .success:
                    if let httpResponse = response as? HTTPURLResponse,
                       let operationLocation = httpResponse.value(forHTTPHeaderField: "operation-location")  {
                        print("HTTP: Azure form recognizer image POST request suceeded!\n\tWorking at \(operationLocation)")
                        completionBlock(.success(Data(operationLocation.utf8)))
                    }
                case .failure(let error):
                    completionBlock(.failure(error))
                    return
            }
        }
    }
    
    func getAsync(url: URL, key: String) async throws -> Data {
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "GET"
        urlRequest.setValue(key, forHTTPHeaderField: "Ocp-Apim-Subscription-Key")
        
        return try await withCheckedThrowingContinuation({ continuation in
            self.makeRequest(request: urlRequest) {
                result, response in
                switch(result) {
                case .success(let data):
                    continuation.resume(returning: data)
                case .failure(let error):
                    continuation.resume(throwing: error)
                }
            }
        })
    }
    
    func postAsync(url: URL, image: UIImage, key: String) async throws -> Data {
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "POST"
        urlRequest.setValue("image/jpeg", forHTTPHeaderField: "Content-Type")
        urlRequest.setValue(key, forHTTPHeaderField: "Ocp-Apim-Subscription-Key")
        urlRequest.httpBody = image.jpegData(compressionQuality: 1.0)
        
        return try await withCheckedThrowingContinuation { continuation in
            self.makeRequest(request: urlRequest) {
                result, response in
                switch(result) {
                case .success:
                    if let httpResponse = response as? HTTPURLResponse,
                       let operationLocation = httpResponse.value(forHTTPHeaderField: "operation-location")  {
                        print("INFO: Azure form recognizer image POST request suceeded!\n\tWorking at \(operationLocation)")
                        continuation.resume(returning: Data(operationLocation.utf8))
                    }
                case .failure(let error):
                    continuation.resume(throwing: error)
                }
            }
        }
    }
    
 
}
