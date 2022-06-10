//
//  HTTPManager.swift
//  sYg
//
//  Created by Jack Wang on 2/11/22.
//

import Foundation

class HTTPManager<T : URLSessionProtocol> {
    let session: T
    
    required init(session: T) {
        self.session = session
    }
    
    enum HTTPError: Error {
        case invalidURL
        case invalidParams
        case noInternet
        case invalidResponse(Data?, URLResponse?)
        case customResponse([String: String])
    }
    
    /*
     * Wrapper using simple url with preset cache policy and no headers etc. 
     */
    func makeRequest(with url: URL, completionBlock: @escaping (Result<Data, Error>, URLResponse?) -> Void) {
        // Try to use cache w/ 60 s timeout
        let request = URLRequest(url: url, cachePolicy: .reloadRevalidatingCacheData, timeoutInterval: 60)
        
        self.makeRequest(request: request, completionBlock: completionBlock)
    }
    
    /*
     * INPUT: URLRequest for the desired api
     * OUTPUT: Result, either successful with a list of the produce items
     *          or a failure with corresponding error code in the completionBlock
     */
    func makeRequest(request: URLRequest, completionBlock: @escaping (Result<Data, Error>, URLResponse?) -> Void) {
        let task = self.session.dataTask(with: request) {
            data, response, error in
            
            // HTTP Error Handling
            if let error = error {
                completionBlock(.failure(error), response)
                return
            }
            
            guard
                let _ = data,
                let httpResponse = response as? HTTPURLResponse,
                200 ..< 300 ~= httpResponse.statusCode
            else {
                if let data = data {
                    completionBlock(.success(data), response)
                } else {
                    completionBlock(.failure(HTTPError.invalidResponse(data, response)), response)
                }
                return
            }
            
            // Passes guards
            if let data = data {
                completionBlock(.success(data), httpResponse)
            }
        }
        
        task.resume()
    }
    
}
