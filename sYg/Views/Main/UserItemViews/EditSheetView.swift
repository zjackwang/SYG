//
//  EditSheetView.swift
//  sYg
//
//  Created by Jack Wang on 3/9/22.
//

import SwiftUI

struct EditSheetView: View {
    @Binding var show: Bool
    @Binding var editScannedItem: EditScannedItem
    @Binding var showAlert: Bool

    @StateObject private var sivm = ScannedItemViewModel.shared
    @Binding var alertText: String 
    
    var body: some View {
        ZStack {
            Form {
                Text("Edit Item Info")
                    .font(.title)
                TextField("Enter new item name", text: $editScannedItem.nameText)
                
                DatePicker("Purchase date", selection: $editScannedItem.purchaseDate, displayedComponents: [.date, .hourAndMinute])
                
                DatePicker("Remind date", selection: $editScannedItem.remindDate, displayedComponents: [.date, .hourAndMinute])
                Button {
                    show.toggle()
                    showAlert.toggle()
                    print("Showing \(show)")
                    print("Alert \(showAlert)")
                } label: {
                    Text("Cancel")
                }
                Button {
                    // save form
                    show.toggle()
                    showAlert.toggle()
//                        saveEditedItem()
                } label: {
                    Text("Save")
                }
                
            }
            
        }
        
        .opacity(show ? 1.0 : 0.0)
    }
}

extension EditSheetView {
    func saveEditedItem() {
        if editScannedItem.nameText.count < 3 {
            showAlert.toggle()
            alertText = "Name should have at least 3 characters!"
        }
        
        if sivm.updateScannedItem(oldName: editScannedItem.oldItem?.name ?? "Unknown", name: editScannedItem.nameText, purchaseDate: editScannedItem.purchaseDate, remindDate: editScannedItem.remindDate) {
            showAlert.toggle()
            alertText = "Update successful!"
        } else {
            showAlert.toggle()
            alertText = "Update unsuccessful."
        }
    }
}

struct EditScannedItem {
    var nameText: String
    var purchaseDate: Date
    var remindDate: Date

    var oldItem: ScannedItem?
}

//struct EditSheetView_Previews: PreviewProvider {
//    static var previews: some View {
//        EditSheetView()
//    }
//}
