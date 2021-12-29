//
//  ProduceViewModel.swift
//  sYg
//
//  Created by Jack Wang on 12/28/21.
//

import Foundation
import SwiftUI

class ProduceViewModel: ObservableObject {
    @Published var items: [ProduceItem] = []
    
    func fetchProduce() {
        guard let url = URL(string: "https://saveyourgroceries-api.herokuapp.com/produce") else {
            return
        }
        
        let task = URLSession.shared.dataTask(with: url) { [weak self]
            data, _, error in
            guard let data = data, error == nil else {
                return
            }
            // Convert to JSON
            do {
                let items = try JSONDecoder().decode([ProduceItem].self, from: data)
                DispatchQueue.main.async {
                    self?.items = items
                }
            }
            catch {
                print(error)
            }
        }
        
        task.resume()
    }
}
