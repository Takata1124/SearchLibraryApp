//
//  SelectPresenter.swift
//  SearchLibraryApp
//
//  Created by t032fj on 2022/05/22.
//

import Foundation

protocol SelectBookPresenterInput: AnyObject {
    
    func searchBook(isbn: String, systemId: String, completion: @escaping(String) -> Void)
}

protocol SelectBookPresenterOutput: AnyObject {
    
    
}

class SelectBookPresenter {
    
    private weak var output: SelectBookPresenterOutput?
    private var model: SelectBookModelInput
    
    init(output: SelectBookPresenterOutput, model: SelectBookModelInput) {
        self.output = output
        self.model = model
    }
}

extension SelectBookPresenter: SelectBookPresenterInput {
    
    func searchBook(isbn: String, systemId: String, completion: @escaping(String) -> Void) {
        model.searchBooks(isbn: isbn, systemId: systemId) { resultText in
            completion(resultText)
        }
    }
}
