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

    @StateObject private var vm = EditViewModel.shared
    
    @State var cancellables = Set<AnyCancellable>()
    
    var body: some View {
        ZStack {
            Form {
                Text(vm.title)
                    .font(.title)
                
                nameField
                categoryPicker
                storagePicker
                purDatePicker
                remindDatePicker
                
                Button {
                    show.toggle()
                } label: {
                    Text("Cancel")
                }
                Button {
                    // save form
                    vm.confirmed = true 
                    show.toggle()
                } label: {
                    Text("Save")
                }
                .opacity(vm.showConfirmButton ? 1.0 : 0.25)
            }
        }
        .opacity(show ? 1.0 : 0.0)
    }
}

// MARK: COMPONENTS 
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
    
    // TODO: STILL NOT UPDATING UPON EVERY APPEAR
    private var categoryPicker: some View {
        return Picker("Category", selection: $vm.categorySelection) {
            Text("Produce").tag("Produce")
            Text("Dairy").tag("Dairy")
            Text("Meat, Poultry, Seafood").tag("Meat, Poultry, Seafood")
            Text("Condiments").tag("Condiments")
            Text("Drinks").tag("Drinks")
            Text("Cooked").tag("Cooked")
        }
        .onAppear(perform: {
            vm.$category
                .sink { category in
                    vm.categorySelection = CategoryConverter.rawValue(given: category)
                }
                .store(in: &cancellables)
        })
        .pickerStyle(.segmented)
    }
    
    private var storagePicker: some View {
        Picker("Storage", selection: $vm.storageSelection) {
            Text("Fridge").tag("Fridge")
            Text("Freezer").tag("Freezer")
            Text("Shelf").tag("Shelf")
        }
        .onAppear(perform: {
            vm.$storage
                .sink { storage in
                    vm.storageSelection = StorageConverter.rawValue(given: storage)
                }
                .store(in: &cancellables)
        })
        .pickerStyle(.segmented)
    }
    
    private var purDatePicker: some View {
        DatePicker("Purchase date", selection: $vm.purchaseDate, displayedComponents: [.date, .hourAndMinute])
    }
    
    private var remindDatePicker: some View {
        DatePicker("Remind date", selection: $vm.remindDate, displayedComponents: [.date, .hourAndMinute])
    }
}
