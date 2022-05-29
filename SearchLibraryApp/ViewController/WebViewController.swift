//
//  WebViewController.swift
//  SearchLibraryApp
//
//  Created by t032fj on 2022/05/02.
//

import UIKit
import WebKit

class WebViewController: UIViewController {
    
    var webTitle: String = ""
    var articleUrl: String = ""
    
    let webView = WKWebView()
    
    @IBOutlet weak var baseView: UIView!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupLayout()
    }
    
    override func viewDidLayoutSubviews() {
        
        webView.frame = baseView.frame
    }
    
    private func setupLayout() {
        
        self.title = String(webTitle)
        
        self.navigationItem.hidesBackButton = true
        
        baseView.addSubview(webView)
        
        let request = URLRequest(url: URL(string: "\(articleUrl)")!)
        webView.load(request)
    }
    
    @IBAction func goBackView(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
}
