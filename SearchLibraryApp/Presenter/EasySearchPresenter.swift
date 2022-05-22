//
//  EasySearchPresenter.swift
//  SearchLibraryApp
//
//  Created by t032fj on 2022/05/20.
//

import Foundation
import UIKit

protocol EasySearchPresenterInput: AnyObject {
    
    var numberOfItems: Int { get }
    func item(index: Int) -> Item
    func didGetRakutenData(keyword: String)
    func deleteCollectionItems()
    func didGetBookImage(imageUrl: String, completion: @escaping(UIImage) -> Void)
    func initalizePageCount()
    func addPageCount()
}

protocol EasySearchPresenterOutput: AnyObject {
    
    func updateTable()
}

class EasySearchPresenter {
    
    private weak var output: EasySearchPresenterOutput?
    private var model: EasySearchModelInput
    
    var collectionTableArray: [Item] = []
    var pageCount: Int = 1
    
    init(output: EasySearchPresenterOutput, model: EasySearchModelInput) {
        
        self.output = output
        self.model = model
    }
}

extension EasySearchPresenter: EasySearchPresenterInput {
    
    func deleteCollectionItems() {
        self.collectionTableArray = []
    }
 
    var numberOfItems: Int {
        collectionTableArray.count
    }
    
    func item(index: Int) -> Item {
        collectionTableArray[index]
    }
    
    func didGetRakutenData(keyword: String) {
        
        model.getRakutenData(reloadTimes: self.pageCount, keyword: keyword) { result in
            
            switch result {
                
            case .success(let item):
                self.collectionTableArray += item
                self.output?.updateTable()

            case .failure(let error):
                print(error)
            }
        }
    }
    
    func didGetBookImage(imageUrl: String, completion: @escaping(UIImage) -> Void) {
        
        model.makingImage(imageUrl: imageUrl) { uiImage in
            completion(uiImage)
        }
    }
    
    func initalizePageCount() {
        self.pageCount = 1
    }
    
    func addPageCount() {
        self.pageCount += 1
    }
}
