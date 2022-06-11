//
//  Order.swift
//  SearchLibraryApp
//
//  Created by t032fj on 2022/06/11.
//

import Foundation

class Order: Equatable {
    
    static func == (lhs: Order, rhs: Order) -> Bool {
        lhs.id == rhs.id
    }

    let id: Int64
    let isNewOrder: Bool
    
    init(id: Int64, isNewOrder: Bool) {
        self.id = id
        self.isNewOrder = isNewOrder
    }
}
