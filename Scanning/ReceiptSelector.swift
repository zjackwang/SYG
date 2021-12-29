//
//  ReceiptSelector.swift
//  sYg
//
//  Created by Jack Wang on 12/28/21.
//

import Foundation
import SwiftUI

/*
 * Actual UIKit interface for Camera, Photo Library
 */
struct ReceiptSelector: UIViewControllerRepresentable {
    
    @Binding var receipt: UIImage?
    var sourceType: UIImagePickerController.SourceType = .camera
    
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let selector = UIImagePickerController()
        selector.sourceType = sourceType
        selector.allowsEditing = true
        selector.delegate = context.coordinator
        
        
        return selector
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {
        
    }
    
    final class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
        
        let receiptSelector: ReceiptSelector
        
        init(receiptSelector: ReceiptSelector) {
            self.receiptSelector = receiptSelector
        }
        
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let image = info[.editedImage] as? UIImage {
                receiptSelector.receipt = image
            } else {
                print("ERROR")
            }
            picker.dismiss(animated: true)
        }
    }

    func makeCoordinator() -> ReceiptSelector.Coordinator {
        return Coordinator(receiptSelector: self)
    }
}
