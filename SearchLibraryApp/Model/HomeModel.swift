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

protocol HomeModelInput {
    
    func distributeItem(cartItems: [CartItem], completion: @escaping([Int], [String]) -> Void)
    func searchLocationLibrary(latitude: Double, longitude: Double)
    func fetchAllItem(completion: @escaping([Date], [CartItem]) -> Void)
}

class HomeModel: HomeModelInput {
    
    let appDelegate: AppDelegate = UIApplication.shared.delegate as! AppDelegate
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext

    func fetchAllItem(completion: @escaping([Date], [CartItem]) -> Void) {
        do {
            let cartItems = try context.fetch(CartItem.fetchRequest())
            
            var createdDays: [Date] = []
            cartItems.forEach { cartitem in
                createdDays.append(cartitem.createdAt!)
                completion(createdDays, cartItems)
            }
        } catch {
            completion([], [])
        }
    }
    
    func distributeItem(cartItems: [CartItem], completion: @escaping([Int], [String]) -> Void) {
        
        var months: [String] = []
        
        cartItems.forEach { cartitem in
            let month = cartitem.createdAt?.toStringWithCurrentLocale().prefix(7)
            if let month = month {
                months.append(String(month))
            }
        }
    
        let uniqueMonths = Array(Set(months))
        var countArray: [Int] = []
        uniqueMonths.enumerated().map { monthIndex, month in
            var i = 0
            
            cartItems.enumerated().forEach { index, cartitem in
                if let day = cartitem.createdAt?.toStringWithCurrentLocale() {
                
                    if day.contains(month) {
                        i += 1
                    }
                    
                    if index == cartItems.count - 1 {
                        countArray.insert(i, at: monthIndex)
                        completion(countArray, uniqueMonths)
                    }
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
