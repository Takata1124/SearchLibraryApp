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

}
