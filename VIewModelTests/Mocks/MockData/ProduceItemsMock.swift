//
//  ProduceItemsMock.swift
//  sYg
//
//  Created by Jack Wang on 2/13/22.
//

import Foundation
@testable import sYg

let produceItemsMock: [ProduceItem] = [
    ProduceItem(Category: "Produce", Item: "Apple", SubCategory: "Fresh", IsCut: false, DaysInFridge: 30, DaysOnShelf: 7, DaysInFreezer: 240, Notes: ""),
    ProduceItem(Category: "Produce", Item: "Avocado", SubCategory: "Fresh", IsCut: false, DaysInFridge: 10, DaysOnShelf: 3, DaysInFreezer: 0, Notes: ""),
    ProduceItem(Category: "Produce", Item: "Corn", SubCategory: "Fresh", IsCut: false, DaysInFridge: 6, DaysOnShelf: 0, DaysInFreezer: 0, Notes: ""),
    ProduceItem(Category: "Produce", Item: "Parsnips", SubCategory: "Fresh", IsCut: false, DaysInFridge: 30, DaysOnShelf: 4, DaysInFreezer: 180, Notes: ""),
    ProduceItem(Category: "Produce", Item: "Banana", SubCategory: "Green", IsCut: false, DaysInFridge: 9, DaysOnShelf: 6, DaysInFreezer: 90, Notes: ""),
    ProduceItem(Category: "Produce", Item: "Banana", SubCategory: "Yellow", IsCut: false, DaysInFridge: 7, DaysOnShelf: 3, DaysInFreezer: 90, Notes: ""),
    ProduceItem(Category: "Produce", Item: "Cabbage", SubCategory: "fresh", IsCut: false, DaysInFridge: 40, DaysOnShelf: 1.5, DaysInFreezer: 365, Notes: ""),
    ProduceItem(Category: "Produce", Item: "Cabbage", SubCategory: "fresh", IsCut: true, DaysInFridge: 7, DaysOnShelf: 0.15, DaysInFreezer: 365, Notes: ""),
    ProduceItem(Category: "Produce", Item: "Red Bell Pepper", SubCategory: "fresh", IsCut: true, DaysInFridge: 12, DaysOnShelf: 0, DaysInFreezer: 180, Notes: ""),
    ProduceItem(Category: "Produce", Item: "Lemon", SubCategory: "fresh", IsCut: true, DaysInFridge: 45, DaysOnShelf: 21, DaysInFreezer: 0, Notes: "")
]
