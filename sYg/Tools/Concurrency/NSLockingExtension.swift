//
//  NSLockingExtension.swift
//  sYg
//
//  Created by Jack Wang on 2/25/22.
//

import Foundation

extension NSLocking {
    func synchronized<T>(block: () throws -> T) rethrows -> T {
        lock()
        defer { unlock() }
        return try block()
    }
}
