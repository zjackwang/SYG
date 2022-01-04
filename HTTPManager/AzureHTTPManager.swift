//
//  HTTPManager.swift
//  sYg
//
//  Created by Jack Wang on 1/3/22.
//

import Foundation
import UIKit

class AzureHTTPManager <T: URLSessionProtocol>{
    var session: T
    
    required init(session: T) {
        self.session = session
    }
    
    func makeRequest(request: URLRequest, completionBlock: @escaping (Result<Data, Error>, URLResponse?) -> Void) {
        
        let task = session.dataTask(with: request) {
            data, response, error in
            
            if let error = error {
                completionBlock(.failure(error), response)
                return
            }
            
            guard
                let _ = data,
                let httpReponse = response as? HTTPURLResponse,
                200 ..< 300 ~= httpReponse.statusCode
            else {
                // Hm, what happens if status code not in range?
                if let data = data {
                    completionBlock(.success(data), response)
                } else {
                    completionBlock(.failure(HTTPError.invalidResponse(data, response)), response)
                }
                return
            }
            
            // Passes guard
            // have to cast back to httpResponse 
            if let data = data {
                completionBlock(.success(data), httpReponse)
            }
        }
        task.resume()
    }
    
    func get(url: URL, key: String, completionBlock: @escaping (Result<Data, Error>) -> Void) {
        
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "GET"
        urlRequest.setValue(key, forHTTPHeaderField: "Ocp-Apim-Subscription-Key")
        
        makeRequest(request: urlRequest) {
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
        
        makeRequest(request: urlRequest) {
            result, response in
            // get operation location
            guard
                let httpResponse = response as? HTTPURLResponse,
                let operationLocation = httpResponse.value(forHTTPHeaderField: "operation-location")
            else {
                completionBlock(.failure(HTTPError.invalidResponse(try! result.get(), response)))
                return
            }
            
            // return operation location somehow, to be used by get... in completion block... 
            print("Azure form recognizer image POST request suceeded!\nWorking at \(operationLocation)")
            completionBlock(.success(Data(operationLocation.utf8)))
        
        }
        
    }
}
