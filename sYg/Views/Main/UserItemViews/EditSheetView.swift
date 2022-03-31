//
//  EditSheetView.swift
//  sYg
//
//  Created by Jack Wang on 3/9/22.
//

import SwiftUI
import Combine

/*
 * Overlayed sheet shown
 *
 * Sheet
 *  - Name
 *  - Pur date
 *  - Remind date
 *  - Confirm
 *
 *  Alert?
 *  - show x mark / check instead
 *
 */

struct EditSheetView: View {
    @Binding var show: Bool
    @Binding var id: String

    @StateObject private var vm = EditViewModel.shared
    
    var body: some View {
        ZStack {
            Form {
                Text("Edit Item Info")
                    .font(.title)
                
                nameField
                categoryPicker
                
                purDatePicker
                remindDatePicker
                
                Button {
                    show.toggle()
                } label: {
                    Text("Cancel")
                }
                Button {
                    // save form
                    show.toggle()
                    vm.updateUserItem(for: id)
                } label: {
                    Text("Save")
                }
                .opacity(vm.showConfirmButton ? 1.0 : 0.25)
            }
        }
        .opacity(show ? 1.0 : 0.0)
    }
}

extension EditSheetView {
    private var nameField: some View {
        TextField("Enter new item name", text: $vm.nameText)
            .overlay(
                ZStack {
                    Image(systemName: "xmark")
                        .foregroundColor(.red)
                        .opacity(
                            vm.nameText.count < 1 ? 0.0 :
                            vm.nameTextIsValid ? 0.0 : 1.0)
                    
                    Image(systemName: "checkmark")
                        .foregroundColor(.green)
                        .opacity(vm.nameTextIsValid ? 1.0: 0.0)
                }
                .font(.headline)
                .padding(.trailing)
                , alignment: .trailing
            )
    }
    
    private var categoryPicker: some View {
        Picker("Category", selection: $vm.category) {
            Text("Produce").tag(Category.produce)
            Text("Meats, Poultry, Seafood").tag(Category.meatPoultrySeafood)
            Text("Dairy").tag(Category.dairy)
            Text("Drinks").tag(Category.drinks)
            Text("Condiments").tag(Category.condiments)
        }
        .pickerStyle(.segmented)
    }
    
    private var purDatePicker: some View {
        DatePicker("Purchase date", selection: $vm.purchaseDate, displayedComponents: [.date, .hourAndMinute])
    }
    
    private var remindDatePicker: some View {
        DatePicker("Remind date", selection: $vm.remindDate, displayedComponents: [.date, .hourAndMinute])
    }
}
