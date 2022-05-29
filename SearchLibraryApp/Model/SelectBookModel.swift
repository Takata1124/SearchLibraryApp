//
//  SelectBookModel.swift
//  SearchLibraryApp
//
//  Created by t032fj on 2022/05/22.
//

import Foundation
import Alamofire
import SwiftyJSON

protocol SelectBookModelInput {
    
    func searchBooks(isbn: String, systemId: String, completion: @escaping(String) -> Void)
}

class SelectBookModel: SelectBookModelInput {
    
    func searchBooks(isbn: String, systemId: String, completion: @escaping(String) -> Void) {
        
        let api_key = Apikey().libraryApikey
        
        let url = "https://api.calil.jp/check?appkey=\(api_key)&isbn=\(isbn)&systemid=\(systemId)&callback=no&format=json"
        
        AF.request(url).responseJSON { response in
            
            guard let data = response.data else {
                completion("蔵書なし")
                return
            }
            
            do {
                let json = try JSON(data: data)
                
                guard let conTinue = json["continue"].int else {
                    completion("蔵書なし")
                    return
                }
                
                if conTinue == 0 {
                    
                    guard let situation = json["books"]["\(isbn)"]["\(systemId)"]["libkey"].dictionary else {
                        completion("蔵書なし")
                        return
                    }
                    
                    if let key = situation.keys.first {
                        
                        guard let borrow = situation[key] else {
                            completion("蔵書なし")
                            return
                        }
                        
                        let result = borrow.rawValue as! String
                        completion(result)
                    }
                    else {
                        completion("蔵書なし")
                    }
                } else {
                    completion("検索中")
                }
            } catch {
                completion("検出不可")
            }
        }
    }
}
