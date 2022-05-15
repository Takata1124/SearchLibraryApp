//
//  CartItem+CoreDataProperties.swift
//  
//
//  Created by t032fj on 2022/04/28.
//
//

import Foundation
import CoreData


extension CartItem {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<CartItem> {
        return NSFetchRequest<CartItem>(entityName: "CartItem")
    }

    @NSManaged public var title: String?
    @NSManaged public var author: String?
    @NSManaged public var imageUrl: String?
    @NSManaged public var isbn: String?
    @NSManaged public var pubDate: String?
    @NSManaged public var detailText: String?
    @NSManaged public var createdAt: Date?
    @NSManaged public var read: Bool?
    @NSManaged public var star: Bool?
}
