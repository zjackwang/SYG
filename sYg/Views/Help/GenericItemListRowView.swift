//
//  GenericItemListRowView.swift
//  sYg
//
//  Created by Jack Wang on 4/19/22.
//

import SwiftUI

struct GenericItemListRowView: View {
    @Binding var item: GenericItem
    
    let columns = [
                GridItem(.flexible(maximum: 100)), // Category
                GridItem(.flexible(maximum: 100)), // Name
                GridItem(.flexible(maximum: 100)), // Times
//                GridItem(.flexible()), // Link?
    ]
    
    private let background: Color = Color.DarkPalette.background
    private let onBackground: Color = Color.DarkPalette.onBackground
    private let primary: Color = Color.DarkPalette.primary
    private let onPrimary: Color = Color.DarkPalette.onPrimary

    var body: some View {
        ZStack {
            LazyVGrid(columns: columns) {
                Text(item.Category)
                    .font(.headline)
                    .fontWeight(.semibold)
//                    .padding(.leading, 10)
                    .foregroundColor(onPrimary)
                Text(item.Name)
                    .font(.headline)
                    .fontWeight(.semibold)
//                    .padding(.leading, 10)
                    .foregroundColor(onPrimary)
                HStack {
                   eatByText
//                    .padding(.trailing)
            }
                
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .listRowBackground(background)
        }
    }
}

extension GenericItemListRowView {
    private var eatByText: Text {
        let fridgeTimeInDays = String(format: "%.1f", item.DaysInFridge / 24 * 60 * 60)
        let freezerTimeInDays = String(format: "%.1f", item.DaysInFreezer / 24 * 60 * 60)
        let shelfTimeInDays = String(format: "%.1f", item.DaysOnShelf / 24 * 60 * 60)
        
        return Text("\(fridgeTimeInDays) | \(freezerTimeInDays) | \(shelfTimeInDays)")
            .font(.subheadline)
//                        .padding(.trailing, 20)
            .foregroundColor(onPrimary)
    }
}
    
//struct ShowGenericItemListRowView: View {
//    @State var item: GenericItem = GenericItem(Name: "Example", DaysInFridge: 10, DaysInFreezer: 100, DaysOnShelf: 1, Category: "Produce", Subcategory: "Fresh", IsCut: false, IsCooked: false, IsOpened: false, Notes: "", Links: "")
//    var body: some View {
//        GenericItemListRowView(item: $item)
//    }
//}
//
//struct GenericItemListRowView_Previews: PreviewProvider {
//    static var previews: some View {
//        ShowGenericItemListRowView()
//    }
//}