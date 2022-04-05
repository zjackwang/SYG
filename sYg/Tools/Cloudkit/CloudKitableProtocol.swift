//
//  CloudKitableProtocol.swift
//  sYg
//
//  Created by Jack Wang on 3/29/22.
//

import Foundation
import CloudKit

protocol CloudKitableProtocol {
    var record: CKRecord { get }
    init?(record: CKRecord)
}
