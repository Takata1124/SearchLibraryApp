//
//  Router.swift
//  SearchLibraryApp
//
//  Created by t032fj on 2022/05/29.
//

import Foundation
import UIKit

protocol IsbnRouterInput: AnyObject {
    
    func transionGoBookView()
}

class IsbnRouter {
    
    private var viewController: UIViewController!
    
    init(viewController: UIViewController) {
        self.viewController = viewController
    }
}

extension IsbnRouter: IsbnRouterInput {
    
    func transionGoBookView() {
        viewController.performSegue(withIdentifier: "goBook", sender: nil)
    }
}
