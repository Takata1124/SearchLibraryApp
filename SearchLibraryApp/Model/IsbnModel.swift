//
//  IsbnModel.swift
//  SearchLibraryApp
//
//  Created by t032fj on 2022/05/06.
//

import Foundation
import UIKit
import CoreData

final class IsbnModel {
    
    let notificationCenter = NotificationCenter()
    static let notificationName = "IsbnModel"
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    func createItem(title: String, author: String, imageUrl: String, isbn: String, pubDate: String, detailText: String) {
        
        let cartItem = CartItem(context: context)
        cartItem.title = title
        cartItem.author = author
        cartItem.imageUrl = imageUrl
        cartItem.isbn = isbn
        cartItem.pubDate = pubDate
        cartItem.detailText = detailText
        cartItem.createdAt = Date()
        cartItem.read = false
        cartItem.star = false
        
        do {
            try context.save()
        }
        catch {
            print("saveできませんでした")
        }
    }
    
    func reverseRead(title: String) {
        
        let fetchRequest = NSFetchRequest<CartItem>(entityName:"CartItem")

        fetchRequest.predicate = NSPredicate(format: "title = %@", title)

        do {
            let myResults = try context.fetch(fetchRequest)
            
            myResults.forEach { cartitem in

                var currentRead: Bool = cartitem.read
                currentRead.toggle()
                
                notificationCenter.post(name: .init(rawValue: IsbnModel.notificationName), object: nil, userInfo: ["currentRead" : currentRead])

                cartitem.setValue(currentRead, forKey: "read")
            }

            try context.save()

        } catch let error as NSError {

            print("\(error), \(error.userInfo)")
        }
    }
    
}
