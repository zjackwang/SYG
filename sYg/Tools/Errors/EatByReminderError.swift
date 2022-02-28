//
//  EatByReminderErrors.swift
//  sYg
//
//  Created by Jack Wang on 2/22/22.
//

import Foundation

struct EatByReminderError: Error {
    let message: String
    
    init(_ message: String) {
        self.message = message
    }
    
    public var localizedDescription: String {
        return message
    }
}
