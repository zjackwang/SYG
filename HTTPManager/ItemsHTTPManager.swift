//
//  ItemsHTTPManager.swift
//  sYg
//
//  Created by Jack Wang on 2/1/22.
//

import Foundation
import SwiftUI


class ItemsHTTPManager <T: URLSessionProtocol> {
    var session: T
    
    required init(session: T) {
        self.session = session
    }
    /*
     * INPUT: name: String name of the item (optional)
     *        isCut: Boolean, whether the item is cut or not (optional)
     * OUTPUT: List of ProduceItem structs, via the completion block
     */
    func fetchProduceItem(for name: String?, isCut: Bool = false, completionBlock: @escaping (Result<[ProduceItem], Error>) -> Void) {
        var urlString: String = "https://saveyourgroceries-api.herokuapp.com/produce"
        if let name = name {
            // API parameters
            let capitalizedName = name.lowercased().capitalized
            let capitalizedBool = String(isCut).capitalized
            urlString += "?item_name=\(capitalizedName)&is_cut=\(capitalizedBool)"
        }
        
        // validate URL
        guard let url = URL(string: urlString) else {
            completionBlock(.failure(HTTPError.invalidURL))
            return
        }
        
        fetchProduce(with: url) {
            result, response in
            
            var items: [ProduceItem] = []
            do {
                items = try JSONDecoder().decode([ProduceItem].self, from: result.get())
            } catch let DecodingError.typeMismatch(_, context) {
                // description 
                print(context.debugDescription)
                items.append(try! JSONDecoder().decode(ProduceItem.self, from: result.get()))
            } catch {
                completionBlock(.failure(error))
            }
            completionBlock(.success(items))
        }
        
    }
    
    
    /*
     * INPUT: URLRequest for the desired api
     * OUTPUT: Result, either successful with a list of the produce items
     *          or a failure with corresponding error code in the completionBlock
     */
    private func fetchProduce(with url: URL, completionBlock: @escaping (Result<Data, Error>, URLResponse?) -> Void) {
        
        // Do I need URLRequest?
        let task = self.session.dataTask(with: url) {
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
