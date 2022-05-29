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
    func filterReadItem(isRead: Bool, completion: @escaping([CartItem], Bool) -> ())
    func changeOrderItem(isNewOrder: Bool, completion: @escaping([CartItem], Bool) -> ())
    func searchItem(searchText: String, completion: @escaping([CartItem]) -> ())
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
            completion([], false)
        }
    }
    
    func filterReadItem(isRead: Bool, completion: @escaping([CartItem], Bool) -> ()) {
        
        let fetchRequest = NSFetchRequest<CartItem>(entityName: "CartItem")
        
        if isRead == false {
            fetchRequest.predicate = NSPredicate(format: "read = %d", true)
        } else {
            fetchRequest.predicate = NSPredicate(format: "read = %d", false)
        }
        
        var isRead = isRead
        isRead.toggle()
        
        do {
            let cartItemModel = try context.fetch(fetchRequest)
            completion(cartItemModel, isRead)
        } catch {
            print(error)
            completion([], false)
        }
    }
    
    func changeOrderItem(isNewOrder: Bool, completion: @escaping([CartItem], Bool) -> ()) {
        
        let fetchRequest = NSFetchRequest<CartItem>(entityName: "CartItem")
        
        let sort: NSSortDescriptor?
        
        if isNewOrder == false {
            sort = NSSortDescriptor(key: "pubDate", ascending: true)
        } else {
            sort = NSSortDescriptor(key: "pubDate", ascending: false)
        }
        
        if let sort = sort {
            
            fetchRequest.sortDescriptors = [sort]
            
            do {
                var isNewOrder = isNewOrder
                isNewOrder.toggle()
                
                let cartItemModel = try context.fetch(fetchRequest)
                completion(cartItemModel, isNewOrder)
                return
            } catch {
                print(error)
            }
        }
        
        completion([], false)
    }
    
    func searchItem(searchText: String, completion: @escaping([CartItem]) -> ()) {
        
        let fetchRequest = NSFetchRequest<CartItem>(entityName: "CartItem")
        
        if searchText != "" {

            fetchRequest.predicate = NSPredicate(format:"title CONTAINS %@ || author CONTAINS %@", "\(searchText)", "\(searchText)")
            
            do {
                let cartItemModel = try context.fetch(fetchRequest)
                completion(cartItemModel)
                return
            } catch {
                print(error)
            }
        }
        completion([])
    }
}
