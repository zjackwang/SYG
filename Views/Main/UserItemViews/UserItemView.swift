//
//  UserItem.swift
//  sYg
//
//  Created by Jack Wang on 1/31/22.
//

import SwiftUI

struct UserItemView: View {
    @State private var showEatPopup = false
    
    var item: UserItem
    let columns = [
                GridItem(.flexible()),
                GridItem(.flexible()),
            ]
    var body: some View {
        LazyVGrid(columns: columns, spacing: 30) {
            Text(item.Name)
                .font(.headline)
                .fontWeight(.semibold)
                .padding(.leading, 10)
            HStack {
                Text(item.DateOfPurchase, format: .dateTime.day().month().year())
                    .font(.subheadline)
                    .padding(.trailing, 10)
                // Have a progress bar with color to depict
                StatusClockView(dateToRemind: item.DateToRemind)
                    .onTapGesture {
                        showEatPopup = true
//                        removeUserItem(svm, item.Name)
                    }
//                    .popover(isPresented: $showEatPopup) {
//                        Button {
//                            removeUserItem(svm, item.Name)
//                        } label: {
//                            Text("Eat or Discard")
//                        }
//                    }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

struct UserItemView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            UserItemView(item: UserItem(Name: "Apple", DateOfPurchase: Date.now, DateToRemind: Date.init(timeIntervalSinceNow: 1000)))
        }
    }
}
