//
//  UIApplicationExtension - EnvVar.swift
//  sYg
//
//  Created by Jack Wang on 3/5/22.
//

import Foundation
import UIKit

class Info {
    static var envVars: Dictionary<String, String>? {
        return Bundle.main.object(forInfoDictionaryKey: "LSEnvironment") as? Dictionary<String, String>
    }
}
