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
    @IBOutlet weak var backViewButton: UIButton!
    @IBOutlet weak var keyButton: UIButton!
    @IBOutlet weak var searchButton: UIButton!
    @IBOutlet weak var libraryButton: UIButton!
    @IBOutlet weak var addDataButton: UIButton!
    @IBOutlet weak var readButton: UIButton!
    @IBOutlet weak var starButton: UIButton!
    @IBOutlet weak var shareButton: UIButton!
    
    var isbnInputText = ""
    var item: Item?
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    var isbn: String = "" {
        didSet {
            self.isbnLabel.text = isbn
        }
    }
    
    var pubDate: String = "" {
        didSet {
            self.pubdateLabel.text = pubDate
        }
    }
    
    var titleText: String = "" {
        didSet {
            self.titleLabel.text = titleText
            self.navigationItem.title = "\(titleText)"
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
            self.authorLabel.text = author
        }
    }
    
    var isRead: Bool = false {
        didSet {
            DispatchQueue.main.async {
                if self.isRead {
                    self.readButton.setTitle("読書済", for: .normal)
                    self.readButton.setTitleColor(.red, for: .normal)
                } else {
                    self.readButton.setTitle("読書中", for: .normal)
                    self.readButton.setTitleColor(.modeTextColor, for: .normal)
                }
            }
        }
    }
    
    var isStar: Bool = false {
        didSet {
            DispatchQueue.main.async {
                if self.isStar {
                    self.starButton.setImage(UIImage(systemName: "star.fill"), for: .normal)
                } else {
                    self.starButton.setImage(UIImage(systemName: "star"), for: .normal)
                }
            }
        }
    }
    
    var isHiddenItems: Bool = false {
        didSet {
            if isHiddenItems {
                DispatchQueue.main.async {
                    self.isbnTextField.isHidden = true
                    self.keyButton.isHidden = true
                    self.searchButton.isHidden = true
                    self.libraryButton.isHidden = true
                    self.addDataButton.isHidden = true
                    self.readButton.isHidden = false
                    self.starButton.isHidden = false
                    self.shareButton.isHidden = false
                }
            }
        }
    }
    
    private var cartItemModel: [CartItem] = []
    
    private var presenter : IsbnPresenterInput!
    private var router: IsbnRouterInput!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupLayout()
        self.presenter = IsbnPresenter(output: self, model: IsbnModel())
        self.router = IsbnRouter(viewController: self)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        self.isbnTextField.text = isbnInputText
    }
    
    private func setupLayout() {
        
        isbnTextField.placeholder = "isbn"
        isbnTextField.keyboardType = .numberPad
        isbnTextField.delegate = self
        isbnTextField.layer.borderColor = UIColor.black.cgColor
        isbnTextField.layer.borderWidth = 0.5
        
        readButton.isHidden = true
        starButton.isHidden = true
        shareButton.isHidden = true
        
        self.navigationItem.hidesBackButton = true
        
        self.titleText = item?.title ?? ""
        self.author = item?.author ?? ""
        self.isbn = item?.isbn ?? ""
        self.pubDate = item?.salesDate ?? ""
        self.detailText = item?.itemCaption ?? ""
        self.imageUrl = item?.largeImageUrl ?? ""
    }
    
    @IBAction func searchBook(_ sender: Any) {
        
        self.titleText = ""
        self.author = ""
        self.isbn = ""
        self.pubDate = ""
        self.detailText = ""
        self.coverImage.image = nil
        self.item = nil
        
        self.view.endEditing(true)
        
        if let isbn = isbnTextField.text {
            presenter.didGetSearchBookData(isbn: isbn)
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

    @IBAction func goBack(_ sender: Any) {
        
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func forcusSearchBar(_ sender: Any) {
        
        isbnTextField.becomeFirstResponder()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        self.view.endEditing(true)
    }
    
    @IBAction func addAction(_ sender: Any) {
        
        let alert = UIAlertController(title: "本の登録", message: "この本を登録しますか？", preferredStyle: .alert)
        
        let addActionAlert: UIAlertAction = UIAlertAction(title: "はい", style: .default, handler: { _ in
            self.presenter.didAddStoredItem(title: self.titleText, author: self.author, imageUrl: self.imageUrl, isbn: self.isbn, pubDate: self.pubDate, detailText: self.detailText)
        })

        let notAddActionAlert: UIAlertAction = UIAlertAction(title: "いいえ", style: .default, handler: { _ in
            alert.dismiss(animated: false, completion: nil)
        })
        
        alert.addAction(addActionAlert)
        alert.addAction(notAddActionAlert)
        
        alert.view.tintColor = UIColor.modeTextColor
        
        present(alert, animated: true)
    }
    
    @IBAction func goBookView(_ sender: Any) {
        if self.titleText != "" {
            router.transionGoBookView()
        }
    }
    
    @IBAction func goBackHomeView(_ sender: Any) {
        self.navigationController?.popToRootViewController(animated: true)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "goBook" {
            let selectBookViewController = segue.destination as! SelectBookViewController
            selectBookViewController.item = self.item
            selectBookViewController.uiImage = self.coverImage.image
        }
    }
    
    @IBAction func readAction(_ sender: Any) {
        
        presenter.didTapReverseRead(text: self.titleText)
    }
    
    @IBAction func reverseStar(_ sender: Any) {
        
        presenter.didTapReverseStar(text: self.titleText)
    }
    
    @IBAction func shareAction(_ sender: Any) {
        
        let shareText = "\(self.titleText)"
        let shareAuthor = "\(self.author)"
        let shareIsbn = "\(self.isbn)"
        let shareDetailText = "\(self.detailText)"
        let shareWebsite = NSURL(string: "\(self.imageUrl)")
        
        let activityItems = [shareText, shareAuthor, shareIsbn, shareDetailText, shareWebsite as Any] as [Any]
        
        // 初期化処理
        let activityVC = UIActivityViewController(activityItems: activityItems, applicationActivities: nil)
        
        // 使用しないアクティビティタイプ
        let excludedActivityTypes = [
            UIActivity.ActivityType.postToFacebook,
            UIActivity.ActivityType.postToTwitter,
            UIActivity.ActivityType.message,
            UIActivity.ActivityType.saveToCameraRoll,
            UIActivity.ActivityType.print
        ]
        
        activityVC.excludedActivityTypes = excludedActivityTypes
      
        self.present(activityVC, animated: true, completion: nil)
    }
}

extension IsbnViewController: IsbnPresenterOutput {

    func updateStarItem(isStar: Bool) {
        self.isStar = isStar
    }
    
    func updateReadItem(isRead: Bool) {
        self.isRead = isRead
    }
    
    func updateBookItem(item: Item) {
        
        self.isbn = item.isbn
        self.titleText = item.title
        self.pubDate = item.salesDate
        self.detailText = item.itemCaption
        self.imageUrl = item.largeImageUrl
        self.author = item.author
    }
    
    func updateDetailText() {
        self.detailText = "見つかりませんでした"
    }
}
