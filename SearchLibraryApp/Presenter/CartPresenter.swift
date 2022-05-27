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
    func didTapReloadTable()
    func didTapSelectRemoveItem(index: Int)
    func didTapFilterStar(isStarFiter: Bool)
    func didTapFilterRead(isRead: Bool)
    func didTapChangeOrder(isNewOrder: Bool)
    func didTapSearchButton(searchText: String)
}
// 出力
protocol CartPresenterOutput: AnyObject {
    
    func updateTable()
    func updateIsStarFilterSituation(isStarFilter: Bool)
    func updateIsReadFilterSituation(isRead: Bool)
    func updateIsOrderSituation(isNewOrder: Bool)
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
    
    func didTapReloadTable() {
        
        self.cartItem = self.model.fetchAllItem()
        DispatchQueue.main.async {
            self.output?.updateTable()
        }
    }
    
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
    
    func didTapFilterRead(isRead: Bool) {
        
        model.filterReadItem(isRead: isRead) { item, isRead in
            
            self.cartItem = item
            
            DispatchQueue.main.async {
                self.output?.updateTable()
                self.output?.updateIsReadFilterSituation(isRead: isRead)
            }
        }
    }
    
    func didTapChangeOrder(isNewOrder: Bool) {
        
        model.changeOrderItem(isNewOrder: isNewOrder) { item, isNewOrder in
            
            self.cartItem = item
            
            DispatchQueue.main.async {
                self.output?.updateTable()
                self.output?.updateIsOrderSituation(isNewOrder: isNewOrder)
            }
        }
    }
    
    func didTapSearchButton(searchText: String) {
        
        model.searchItem(searchText: searchText) { item in
            self.cartItem = item
            
            DispatchQueue.main.async {
                self.output?.updateTable()
            }
        }
    }
}