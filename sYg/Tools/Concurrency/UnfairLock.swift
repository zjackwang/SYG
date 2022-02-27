//
//  UnfairLock.swift
//  sYg
//
//  Created by Jack Wang on 2/25/22.
//

import Foundation

/*
 * Src: https://stackoverflow.com/questions/59962747/osspinlock-was-deprecated-in-ios-10-0-use-os-unfair-lock-from-os-lock-h-i
 */

final class UnfairLock: NSLocking {
    private let unfairLock: UnsafeMutablePointer<os_unfair_lock> = {
        let pointer = UnsafeMutablePointer<os_unfair_lock>.allocate(capacity: 1)
        pointer.initialize(to: os_unfair_lock())
        return pointer
    }()

    deinit {
        unfairLock.deinitialize(count: 1)
        unfairLock.deallocate()
    }

    func lock() {
        os_unfair_lock_lock(unfairLock)
    }

    func tryLock() -> Bool {
        os_unfair_lock_trylock(unfairLock)
    }

    func unlock() {
        os_unfair_lock_unlock(unfairLock)
    }
}
