//
//  UserSuggestionHTTPManager.swift
//  sYg
//
//  Created by Jack Wang on 6/11/22.
//

import Foundation

class UserSuggestionHTTPManager <T: URLSessionProtocol>: HTTPManager<T>  {
    
    private let userSubmittedGenericItemURLString = "https://syg-user-submitted.herokuapp.com/usersubmittedgenericitemset"
    private let userSubmittedMatchedItemURLString = "https://syg-user-submitted.herokuapp.com/usersubmittedmatcheditemset"
    private let userSubmittedGenericItemUpdateURLString = "https://syg-user-submitted.herokuapp.com/userupdatedgenericitemset"
    
    private let secretKey: String = Info.envVars?["Private_Api_Secret_Key"] ?? ""
    
    
    func submitSuggestGenericItemAsync(genericItem: GenericItem) async throws {
        let jsonData = try JSONEncoder().encode(genericItem)
        
        guard let url = URL(string: userSubmittedGenericItemURLString) else {
            throw HTTPError.invalidURL
        }
        
        try await postAsync(url: url, jsonData: jsonData)
    }
    
    func submitSuggestedMatchedItemAsync(matchedItem: MatchedItem) async throws{
        let jsonData = try JSONEncoder().encode(matchedItem)
        
        guard let url = URL(string: userSubmittedMatchedItemURLString) else {
            throw HTTPError.invalidURL
        }
        
        try await postAsync(url: url, jsonData: jsonData)
    }
    
    func submitSuggestedGenericItemUpdateAsync(updatedGenericItem: UserUpdatedGenericItem) async throws {
        let jsonData = try JSONEncoder().encode(updatedGenericItem)
        
        guard let url = URL(string: userSubmittedGenericItemUpdateURLString) else {
            throw HTTPError.invalidURL
        }
        
        try await postAsync(url: url, jsonData: jsonData)
    }
    
    /*
     * Send POST request to given url with json payload
     */
    private func postAsync(url: URL, jsonData: Data) async throws {
        // Create URLRequest
        var urlRequest = URLRequest(url: url)
        let (hmacSig, message) = Crypto.generateHMAC(keyString: secretKey)
        urlRequest.addValue(hmacSig, forHTTPHeaderField: "X-Hmac-Signature")
        urlRequest.addValue(message, forHTTPHeaderField: "X-Hmac-Message")
        urlRequest.addValue("true", forHTTPHeaderField: "X-Is-Test-Request")
        urlRequest.addValue("application/JSON", forHTTPHeaderField: "Content-Type")
        urlRequest.httpBody = jsonData
        urlRequest.httpMethod = "POST"
        
        // Submit post request
        return try await withCheckedThrowingContinuation({ continuation in
            makeRequest(request: urlRequest) { result, response in
                switch result {
                case .failure(let error):
                    continuation.resume(throwing: error)
                case .success(let data):
                    do {
                        if let httpResponse = response as? HTTPURLResponse,
                           httpResponse.statusCode == 200 {
                            continuation.resume()
                            return
                        }
                        let message = try JSONDecoder().decode([String: String].self, from: data)
                        print(message)
                        throw HTTPError.customResponse(message)
                    } catch (let error){
                        continuation.resume(throwing: error)
                    }
                    
                }
            }
        })
    }
}

