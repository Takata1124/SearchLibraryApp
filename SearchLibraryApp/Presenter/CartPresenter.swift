//
//  CartPresenter.swift
//  SearchLibraryApp
//
//  Created by t032fj on 2022/05/14.
//

import Foundation

protocol CartPresenterInput: AnyObject {
    
    var numberOfItems: Int { get }
    func item(index: Int) -> CartItem
    func didTapSelectRemoveItem(index: Int)
    func didTapFilterStar(isStarFiter: Bool)
}
// 出力
protocol CartPresenterOutput: AnyObject {
    
    func updateTable()
    func updateIsStarFilterSituation(isStarFilter: Bool)
}

class CartPresenter {
    
    private weak var output: CartPresenterOutput?
    private var model: CartModelInput
    
    var cartItem: [CartItem] = []
    
    init(output: CartPresenterOutput, model: CartModelInput) {
        self.output = output
        self.model = model
        self.cartItem = model.fetchAllItem()
    }
}

extension CartPresenter: CartPresenterInput {
    
    var numberOfItems: Int {
        cartItem.count
    }
    
    func item(index: Int) -> CartItem {
        cartItem[index]
    }
    
    func didTapSelectRemoveItem(index: Int) {
        
        model.deleteSelectedItem(item: cartItem[index]) { success in
            
            if success {
                self.cartItem = self.model.fetchAllItem()
                DispatchQueue.main.async {
                    self.output?.updateTable()
                }
            }
        }
    }
    
    func didTapFilterStar(isStarFiter: Bool) {
        
        model.filterStarItem(isStarFilter: isStarFiter) { item, isStarFilter  in
         
            self.cartItem = item
            DispatchQueue.main.async {
                self.output?.updateTable()
                self.output?.updateIsStarFilterSituation(isStarFilter: isStarFilter)
            }
        }
    }
}
