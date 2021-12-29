//
//  Selector.swift
//  sYg
//
//  Created by Jack Wang on 12/29/21.
//

import Foundation
import UIKit

enum Selector {
    enum Source {
        case library, camera
    }
    
    static func checkPermissions() -> Bool {
        return UIImagePickerController.isSourceTypeAvailable(.camera)
    }
}
