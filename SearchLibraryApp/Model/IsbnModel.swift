//
//  IsbnModel.swift
//  SearchLibraryApp
//
//  Created by t032fj on 2022/05/06.
//

import Foundation
import UIKit
import CoreData
import Alamofire

protocol IsbnModelInput {
    
    func reverseStar(titleText: String) -> Bool
    func reverseRead(titleText: String) -> Bool
    func createItem(title: String, author: String, imageUrl: String, isbn: String, pubDate: String, detailText: String)
    func getSearchBookData(isbn: String, completion: @escaping([Item]) -> Void)
}

class IsbnModel: IsbnModelInput {
    
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
    
    func reverseRead(titleText: String) -> Bool {
        
        let fetchRequest = NSFetchRequest<CartItem>(entityName:"CartItem")

        fetchRequest.predicate = NSPredicate(format: "title = %@", titleText)
        
        var reverseread: Bool = false

        do {
            let myResults = try context.fetch(fetchRequest)
            
            myResults.forEach { cartitem in

                var currentRead: Bool = cartitem.read
                currentRead.toggle()

                cartitem.setValue(currentRead, forKey: "read")
                
                reverseread = currentRead
            }

            try context.save()
            
            return reverseread

        } catch let error as NSError {

            print("\(error), \(error.userInfo)")
            
            return false
        }
    }
    
    func reverseStar(titleText: String) -> Bool {
        
        let fetchRequest = NSFetchRequest<CartItem>(entityName:"CartItem")

        fetchRequest.predicate = NSPredicate(format: "title = %@", titleText)
        
        var reversestar: Bool = false
        
        do {
            let myResults = try context.fetch(fetchRequest)
            
            myResults.forEach { cartitem in
                
                var currentStar: Bool = cartitem.star
                currentStar.toggle()
                
                cartitem.setValue(currentStar, forKey: "star")
                
                reversestar = currentStar
            }
            
            try context.save()
            
            return reversestar

        } catch let error as NSError {
            
            print("\(error), \(error.userInfo)")
            
            return false
        }
    }
    
    func getSearchBookData(isbn: String, completion: @escaping([Item]) -> Void) {
        
        let url: String = "https://api.openbd.jp/v1/get?isbn=\(isbn)"
        
        var item: [Item] = []
        
        AF.request(url).responseDecodable(of: [IsbnData].self, decoder: JSONDecoder()) { response in
            
            switch response.result {
                
            case .success(let data):
                
                data.forEach { isbn in
                    
                    let Isbn = isbn.summary.isbn
                    let titleText = isbn.summary.title
                    let pubDate = isbn.summary.pubdate
                    let detailText = isbn.onix.CollateralDetail.TextContent[0].Text
                    let imageUrl = isbn.summary.cover
                    let author = isbn.summary.author
                    
                    item = [Item(title: titleText, author: author, isbn: Isbn, salesDate: pubDate, itemCaption: detailText, largeImageUrl: imageUrl)]
                    
                    completion(item)
                }
                
            case .failure(let error):
//                self.detailText = "見つかりませんでした"
                print("error:\(error)")
                
                completion(item)
            }
        }
    }
}
