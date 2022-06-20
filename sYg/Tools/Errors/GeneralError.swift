//
//  GeneralError.swift
//  sYg
//
//  Created by Jack Wang on 6/19/22.
//

import Foundation

struct GeneralError: Error {
    let message: String
    
    init(_ message: String) {
        self.message = message
    }
    
    public var localizedDescription: String {
        return message
    }
}
