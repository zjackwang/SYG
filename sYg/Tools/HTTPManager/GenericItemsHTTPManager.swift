//
//  GenericItemsHTTPManager.swift
//  sYg
//
//  Created by Jack Wang on 6/7/22.
//

import Foundation
import CryptoKit

class GenericItemsHTTPManager <T: URLSessionProtocol>: HTTPManager<T> {
    let genericItemURLString = "https://api-syg.herokuapp.com/genericitem/"
    let genericItemSetURLString = "https://api-syg.herokuapp.com/genericitemset"
    let genericItemListURLString = "https://api-syg.herokuapp.com/genericitemlist"
    
    private let secretKey: String = Info.envVars?["Public_Api_Secret_Key"] ?? ""
    private let publicKey: String = Info.envVars?["Public_Api_Key"] ?? ""
    
    
    func fetchAllGenericItemsAsync() async throws -> [GenericItem] {
        return try await withCheckedThrowingContinuation({ continuation in
            fetchAllGenericItems { result in
                switch result {
                case .success(let items):
                    continuation.resume(returning: items)
                case .failure(let error):
                    continuation.resume(throwing: error)
                }
            }
        })
    }
    
    func fetchGenericItemAsync(for name: String, formParms: [String: String]?) async throws -> [GenericItem] {
        return try await withCheckedThrowingContinuation({ continuation in
            fetchGenericItem(for: name, formParams: formParms) { result in
                switch result {
                case .success(let items):
                    continuation.resume(returning: items)
                case .failure(let error):
                    continuation.resume(throwing: error)
                }
            }
        })
    }
    
    func fetchGenericItemNamesAsync() async throws -> [String] {
        return try await withCheckedThrowingContinuation({ continuation in
            fetchGenericItemNames { result in
                switch result {
                case .success(let names):
                    continuation.resume(returning: names)
                case .failure(let error):
                    continuation.resume(throwing: error)
                }
            }
        })
    }
}


// MARK: Request Functions
extension GenericItemsHTTPManager {
    // TODO: Why is there a double callback?
    func fetchAllGenericItems(completionBlock: @escaping (Result<[GenericItem], Error>) -> Void) {
        // validate url
        guard let url = URL(string: genericItemSetURLString) else {
            completionBlock(.failure(HTTPError.invalidURL))
            return
        }
                
        // request
        var urlRequest = URLRequest(url: url)
        
        // request headers
        urlRequest.addValue(publicKey, forHTTPHeaderField: "X-Syg-Api-Key")
        let (hmacSigString, message) = Crypto.generateHMAC(keyString: secretKey)
        urlRequest.addValue(hmacSigString, forHTTPHeaderField: "X-Hmac-Signature")
        urlRequest.addValue(message, forHTTPHeaderField: "X-Hmac-Message")
        urlRequest.httpMethod = "GET"
        
        // make keyed request with form params
        makeRequest(request: urlRequest) {
            result, response in
            
            var items: [GenericItem] = []
            switch(result) {
            case .failure(let error):
                completionBlock(.failure(error))
            case .success(let data):
                // Decode into generic items TODO:
                do {
                    print(data)
                    items = try JSONDecoder().decode([GenericItem].self, from: data)
                } catch (let error) {
                    completionBlock(.failure(error))
                }
                
                completionBlock(.success(items))
            }
            return
        }
    }
    
    /*
     * INPUT: name: String name of the item
     *        key: Secret key to access api
     *        formParms: Dict<String: Any>? optional table of parameters to narrow down fetch request
     * OUTPUT: List of GenericItem structs, via the completion block
     */
    func fetchGenericItem(for name: String, formParams: [String: String]?, completionBlock: @escaping (Result<[GenericItem], Error>) -> Void) {
        let urlString: String = genericItemURLString + name

        // validate url
        guard let url = URL(string: urlString) else {
            completionBlock(.failure(HTTPError.invalidURL))
            return
        }
        
        // get payload
        var payload = ""
        if let formParams = formParams {
            for (key, value) in formParams {
                payload += (key + "=" + value + " ")
            }
        }
        
        // request
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "POST"
        // request headers
        urlRequest.addValue(publicKey, forHTTPHeaderField: "X-Syg-Api-Key")
        let (hmacSigString, message) = Crypto.generateHMAC(keyString: secretKey)
        urlRequest.addValue(hmacSigString, forHTTPHeaderField: "X-HMAC-Signature")
        urlRequest.addValue(message, forHTTPHeaderField: "X-Hmac-Message")

        // make keyed request with form params
        makeRequest(request: urlRequest) {
            result, response in
            
            var items: [GenericItem] = []
            switch(result) {
            case .failure(let error):
                completionBlock(.failure(error))
            case .success(let data):
                // Decode into generic items TODO:
                do {
                    print(data)
                    items = try JSONDecoder().decode([GenericItem].self, from: data)
                } catch DecodingError.typeMismatch(_, _) {
                    // Error message
                    let errorResponse = try! JSONDecoder().decode([String: String].self, from: data)
                    print(errorResponse)
                } catch (let error) {
                    completionBlock(.failure(error))
                }
                
                completionBlock(.success(items))
            }
            return
        }
    }
    
    /*
     * OUTPUT: List of Strings, via the completion block
     */
    func fetchGenericItemNames(completionBlock: @escaping (Result<[String], Error>) -> Void) {
        let urlString: String = genericItemListURLString

        // validate url
        guard let url = URL(string: urlString) else {
            completionBlock(.failure(HTTPError.invalidURL))
            return
        }
        
        // request
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "GET"
        // request headers
        urlRequest.addValue(publicKey, forHTTPHeaderField: "X-Syg-Api-Key")
        let (hmacSigString, message) = Crypto.generateHMAC(keyString: secretKey)
        urlRequest.addValue(hmacSigString, forHTTPHeaderField: "X-HMAC-Signature")
        urlRequest.addValue(message, forHTTPHeaderField: "X-Hmac-Message")

        // make keyed request with form params
        makeRequest(request: urlRequest) {
            result, response in
            
            var items: [String] = []
            switch(result) {
            case .failure(let error):
                completionBlock(.failure(error))
            case .success(let data):
                // Decode into generic items TODO:
                do {
                    items = try JSONDecoder().decode([String].self, from: data)
                } catch DecodingError.typeMismatch(_, _) {
                    // Error message
                    let errorResponse = try! JSONDecoder().decode([String: String].self, from: data)
                    print(errorResponse)
                    completionBlock(.failure(HTTPError.customResponse(errorResponse)))
                } catch (let error) {
                    completionBlock(.failure(error))
                }
                
                completionBlock(.success(items))
            }
            return
        }
    }
}
