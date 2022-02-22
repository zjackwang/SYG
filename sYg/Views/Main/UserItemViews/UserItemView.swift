//
//  UserItem.swift
//  sYg
//
//  Created by Jack Wang on 1/31/22.
//

import SwiftUI

struct UserItemView: View {
    @State private var showEatPopup = false
    
    var item: ScannedItem?
    let columns = [
                GridItem(.flexible()),
                GridItem(.flexible()),
            ]
    var body: some View {
        LazyVGrid(columns: columns, spacing: 30) {
            Text(item?.name ?? "unknown")
                .font(.headline)
                .fontWeight(.semibold)
                .padding(.leading, 10)
            HStack {
                Text(item?.dateOfPurchase ?? Date.now, format: .dateTime.day().month().year())
                    .font(.subheadline)
                    .padding(.trailing, 20)
                
                StatusClockView(dateToRemind: item?.dateToRemind ?? Date.init(timeIntervalSinceNow: 3 * TimeConstants.settings.dayTimeInterval))
                    .onTapGesture {
                        showEatPopup = true
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
            UserItemView()
        }
    }
}
