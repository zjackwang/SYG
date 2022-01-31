//
//  ContentView.swift
//  sYg
//
//  Created by Jack Wang on 12/27/21.
// https://www.youtube.com/watch?v=CimY_Sr3gWw&t=453s
//

import SwiftUI
import Combine

struct ProduceListView: View {
    @StateObject var produceViewModel = ProduceViewModel()
    var body: some View {
        NavigationView {
            List {
                ForEach(produceViewModel.items, id: \.self) {
                    item in
                    HStack {
                        Text(item.Item)
                            .bold()
                        Spacer()
                        Image(systemName: item.IsCut ? "applelogo" : "")
                            .foregroundColor(.red)
                    }
                    .padding(3)
                }
            }
            .listStyle(.inset)
            .navigationTitle("Savable Produce")
            .onAppear {
                produceViewModel.fetchProduce()
            }
        }
    }
}

struct ProduceListView_Previews: PreviewProvider {
    static var previews: some View {
        ProduceListView()
    }
}
