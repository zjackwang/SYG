//
//  Date - DateFormatExtension.swift
//  sYg
//
//  Created by Jack Wang on 2/22/22.
//

import Foundation

// https://stackoverflow.com/questions/35700281/date-format-in-swift
extension Date {
   func getFormattedDate(format: String) -> String {
        let dateformat = DateFormatter()
        dateformat.dateFormat = format
        return dateformat.string(from: self)
    }
}
