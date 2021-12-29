//
//  ReceiptViewModel.swift
//  sYg
//
//  Created by Jack Wang on 12/29/21.
//

import SwiftUI

/*
 * Encapsulates objs and actions required to get UIKit ImagePicker Functionality 
 */
class ReceiptViewModel: ObservableObject {
    @Published var receipt: UIImage?
    @Published var showSelector = false
    @Published var source: Selector.Source = .library
    @Published var showCameraAlert = false
    @Published var cameraError: Selector.CameraErrorType?
    
    func showReceiptSelector () {
        do {
            if source == .camera {
                try Selector.checkPermissions()
            }
            showSelector = true
        } catch {
            showCameraAlert = true
            cameraError = Selector.CameraErrorType(error: error as! Selector.SelectorError)
        }
    }
}
