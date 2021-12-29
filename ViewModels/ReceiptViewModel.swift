//
//  ReceiptViewModel.swift
//  sYg
//
//  Created by Jack Wang on 12/29/21.
//

import SwiftUI

class ReceiptViewModel: ObservableObject {
    @Published var receipt: UIImage?
    @Published var showSelector = false
    @Published var source: Selector.Source = .library
    
    func showReceiptSelector () {
        if source == .camera {
            if !Selector.checkPermissions() {
                print("There is no camera on this device!")
                return
            }
        }
        showSelector = true 
    }
}
