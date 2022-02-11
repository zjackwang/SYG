//
//  Settings.swift
//  sYg
//
//  Created by Jack Wang on 1/25/22.
//

import Foundation

struct Settings {
    let redClockInterval: TimeInterval
    let yellowClockInterval: TimeInterval
}

extension Settings {
    static let DefaultSettings =
        Settings (
            redClockInterval: TimeInterval(2 * 24 * 60 * 60),
            yellowClockInterval: TimeInterval(4 * 24 * 60 * 60)
        )
}
