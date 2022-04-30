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
    
    var resultArray: [String] = [] {
        didSet {
            if resultArray.count == appDelegate.totalArray.count && resultArray.contains("検索中") {
                resultArray = []
                tableView.reloadData()
            }
            
            if resultArray.count == appDelegate.totalArray.count && !resultArray.contains("検索中") {
                print("完了しました")
                HUD.hide()
            }
        }
    }
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var authorLabel: UILabel!
    @IBOutlet weak var isbnLabel: UILabel!
    @IBOutlet weak var pubdateLabel: UILabel!
    @IBOutlet weak var coverImage: UIImageView!
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorInset = .zero
//        tableView.separatorColor = .black
        tableView.layer.borderColor = UIColor.black.cgColor
        tableView.layer.borderWidth = 0.5
        
        tableView.register(UINib(nibName: "BookTableViewCell", bundle: nil), forCellReuseIdentifier: "bookCell")
        
        HUD.show(.progress, onView: self.view)
        
        print(appDelegate.totalArray)
        print(appDelegate.totalArray.count)
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
                
//                print(json)

                guard let conTinue = json["continue"].int else {
                    completion("蔵書なし")
                    return
                }
                print(conTinue)
                
                if conTinue == 0 {
                    
                    guard let situation = json["books"]["\(isbn)"]["\(systemId)"]["libkey"].dictionary else {
                        completion("蔵書なし")
                        return
                    }
                    
                    print(situation)
                    print(situation.description.components(separatedBy: ","))
                    print(situation.count)
                    
                    if let key = situation.keys.first {
                        
                        
                        
                        guard let borrow = situation[key] else {
                            completion("蔵書なし")
                            return
                        }
                        
                        let result = borrow.rawValue as! String
                        completion(result)
                        
                    } else {
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
        
//        print(indexPath.row)
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "bookCell", for: indexPath) as! BookTableViewCell
        
        let name = appDelegate.totalArray[indexPath.row].name
        let systemId = appDelegate.totalArray[indexPath.row].systemId
//        print(systemId)
    
        searchBooks(isbn: self.isbnLabel.text ?? "", systemId: systemId) { text in
            print(text)
            self.resultArray.append(text)
//            cell.borrowLabel.text = text
            cell.borrowSituation = text
        }
        
        cell.libraryName.text = name
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        return 75
    }
    
    @IBAction func goBackView(_ sender: Any) {
        
        self.navigationController?.popViewController(animated: true)
    }
    
}
