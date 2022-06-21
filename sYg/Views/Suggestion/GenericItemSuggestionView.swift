//
//  GenericItemSuggestionView.swift
//  sYg
//
//  Created by Jack Wang on 6/18/22.
//

import SwiftUI
import Combine

// Going to be similar to EditSheetView 
struct GenericItemSuggestionView: View {
    
    @StateObject private var vm = GenericItemSuggestionViewModel.shared
    @StateObject private var usvm = UserSuggestionViewModel.shared

    @State var cancellables = Set<AnyCancellable>()
    
    var body: some View {
        ZStack {
            Form {
                Text(vm.title)
                    .font(.title)
                
                nameField
                categoryPicker
                subcategoryField
                
                VStack {
                    daysInFridgeField
                    daysInFreezerField
                    daysOnShelfField
                }
                
                HStack {
                    Text("Add. Info: ")
                        .foregroundColor(.gray)
                    isCutPicker
                    isCookedPicker
                    isOpenedPicker
                }
                linkField
                
                Button {
                    usvm.showGenericItemSuggestionView.toggle()
                } label: {
                    Text("Cancel")
                }
                
                Button {
                    // save form
                    vm.submitGenericItemSuggestion()
                    usvm.showGenericItemSuggestionView.toggle()
                } label: {
                    Text("Save")
                }
                .opacity(vm.showConfirmButton ? 1.0 : 0.25)
            
            }
        }
    }
}

struct GenericItemSuggestionView_Previews: PreviewProvider {
    static var previews: some View {
        GenericItemSuggestionView()
    }
}

// MARK: Components
extension GenericItemSuggestionView {
    private var nameField: some View {
        HStack {
            Text("Name: ")
                .foregroundColor(.gray)
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
    }
    
    private var categoryPicker: some View {
        HStack{
            Text("Category: ")
                .foregroundColor(.gray)
            Picker("Category", selection: $vm.categorySelection) {
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
            .pickerStyle(.menu)
        }
        
        
    }
    
    private var daysInFridgeField: some View {
        HStack{
            Text("Days In Fridge: ")
                .foregroundColor(.gray)
            
            TextField("\(vm.daysInFridge.formatted)", text: $vm.daysInFridgeText)
                .overlay(
                    ZStack {
                        Image(systemName: "xmark")
                            .foregroundColor(.red)
                            .opacity(
                                vm.daysInFridgeTextIsValid ? 0.0 : 1.0)
                        
                        Image(systemName: "checkmark")
                            .foregroundColor(.green)
                            .opacity(vm.daysInFridgeTextIsValid ? 1.0: 0.0)
                    }
                    .font(.headline)
                    .padding(.trailing)
                    , alignment: .trailing
                )
        }
    }
    private var daysInFreezerField: some View {
        HStack{
            Text("Days In Freezer: ")
                .foregroundColor(.gray)

            TextField("\(vm.daysInFreezer.formatted)", text: $vm.daysInFreezerText)
                .overlay(
                    ZStack {
                        Image(systemName: "xmark")
                            .foregroundColor(.red)
                            .opacity(
                                vm.daysInFreezerTextIsValid ? 0.0 : 1.0)
                        
                        Image(systemName: "checkmark")
                            .foregroundColor(.green)
                            .opacity(vm.daysInFreezerTextIsValid ? 1.0: 0.0)
                    }
                        .font(.headline)
                        .padding(.trailing)
                    , alignment: .trailing
                )
        }
    }
    
    private var daysOnShelfField: some View {
        HStack{
            Text("Days On Shelf: ")
                .foregroundColor(.gray)
        
            TextField("\(vm.daysOnShelf.formatted)", text: $vm.daysOnShelfText)
                .overlay(
                    ZStack {
                        Image(systemName: "xmark")
                            .foregroundColor(.red)
                            .opacity(
                                vm.daysOnShelfTextIsValid ? 0.0 : 1.0)
                        
                        Image(systemName: "checkmark")
                            .foregroundColor(.green)
                            .opacity(vm.daysOnShelfTextIsValid ? 1.0: 0.0)
                    }
                        .font(.headline)
                        .padding(.trailing)
                    , alignment: .trailing
                )
        }
    }
    
    private var isCutPicker: some View {
        return Picker("IsCut", selection: $vm.isCutSelection) {
            Text("Uncut").tag("Uncut")
            Text("Cut").tag("Cut")
        }
        .onAppear {
            vm.$isCut
                .sink { isCut in
                    vm.isCutSelection = isCut ? "Cut" : "Uncut"
                }
                .store(in: &cancellables)
        }
        .pickerStyle(.menu)
    }
    
    private var isCookedPicker: some View {
        return Picker("IsCooked", selection: $vm.isCookedSelection) {
            Text("Uncooked").tag("Uncooked")
            Text("Cooked").tag("Cooked")
        }
        .onAppear {
            vm.$isCooked
                .sink { isCooked in
                    vm.isCookedSelection = isCooked ? "Cooked" : "Uncooked"
                }
                .store(in: &cancellables)
        }
        .pickerStyle(.menu)
    }
    
    private var isOpenedPicker: some View {
        return Picker("isOpened", selection: $vm.isOpenedSelection) {
            Text("Unopened").tag("Unopened")
            Text("Opened").tag("Opened")
        }
        .onAppear {
            vm.$isOpened
                .sink { isOpened in
                    vm.isOpenedSelection = isOpened ? "Opened" : "Unopened"
                }
                .store(in: &cancellables)
        }
        .pickerStyle(.menu)
    }
    
    private var subcategoryField: some View {
        HStack{
            Text("Subcategory (opt.): ")
                .foregroundColor(.gray)
            TextField("Enter subcategory if applicable", text: $vm.subcategory)
        }
    }
    
    private var linkField: some View {
        HStack{
            Text("Link: ")
                .foregroundColor(.gray)
            TextField("Enter link to source if applicable", text: $vm.link)
        }
    }
    
}
