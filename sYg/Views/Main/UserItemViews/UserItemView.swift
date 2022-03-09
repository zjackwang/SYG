//
//  UserItem.swift
//  sYg
//
//  Created by Jack Wang on 1/31/22.
//

import SwiftUI

struct UserItemView: View {
    var item: ScannedItem?
    let background: Color
    
    @State private var showEdit = false
    @State private var showEatPopup = false

    private let onPrimary: Color = Color.DarkPalette.onPrimary
    private let animationDuration = 0.45
    let columns = [
                GridItem(.flexible()),
                GridItem(.flexible()),
            ]
    var body: some View {
        ZStack {
            LazyVGrid(columns: columns, spacing: 30) {
                Text(item?.name ?? "unknown")
                    .font(.headline)
                    .fontWeight(.semibold)
                    .padding(.leading, 10)
                    .foregroundColor(onPrimary)
                HStack {
                    Text(item?.dateOfPurchase ?? Date.now, format: .dateTime.day().month().year())
                        .font(.subheadline)
                        .padding(.trailing, 20)
                        .foregroundColor(onPrimary)
                    
                    StatusClockView(
                        dateToRemind: item?.dateToRemind ?? Date.init(timeIntervalSinceNow: 3 * TimeConstants.dayTimeInterval),
                        showPopup: $showEatPopup
                    )
                        .onTapGesture {
                            withAnimation(.easeInOut(duration: animationDuration)) {
                                showEatPopup.toggle()
                            }
                        }
                }
            }
            .onLongPressGesture(perform: {
                showEdit.toggle()
            })
            
            PopOverScreen(
                title: "Eat By: ",
                message: item?.dateToRemind?.getFormattedDate(format: TimeConstants.reminderDateFormat) ?? "unknown"
            )
                .transition(.move(edge: .trailing))
                .onTapGesture {
                    withAnimation(.easeInOut(duration: animationDuration)) {
                        showEatPopup.toggle()
                    }
                }
                .opacity(showEatPopup ? 1.0 : 0.0)
            
            EditSheetView(
                show: $showEdit,
                nameText: item?.name ?? "unknown",
                purchaseDate: item?.dateOfPurchase ?? Date.now,
                remindDate: item?.dateToRemind ?? Date.now,
                oldItem: item)
            
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .listRowBackground(background)
    }
}

struct EditSheetView: View {
    @Binding var show: Bool
    @State var nameText: String
    @State var purchaseDate: Date
    @State var remindDate: Date

    var oldItem: ScannedItem?
    
    @StateObject private var sivm = ScannedItemViewModel.shared
    @State var showAlert = false
    @State var isError = false
    @State var alertText = ""
    
    var body: some View {
        ZStack {
            Form {
                Text("Edit Item Info")
                    .font(.title)
                TextField("Enter new item name", text: $nameText)
                
                DatePicker("Purchase date", selection: $purchaseDate, displayedComponents: [.date, .hourAndMinute])
                
                DatePicker("Remind date", selection: $remindDate, displayedComponents: [.date, .hourAndMinute])
                
                Button {
                    // save form
                    showAlert.toggle()
                } label: {
                    Text("Save")
                }
            }
            
        }
        .alert(isPresented: $showAlert) {
            Alert(
                title: Text("Results"),
                message: Text(alertText),
                dismissButton: .default(
                    Text("Ok"),
                    action: {
                        if !isError {
                            show.toggle()
                            isError.toggle()
                        }
                        showAlert.toggle()
                    }
               ))
        }
        .opacity(show ? 1.0 : 0.0)
    }
}

extension EditSheetView {
    func saveEditedItem() {
        if nameText.count < 3 {
            showAlert.toggle()
            isError.toggle()
            alertText = "Name should have at least 3 characters!"
        }
        
        if sivm.updateScannedItem(oldName: oldItem?.name ?? "Unknown", name: nameText, purchaseDate: purchaseDate, remindDate: remindDate) {
            showAlert.toggle()
            alertText = "Update successful!"
        } else {
            showAlert.toggle()
            isError.toggle()
            alertText = "Update unsuccessful."
        }
    }
}



struct UserItemView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            UserItemView(background: Color.DarkPalette.background)
                .background(Color.DarkPalette.background)
                
        }
    }
}
