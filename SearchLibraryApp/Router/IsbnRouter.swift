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
    
    init(vc: UIViewController) {
        self.viewController = vc
    }
}

extension IsbnRouter: IsbnRouterInput {
    
    func transionGoBookView() {
        viewController.performSegue(withIdentifier: "goBook", sender: nil)
    }
}
