//
//  GenericItemViewModel.swift
//  sYg
//
//  Created by Jack Wang on 4/19/22.
//

import Foundation

class GenericItemViewModel: ObservableObject {
    
    static let shared = GenericItemViewModel()
    
    // MARK: Initialization
    @Published var genericItems: [GenericItem] = []
    
    // Searching
    let searchPrompt: String = "Enter an item name here!"
    @Published var searchText: String = ""
}
