//
//  EasySearchModel.swift
//  SearchLibraryApp
//
//  Created by t032fj on 2022/05/20.
//

import Foundation
import Alamofire

protocol EasySearchModelInput {
    
    func getRakutenData(reloadTimes: Int, keyword: String, completion: @escaping (Result<[Item], Error>) -> Void)
    func makingImage(imageUrl: String, completion: @escaping (UIImage) -> Void) 
}

class EasySearchModel: EasySearchModelInput {
    
    func getRakutenData(reloadTimes: Int, keyword: String, completion: @escaping (Result<[Item], Error>) -> Void) {
        
        let API_Key = Apikey().rakutenapikey
        var itemData = [Item]()
        let hit: Int = 30
        let page: Int = reloadTimes
        let reserch: String = keyword
        let encodeKeyword: String = reserch.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
        
        let url = "https://app.rakuten.co.jp/services/api/BooksTotal/Search/20170404?format=json&keyword=\(encodeKeyword)&booksGenreId=000&hits=\(String(hit))&page=\(String(page))&applicationId=\(API_Key)"
        
        AF.request(url).responseDecodable(of: RakutenData.self, decoder: JSONDecoder()) { response in
            
            switch response.result {
                
            case .success(let data):
                
                data.Items.forEach { item in
                    let title = item.Item.title
                    let author = item.Item.author
                    let itemCaption = item.Item.itemCaption
                    let imageUrl = item.Item.largeImageUrl
                    let isbn = item.Item.isbn
                    let salesDate = item.Item.salesDate
                    if isbn != "" {
                        itemData.append(Item(title: title, author: author, isbn: isbn, salesDate: salesDate, itemCaption: itemCaption, largeImageUrl: imageUrl))
                    }
                }
                
                completion(.success(itemData))
                
            case .failure(let error):
                
                completion(.failure(error))
            }
        }
    }
    
    func makingImage(imageUrl: String, completion: @escaping (UIImage) -> Void) {
        
        AF.request(imageUrl).responseImage { responseImage in
            if case .success(let uiImage) = responseImage.result {
                completion(uiImage)
            }
        }
    }
}
