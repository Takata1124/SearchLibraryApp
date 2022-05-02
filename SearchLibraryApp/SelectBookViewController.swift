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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        libraryTableView.delegate = self
        libraryTableView.dataSource = self
        libraryTableView.separatorInset = .zero
        libraryTableView.layer.borderColor = UIColor.black.cgColor
        libraryTableView.layer.borderWidth = 0.5
        
        libraryTableView.register(UINib(nibName: "BookTableViewCell", bundle: nil), forCellReuseIdentifier: "bookCell")
        
        NotificationCenter.default.addObserver(forName: .notifyWeb, object: nil, queue: nil) { notification in
            
            guard let url = notification.userInfo?["url"] else { return }
            self.articleUrl = url as! String
            self.performSegue(withIdentifier: "goWeb", sender: nil)
        }
        
        NotificationCenter.default.addObserver(forName: .notifyMap, object: nil, queue: nil) { notification in
            
            guard let latitude = notification.userInfo?["latitude"] else { return }
            guard let longitude = notification.userInfo?["longitude"] else { return }

            self.latitude = latitude as! String
            self.longitude = longitude as! String
            
            self.performSegue(withIdentifier: "goLocation", sender: nil)
        }
        
        HUD.show(.progress, onView: self.view)
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
    }
    
    private func searchBooks(isbn: String, systemId: String, completion: @escaping(String) -> Void) {
        
        let api_key = Apikey().libraryApikey
        
        let url = "https://api.calil.jp/check?appkey=\(api_key)&isbn=\(isbn)&systemid=\(systemId)&callback=no&format=json"
        
        AF.request(url).responseJSON { response in
            
            guard let data = response.data else {
                completion("蔵書なし")
                return
            }
            
            do {
                let json = try JSON(data: data)
                
                guard let conTinue = json["continue"].int else {
                    completion("蔵書なし")
                    return
                }
                
                if conTinue == 0 {
                    
                    guard let situation = json["books"]["\(isbn)"]["\(systemId)"]["libkey"].dictionary else {
                        completion("蔵書なし")
                        return
                    }
                    
                    if let key = situation.keys.first {
                        
                        guard let borrow = situation[key] else {
                            completion("蔵書なし")
                            return
                        }
                        
                        let result = borrow.rawValue as! String
                        completion(result)
                    }
                    else {
                        completion("蔵書なし")
                    }
                } else {
                    completion("検索中")
                }
            } catch {
                completion("検出不可")
            }
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return appDelegate.totalArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "bookCell", for: indexPath) as! BookTableViewCell
        
        let name = appDelegate.totalArray[indexPath.row].name
        let systemId = appDelegate.totalArray[indexPath.row].systemId
        let url = appDelegate.totalArray[indexPath.row].url_pc
        let latitude = appDelegate.totalArray[indexPath.row].latitude
        let longitude = appDelegate.totalArray[indexPath.row].longitude
        
        searchBooks(isbn: self.isbnLabel.text ?? "", systemId: systemId) { text in
            self.resultArray.append(text)
            cell.borrowSituation = text
        }
        
        cell.libraryName.text = name
        cell.articleUrl = url
        cell.latitude = latitude
        cell.longitude = longitude
        
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
    
//    @objc func doOpenMapView(_ notification: Notification) {
//
//        performSegue(withIdentifier: "goLocation", sender: nil)
//    }
}
