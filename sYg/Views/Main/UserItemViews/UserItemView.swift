//
//  UserItem.swift
//  sYg
//
//  Created by Jack Wang on 1/31/22.
//

import SwiftUI

struct UserItemView: View {
    @Binding var item: ScannedItem
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
                Text(item.name ?? "unknown")
                    .font(.headline)
                    .fontWeight(.semibold)
                    .padding(.leading, 10)
                    .foregroundColor(onPrimary)
                HStack {
                    Text(item.dateOfPurchase ?? Date.now, format: .dateTime.day().month().year())
                        .font(.subheadline)
                        .padding(.trailing, 20)
                        .foregroundColor(onPrimary)
                    
                    StatusClockView(
                        dateToRemind: $item.dateToRemind,
                        showPopup: $showEatPopup
                    )
                        .onTapGesture {
                            withAnimation(.easeInOut(duration: animationDuration)) {
                                showEatPopup.toggle()
                            }
                        }
                }
            }
            
            PopOverScreen(
                title: "Eat By: ",
                message: item.dateToRemind?.getFormattedDate(format: TimeConstants.reminderDateFormat) ?? "unknown"
            )
                .transition(.move(edge: .trailing))
                .onTapGesture {
                    withAnimation(.easeInOut(duration: animationDuration)) {
                        showEatPopup.toggle()
                    }
                }
                .opacity(showEatPopup ? 1.0 : 0.0)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .listRowBackground(background)
    }
}

//struct UserItemView_Previews: PreviewProvider {
//    static var previews: some View {
//        NavigationView {
//            UserItemView(background: Color.DarkPalette.background)
//                .background(Color.DarkPalette.background)
//                
//        }
//    }
//}
