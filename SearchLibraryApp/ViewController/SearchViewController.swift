//
//  SearchViewController.swift
//  SearchLibraryApp
//
//  Created by t032fj on 2022/04/26.
//

import UIKit

class SearchViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.title = "探す"
        self.navigationItem.hidesBackButton = true
    }
    
    @IBAction func goIsbnView(_ sender: Any) {
        
        performSegue(withIdentifier: "goIsbn", sender: nil)
    }
    
    @IBAction func goBack(_ sender: Any) {
        
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func goBarcodeView(_ sender: Any) {
        
        performSegue(withIdentifier: "goBarcode", sender: nil)
    }
    
    @IBAction func goEasySearchView(_ sender: Any) {
        
        performSegue(withIdentifier: "goEasySearch", sender: nil)
    }
}
