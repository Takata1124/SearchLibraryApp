//
//  IsbnPresenter.swift
//  SearchLibraryApp
//
//  Created by t032fj on 2022/05/18.
//

import Foundation

protocol IsbnPresenterInput: AnyObject {
    
    func didTapReverseStar(text: String)
    func didTapReverseRead(text: String)
    func didAddStoredItem(title: String, author: String, imageUrl: String, isbn: String, pubDate: String, detailText: String)
    func didGetSearchBookData(isbn: String)
}

protocol IsbnPresenterOutput: AnyObject {
    
    func updateStarItem(isStar: Bool)
    func updateReadItem(isRead: Bool)
    func updateBookItem(item: Item)
    func updateDetailText()
}

class IsbnPresenter {
    
    private weak var output: IsbnPresenterOutput?
    private var model: IsbnModelInput
    
    init(output: IsbnPresenterOutput, model: IsbnModelInput) {
        self.output = output
        self.model = model
    }
}

extension IsbnPresenter: IsbnPresenterInput {

    func didTapReverseStar(text: String) {
        
        let isCurrentStar = model.reverseStar(titleText: text)
        
        DispatchQueue.main.async {
            self.output?.updateStarItem(isStar: isCurrentStar)
        }
    }
    
    func didTapReverseRead(text: String) {
        
        let isCurrentRead = model.reverseRead(titleText: text)
        
        DispatchQueue.main.async {
            self.output?.updateReadItem(isRead: isCurrentRead)
        }
    }
    
    func didAddStoredItem(title: String, author: String, imageUrl: String, isbn: String, pubDate: String, detailText: String) {
        
        model.createItem(title: title, author: author, imageUrl: imageUrl, isbn: isbn, pubDate: pubDate, detailText: detailText)
    }
    
    func didGetSearchBookData(isbn: String) {
        
        model.getSearchBookData(isbn: isbn) { item in
            
            if item != [] {
                self.output?.updateBookItem(item: item[0])
            } else {
                self.output?.updateDetailText()
            }
        }
    }
}
