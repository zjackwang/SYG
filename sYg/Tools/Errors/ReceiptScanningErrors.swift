//
//  ReceiptScanningErrors.swift
//  sYg
//
//  Created by Jack Wang on 2/17/22.
//

import Foundation

struct ReceiptScanningError: Error {
    let message: String
    
    init(_ message: String) {
        self.message = message
    }
    
    public var localizedDescription: String {
        return message 
    }
}
