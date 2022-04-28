//
//  ViewController.swift
//  SearchLibraryApp
//
//  Created by t032fj on 2022/04/26.
//

import UIKit
import Alamofire
import AlamofireImage
import CoreData

class IsbnViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var isbnTextField: UITextField!
    @IBOutlet weak var coverImage: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var isbnLabel: UILabel!
    @IBOutlet weak var pubdateLabel: UILabel!
    @IBOutlet weak var detailLabel: UILabel!
    @IBOutlet weak var authorLabel: UILabel!
    
    var isbnInputText = ""
    var item: Item?
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext

    var isbn: String = "" {
        didSet {
            self.isbnLabel.text = "isbn:\(isbn)"
        }
    }
    
    var pubDate: String = "" {
        didSet {
            self.pubdateLabel.text = "出版日:\(pubDate)"
        }
    }
    
    var titleText: String = "" {
        didSet {
            self.titleLabel.text = "タイトル:\(titleText)"
        }
    }
    
    var detailText: String = "" {
        didSet {
            self.detailLabel.text = detailText
        }
    }
    
    var imageUrl: String = "" {
        didSet {
            self.coverImage.image = nil
            getUrlImage(imageUrl: imageUrl)
        }
    }
    
    var author: String = "" {
        didSet {
            self.authorLabel.text = "著者:\(author)"
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupLayout()
        
        self.titleText = item?.title ?? ""
        self.author = item?.author ?? ""
        self.isbn = item?.isbn ?? ""
        self.pubDate = item?.salesDate ?? ""
        self.detailText = item?.itemCaption ?? ""
        
        getUrlImage(imageUrl: item?.largeImageUrl ?? "")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        self.isbnTextField.text = isbnInputText
    }
    
    private func setupLayout() {
        
        self.navigationItem.title = "Isbn"
        
        isbnTextField.placeholder = "isbn"
        isbnTextField.keyboardType = .numberPad
        
        let leftPadding = UIView(frame: CGRect(x: 0, y: 0, width: 3, height: 0))
        leftPadding.backgroundColor = UIColor.clear
        isbnTextField.leftView = leftPadding
        isbnTextField.leftViewMode = .always
        
        isbnTextField.delegate = self

        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    @IBAction func searchBook(_ sender: Any) {
        
        self.titleText = ""
        self.author = ""
        self.isbn = ""
        self.pubDate = ""
        self.detailText = ""
        self.coverImage.image = nil
        
        self.view.endEditing(true)
        
        guard let isbn = isbnTextField.text else { return }
        
        let url: String = "https://api.openbd.jp/v1/get?isbn=\(isbn)"
        
        AF.request(url).responseDecodable(of: [IsbnData].self, decoder: JSONDecoder()) { response in
            
            switch response.result {
                
            case .success(let data):
                
                data.forEach { isbn in
                    self.isbn = isbn.summary.isbn
                    self.titleText = isbn.summary.title
                    self.pubDate = isbn.summary.pubdate
                    self.detailText = isbn.onix.CollateralDetail.TextContent[0].Text
                    self.imageUrl = isbn.summary.cover
                    self.author = isbn.summary.author
                }
                
            case .failure(let error):
                self.detailText = "見つかりませんでした"
                print("error:\(error)")
            }
        }
    }
    
    private func getUrlImage(imageUrl: String) {
        
        AF.request(imageUrl).responseImage { responseImage in
            if case .success(let uiImage) = responseImage.result {
                self.coverImage.image = uiImage
            }
        }
    }
    
    @IBAction func textClear(_ sender: Any) {
        
        isbnTextField.text = ""
    }
    
    @IBAction func goHome(_ sender: Any) {
        
        self.navigationController?.popToRootViewController(animated: true)
    }
    
    @IBAction func goBack(_ sender: Any) {
        
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func forcusSearchBar(_ sender: Any) {
        
        isbnTextField.becomeFirstResponder()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        self.view.endEditing(true)
    }
    
    @objc func keyboardWillShow(notification: NSNotification) {
        if !isbnTextField.isFirstResponder {
            return
        }
        
        if self.view.frame.origin.y == 0 {
            if let keyboardRect = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
                self.view.frame.origin.y -= keyboardRect.height
            }
        }
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        if self.view.frame.origin.y != 0 {
            self.view.frame.origin.y = 0
        }
    }
    
    private func createItem(title: String) {
        
        let cartItem = CartItem(context: context)
        cartItem.title = title
        
        do {
            try context.save()
        }
        catch {
            print("saveできませんでした")
        }
    }
}
