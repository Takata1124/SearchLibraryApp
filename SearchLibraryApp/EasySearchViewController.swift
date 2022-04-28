//
//  EasySearchViewController.swift
//  SearchLibraryApp
//
//  Created by t032fj on 2022/04/28.
//

import UIKit
import Alamofire
import AlamofireImage

class EasySearchViewController: UIViewController, UISearchBarDelegate, UICollectionViewDelegateFlowLayout, UICollectionViewDelegate, UICollectionViewDataSource {
    
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var collectionTable: UICollectionView!
    
    var pageCount: Int = 1
    var reloading: Bool = true
    var item: Item?
    
    let semaphore = DispatchSemaphore(value: 1)
    
    var collectionTableArray: [Item] = [] {
        didSet {
            collectionTable.reloadData()
        }
    }
    
    private let refreshControl = UIRefreshControl()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        searchBar.delegate = self
        collectionTable.delegate = self
        collectionTable.dataSource = self
        
        collectionTable.refreshControl = refreshControl
        
        refreshControl.addTarget(self, action: #selector(self.refresh(sender:)), for: .valueChanged)
        // Do any additional setup after loading the view.
    }
    
    @objc func refresh(sender: UIRefreshControl) {
        
        print(collectionTableArray.count)
        guard let text = searchBar.text else {
            refreshControl.endRefreshing()
            return
        }
        
        if (Double(collectionTableArray.count).truncatingRemainder(dividingBy: 30.0)) != 0 {
            refreshControl.endRefreshing()
            return
        }
        
        self.pageCount += 1
        
        getRakutenData(reloadTimes: self.pageCount, keyword: text) { result in
            
            switch result {
                
            case .success(let item):
                self.collectionTableArray += item
                
            case .failure(let error):
                print(error)
            }
        }
        
        self.reloading = true
        
        refreshControl.endRefreshing()
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let height = scrollView.frame.size.height
        let contentYoffset = scrollView.contentOffset.y
        let distanceFromBottom = scrollView.contentSize.height - contentYoffset
        if distanceFromBottom < height {
            if self.reloading {
                self.reloading = false// デリゲートは何回も呼ばれてしまうので、リロード中はfalseにしておく
                refresh(sender: self.refreshControl)
            }
        }
    }
    
    @IBAction func goHomeView(_ sender: Any) {
        self.navigationController?.popToRootViewController(animated: true)
    }

    @IBAction func goBackView(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func openKeyboard(_ sender: Any) {
        
        searchBar.becomeFirstResponder()
    }
    
    @IBAction func textClear(_ sender: Any) {
        
        self.searchBar.text = ""
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        self.view.endEditing(true)
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        
        self.pageCount = 1
        collectionTableArray = []
        self.reloading = true
        
        self.view.endEditing(true)
        
        guard let text = searchBar.text else { return }
        
        getRakutenData(reloadTimes: self.pageCount, keyword: text) { result in
            
            switch result {
                
            case .success(let item):
                self.collectionTableArray += item
                
            case .failure(let error):
                print(error)
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return collectionTableArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell: UICollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath)
        
        let imageUrl = collectionTableArray[indexPath.row].largeImageUrl
        let imageView = cell.contentView.viewWithTag(1) as! UIImageView
        makingImage(imageUrl: imageUrl) { uiImage in
            imageView.image = uiImage
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        self.item = collectionTableArray[indexPath.row]
        performSegue(withIdentifier: "goSelectBook", sender: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "goSelectBook" {
            let isbnView = segue.destination as! IsbnViewController
            isbnView.item = self.item
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let horizontalSpace: CGFloat = 5
        let cellSize: CGFloat = self.view.bounds.width/3 - horizontalSpace * 2
        let heightSize = cellSize * 4 / 3
        
        return CGSize(width: cellSize, height: heightSize)
    }
    
    private func makingImage(imageUrl: String, completion: @escaping (UIImage) -> Void) {
        
        AF.request(imageUrl).responseImage { responseImage in
            if case .success(let uiImage) = responseImage.result {
                completion(uiImage)
            }
        }
    }
    
    func getRakutenData(reloadTimes: Int, keyword: String, completion: @escaping (Result<[Item], Error>) -> Void) {
        
        let API_Key = Apikey().rakutenapikey
        var itemData = [Item]()
        let hit: Int = 30
        let page: Int = reloadTimes
        let reserch: String = keyword
        let encodeKeyword: String = reserch.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
        
        let url = "https://app.rakuten.co.jp/services/api/BooksTotal/Search/20170404?format=json&keyword=\(encodeKeyword)&booksGenreId=000&hits=\(String(hit))&page=\(String(page))&applicationId=\(API_Key)"
        
        AF.request(url).responseDecodable(of: RakutenData.self, decoder: JSONDecoder()) { response in
            
            switch response.result {
                
            case .success(let data):
                
                data.Items.forEach { item in
                    let title = item.Item.title
                    let author = item.Item.author
                    let itemCaption = item.Item.itemCaption
                    let imageUrl = item.Item.largeImageUrl
                    let isbn = item.Item.isbn
                    let salesDate = item.Item.salesDate
                    if isbn != "" {
                        itemData.append(Item(title: title, author: author, isbn: isbn, salesDate: salesDate, itemCaption: itemCaption, largeImageUrl: imageUrl))
                    }
                }
                
                completion(.success(itemData))
                
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
}
