//
//  HTTPManager.swift
//  sYg
//
//  Created by Jack Wang on 1/3/22.
//

import Foundation
import UIKit

class AzureHTTPManager <T: URLSessionProtocol>: HTTPManager<T> {
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
                    // return operation location somehow, to be used by get... in completion block...
                    print("Azure form recognizer image POST request suceeded!\nWorking at \(operationLocation)")
                    completionBlock(.success(Data(operationLocation.utf8)))
                }
            case .failure(let error):
                completionBlock(.failure(error))
                return
            }
        }
    }
}
