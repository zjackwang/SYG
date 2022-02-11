//
//  Selector.swift
//  sYg
//
//  Created by Jack Wang on 12/29/21.
//

import Foundation
import SwiftUI
import AVFoundation

enum Selector {
    enum Source {
        case library, camera
    }
    
//    Error wrapper for cases returned from UIImagePickerControoler.isSourceTypeAvailable(.camera)
    enum SelectorError: Error, LocalizedError {
        case unavailable
        case restricted
        case denied
        
        var errorDescription: String? {
            switch self {
            case .unavailable:
                return NSLocalizedString("There is no camera on this device.", comment: "")
            case .restricted:
                return NSLocalizedString("You are not allowed to access media captured devices.", comment: "")
            case .denied:
                return NSLocalizedString("You have explicitly denied permissions for media capture. Please open permissions/Privacy/Camera and grant access for this application.", comment: "")
            }
        
        }
    }
    
//    Called when camera access requested 
    static func checkPermissions() throws {
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            let authStatus = AVCaptureDevice.authorizationStatus(for: AVMediaType.video)
            switch authStatus {
            case .restricted:
                throw SelectorError.restricted
            case .denied:
                throw SelectorError.denied
            default:
                break
            }
        } else {
            throw SelectorError.unavailable
        }
    }
    
//    Container for error alert objs
    struct CameraErrorType {
        let error: Selector.SelectorError
        var message: String {
            error.localizedDescription
        }
        let button = Button("OK", role: .cancel) {}
    }
}
