//
//  ConfirmationViewModel.swift
//  sYg
//
//  Created by Jack Wang on 4/3/22.
//

import SwiftUI
import Combine

class ConfirmationViewModel: ObservableObject {
    static let shared = ConfirmationViewModel()
    
    // Unsaved unconfirmed items. subject to change
    @Published var itemsToConfirm: [UserItem] = []
    
    private var evm = EditViewModel.shared
    
    func setItemsToConfirm(itemsToConfirm: [UserItem]) {
        self.itemsToConfirm = itemsToConfirm
    }
    
 
    func deleteItem(item: UserItem) {
        itemsToConfirm.removeAll(where: { $0.id == item.id })
    }
    
    // Once EditSheetView exits (saves), should get all info into user item
    //  and update the confirmation list of user items
    //  how to detect the sheet view exiting?
    
    
    /*
     * String id: id of item to be updated
     * UserItem newItem: new item with updated info
     */    
    func updateUserItem(for id: String) {
        let i = itemsToConfirm.firstIndex(where: {$0.id == id})
        guard let i = i else { return }

        itemsToConfirm[i] = evm.saveEditsToUserItem()
    }
}
