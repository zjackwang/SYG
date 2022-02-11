//
//  ItemsHTTPManager.swift
//  sYg
//
//  Created by Jack Wang on 2/1/22.
//

import Foundation
import SwiftUI


class ItemsHTTPManager <T: URLSessionProtocol>: HTTPManager<T> {
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
        
        self.makeRequest(with: url) {
            result, response in
            
            var items: [ProduceItem] = []
            switch result {
            case .success(let data):
                do {
                    items = try JSONDecoder().decode([ProduceItem].self, from: data)
                } catch let DecodingError.typeMismatch(_, context) {
                    // Requesting just one item 
                    print(context.debugDescription)
                    items.append(try! JSONDecoder().decode(ProduceItem.self, from: data))
                } catch {
                    completionBlock(.failure(error))
                }
            case .failure(let error):
                completionBlock(.failure(error))
            }
            completionBlock(.success(items))
        }
        
    }
}
