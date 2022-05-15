//
//  HomeModel.swift
//  SearchLibraryApp
//
//  Created by t032fj on 2022/04/26.
//

import UIKit
import Foundation
import Alamofire
import CoreData

final class HomeModel {
    
    let notificationCenter = NotificationCenter()
    static let notificationName = "HomeModel"
    
    let appDelegate: AppDelegate = UIApplication.shared.delegate as! AppDelegate
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    private(set) var cartItems: [CartItem] = [] {
        didSet {
            var createdDays: [Date] = []
            cartItems.forEach { cartitem in
                createdDays.append(cartitem.createdAt!)
                notificationCenter.post(name: .init(rawValue: HomeModel.notificationName), object: nil, userInfo: ["createdDays" : createdDays])
            }
        }
    }
  
    func fetchAllItem() {
        do {
            cartItems = try context.fetch(CartItem.fetchRequest())
        } catch {
            print("coreDataをダウンロードできませんでした")
        }
    }
    
    func distributeItem(completion: @escaping([Int], [String]) -> Void) {
        
        var months: [String] = []
        cartItems.forEach { cartitem in
            let month = cartitem.createdAt?.toStringWithCurrentLocale().prefix(7)
            guard let month = month else { return }
            months.append(String(month))
        }
    
        let uniqueMonths = Array(Set(months))
        var countArray: [Int] = []
        uniqueMonths.enumerated().map { index, month in
            var c = 0
            var i = 0
            cartItems.forEach { cartItem in
                c += 1
                guard let day = cartItem.createdAt?.toStringWithCurrentLocale() else { return }
                if day.contains(month) {
                    i += 1
                }
                
                if c == cartItems.count {
                    countArray.insert(i, at: index)
                    completion(countArray, uniqueMonths)
                }
            }
        }
    }
    
    func searchLocationLibrary(latitude: Double, longitude: Double) {
        
        let count: Int = 6
        let libraryApikey: String = Apikey().libraryApikey
        let url: String = "https://api.calil.jp/library?appkey=\(libraryApikey)&callback=&geocode=\(longitude),\(latitude)&limit=\(String(count))&format=json"
        var totalArray: [Spot] = []
        var i = 0
        
        AF.request(url).responseDecodable(of: [LocationData].self, decoder: JSONDecoder()) { response in
            
            if case .success(let data) = response.result {
                
                data.forEach { singleData in
                    i += 1
                    
                    let name = singleData.short
                    let distance = singleData.distance
                    let systemid = singleData.systemid
                    let longitude = singleData.geocode.components(separatedBy: ",")[0]
                    let latitude = singleData.geocode.components(separatedBy: ",")[1]
                    let url_pc = singleData.url_pc
                    
                    let spot = Spot(name: name, systemId: systemid, latitude: latitude, longitude: longitude, distance: distance, url_pc: url_pc)
                    
                    totalArray.append(spot)
                    
                    if i == data.count {
                        self.appDelegate.totalArray = totalArray
                    }
                }
            }
        }
    }
}
