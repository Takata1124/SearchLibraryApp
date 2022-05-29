//
//  SelectBookViewController.swift
//  SearchLibraryApp
//
//  Created by t032fj on 2022/04/28.
//

import UIKit
import Alamofire
import SwiftyJSON
import PKHUD

class SelectBookViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    let appDelegate: AppDelegate = UIApplication.shared.delegate as! AppDelegate
    
    var uiImage: UIImage?
    var item: Item?
    var articleUrl: String = ""
    var webTitle: String = ""
    var latitude: String = ""
    var longitude: String = ""
    
    var resultArray: [String] = [] {
        didSet {
            if resultArray.count == appDelegate.totalArray.count && resultArray.contains("検索中") {
                resultArray = []
                libraryTableView.reloadData()
            }
            
            if resultArray.count == appDelegate.totalArray.count && !resultArray.contains("検索中") {
                HUD.hide()
            }
        }
    }
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var authorLabel: UILabel!
    @IBOutlet weak var isbnLabel: UILabel!
    @IBOutlet weak var pubdateLabel: UILabel!
    @IBOutlet weak var coverImage: UIImageView!
    @IBOutlet weak var libraryTableView: UITableView!
    
    private var presenter : SelectBookPresenterInput!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.presenter = SelectBookPresenter(output: self, model: SelectBookModel())
        
        libraryTableView.delegate = self
        libraryTableView.dataSource = self
        libraryTableView.separatorInset = .zero
        libraryTableView.separatorColor = UIColor.black
        
        libraryTableView.register(UINib(nibName: "BookTableViewCell", bundle: nil), forCellReuseIdentifier: "bookCell")
        
        NotificationCenter.default.addObserver(forName: .notifyWeb, object: nil, queue: nil) { notification in
            
            guard let url = notification.userInfo?["url"] else { return }
            guard let webTitle = notification.userInfo?["webTitle"] else { return }
            self.articleUrl = url as! String
            self.webTitle = webTitle as! String
            
            self.performSegue(withIdentifier: "goWeb", sender: nil)
        }
        
        NotificationCenter.default.addObserver(forName: .notifyMap, object: nil, queue: nil) { notification in
            
            guard let latitude = notification.userInfo?["latitude"] else { return }
            guard let longitude = notification.userInfo?["longitude"] else { return }

            self.latitude = latitude as! String
            self.longitude = longitude as! String
            
            self.performSegue(withIdentifier: "goLocation", sender: nil)
        }
        
        if appDelegate.totalArray.count != 0 {
            HUD.show(.progress, onView: self.view)
        } else {
            setupAlert()
        }
    }
    
    override func viewDidLayoutSubviews() {
        
        setupLayout()
    }
    
    private func setupLayout() {
        
        self.titleLabel.text = item?.title
        self.authorLabel.text = item?.author
        self.isbnLabel.text = item?.isbn
        self.pubdateLabel.text = item?.salesDate
        self.coverImage.image = self.uiImage
        
        self.navigationItem.hidesBackButton = true
    }
    
    private func setupAlert() {
        
        let alert = UIAlertController(title: "位置情報が許可されていません", message: "位置情報を設定しますか？", preferredStyle: .alert)
        
        let addOkAlert: UIAlertAction = UIAlertAction(title: "はい", style: .default, handler: { _ in
            
            alert.dismiss(animated: false, completion: nil)
            if let url = URL(string: UIApplication.openSettingsURLString), UIApplication.shared.canOpenURL(url) {
               UIApplication.shared.open(url, options: [:], completionHandler: nil)
            }
            
            self.navigationController?.popViewController(animated: true)
        })
        
        let addNgAlert: UIAlertAction = UIAlertAction(title: "いいえ", style: .default, handler: { _ in
            
            alert.dismiss(animated: false, completion: nil)
            self.navigationController?.popViewController(animated: true)
        })

        alert.addAction(addOkAlert)
        alert.addAction(addNgAlert)
        
        present(alert, animated: true)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return appDelegate.totalArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "bookCell", for: indexPath) as! BookTableViewCell
        
        let name = appDelegate.totalArray[indexPath.row].name
        let systemId = appDelegate.totalArray[indexPath.row].systemId
        let url = appDelegate.totalArray[indexPath.row].pcUrl
        let latitude = appDelegate.totalArray[indexPath.row].latitude
        let longitude = appDelegate.totalArray[indexPath.row].longitude
        let webTitle = appDelegate.totalArray[indexPath.row].name
        
        presenter.searchBook(isbn: self.isbnLabel.text ?? "", systemId: systemId) { text in
            self.resultArray.append(text)
            cell.borrowSituation = text
            cell.libraryName.text = name
            cell.articleUrl = url
            cell.latitude = latitude
            cell.longitude = longitude
            cell.webTitle = webTitle
        }
    
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        return 75
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        libraryTableView.deselectRow(at: indexPath, animated: true)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "goWeb" {
            let webViewController = segue.destination as! WebViewController
            webViewController.articleUrl = self.articleUrl
            webViewController.webTitle = self.webTitle
        }
        
        if segue.identifier == "goLocation" {
            let mapViewController = segue.destination as! MapViewController
            mapViewController.latitude = self.latitude
            mapViewController.longitude = self.longitude
        }
    }
    
    @IBAction func goBackView(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
}

extension SelectBookViewController: SelectBookPresenterOutput {
    
}
