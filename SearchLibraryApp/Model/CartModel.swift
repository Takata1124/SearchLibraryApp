//
//  CartModel.swift
//  SearchLibraryApp
//
//  Created by t032fj on 2022/05/14.
//

import Foundation
import UIKit
import CoreData

protocol CartModelInput {
    
    func fetchAllItem() -> [CartItem]
    func deleteSelectedItem(item: CartItem, completion: @escaping(Bool) -> ())
    func filterStarItem(isStarFilter: Bool, completion: @escaping([CartItem], Bool) -> ())
}

class CartModel: CartModelInput {
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    func fetchAllItem() -> [CartItem] {
        do {
            let cartItems = try context.fetch(CartItem.fetchRequest())
            return cartItems
        } catch {
            print("error")
            return []
        }
    }
    
    func deleteSelectedItem(item: CartItem, completion: @escaping(Bool) -> ()) {
        
        context.delete(item)
        
        do {
            try context.save()
            completion(true)
        } catch {
            print("CoreDataに保存できませんでした")
            completion(false)
        }
    }
    
    func filterStarItem(isStarFilter: Bool, completion: @escaping([CartItem], Bool) -> ()){
        
        let fetchRequest = NSFetchRequest<CartItem>(entityName: "CartItem")
        
        if isStarFilter == false {
            fetchRequest.predicate = NSPredicate(format: "star = %d", true)
        } else {
            fetchRequest.predicate = NSPredicate(format: "star = %d", false)
        }
        
        var isStarFilter = isStarFilter
        isStarFilter.toggle()
        
        do {
            let cartItemModel = try context.fetch(fetchRequest)
            completion(cartItemModel, isStarFilter)
        } catch {
            print(error)
            completion([], isStarFilter)
        }
    }
}
