//
//  CartViewController.swift
//  SearchLibraryApp
//
//  Created by t032fj on 2022/04/28.
//

import UIKit
import CoreData
import Alamofire
import AlamofireImage

class CartViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate {
    
    @IBOutlet weak var coreDataTableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var orderButton: UIButton!
    @IBOutlet weak var readButton: UIButton!
    @IBOutlet weak var starButton: UIButton!
    
    var item: Item?
    var star: Bool = false
    var read: Bool = false
    
    var isNewOrder: Bool = false {
        didSet {
            if isNewOrder {
                self.orderButton.setTitle("新しい", for: .normal)
            } else {
                self.orderButton.setTitle("古い", for: .normal)
            }
        }
    }
    
    var isRead: Bool = false {
        
        didSet {
            if isRead {
                self.readButton.setTitle("読書済", for: .normal)
            } else {
                self.readButton.setTitle("読書中", for: .normal)
            }
        }
    }
    
    var isStarFilter: Bool = false {
        didSet {
            if isStarFilter {
                self.starButton.setImage(UIImage(systemName: "star.fill"), for: .normal)
            } else {
                self.starButton.setImage(UIImage(systemName: "star"), for: .normal)
            }
        }
    }
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    private var presenter : CartPresenterInput!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "記録"
        
        searchBar.delegate = self
        
        coreDataTableView.delegate = self
        coreDataTableView.dataSource = self
        coreDataTableView.separatorInset = .zero
        coreDataTableView.separatorColor = .black
        
        coreDataTableView.register(UINib(nibName: "TableViewCell", bundle: nil), forCellReuseIdentifier: "customCell")
        
        self.navigationItem.hidesBackButton = true
        
        let tapGR: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tapGR.cancelsTouchesInView = false
        self.view.addGestureRecognizer(tapGR)
        
        self.presenter = CartPresenter(output: self, model: CartModel())
    }
    
    @objc func dismissKeyboard() {
        
        self.view.endEditing(true)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        self.coreDataTableView.reloadData()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "goDetail" {
            let isbnViewController = segue.destination as! IsbnViewController
            isbnViewController.item = self.item
            isbnViewController.isRead = self.read
            isbnViewController.isStar = self.star
            isbnViewController.isHiddenItems = true
        }
    }
    
    @IBAction func goBackView(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    private func getUrlImage(imageUrl: String, completion: @escaping(UIImage) -> Void) {
        
        AF.request(imageUrl).responseImage { responseImage in
            if case .success(let uiImage) = responseImage.result {
                completion(uiImage)
            }
        }
    }
    
    @IBAction func confirmReadButton(_ sender: Any) {
        
        presenter.didTapFilterRead(isRead: isRead)
    }
    
    @IBAction func orderButton(_ sender: Any) {
        
        presenter.didTapChangeOrder(isNewOrder: isNewOrder)
    }
    
    @IBAction func opneKeyboard(_ sender: Any) {
        
        searchBar.becomeFirstResponder()
    }
    
    @IBAction func allItemButton(_ sender: Any) {
        
        presenter.didTapReloadTable()
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        
        self.searchBar.endEditing(true)
        
        if searchBar.text != "" {
            
            presenter.didTapSearchButton(searchText: searchBar.text!)
        }
    }
    
    @IBAction func filterStar(_ sender: Any) {
        
        presenter.didTapFilterStar(isStarFiter: isStarFilter)
    }
}

extension CartViewController {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return self.presenter.numberOfItems
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "customCell", for: indexPath) as! TableViewCell
        
        getUrlImage(imageUrl:  self.presenter.item(index: indexPath.row).imageUrl ?? "") { uiImage in
            
            cell.img.image = uiImage
            cell.label.text = self.presenter.item(index: indexPath.row).title
            cell.authorLabel.text = self.presenter.item(index: indexPath.row).author
            cell.isbnLabel.text = self.presenter.item(index: indexPath.row).isbn
            cell.createdLabel.text = self.presenter.item(index: indexPath.row).createdAt?.toStringWithCurrentLocale()
            cell.isRead = self.presenter.item(index: indexPath.row).read
            cell.isStar = self.presenter.item(index: indexPath.row).star
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        coreDataTableView.deselectRow(at: indexPath, animated: true)
        
        let commit = self.presenter.item(index: indexPath.row)
        
        self.item = Item(title: commit.title ?? "", author: commit.author ?? "", isbn: commit.isbn ?? "", salesDate: commit.pubDate ?? "", itemCaption: commit.detailText ?? "", largeImageUrl: commit.imageUrl ?? "")
        self.star = commit.star
        self.read = commit.read
        
        performSegue(withIdentifier: "goDetail", sender: nil)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        return 100
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            self.presenter.didTapSelectRemoveItem(index: indexPath.row)
        }
    }
}

extension CartViewController: CartPresenterOutput {
    
    func updateTable() {
        self.coreDataTableView.reloadData()
    }
    
    func updateIsStarFilterSituation(isStarFilter: Bool) {
        self.isStarFilter = isStarFilter
    }
    
    func updateIsReadFilterSituation(isRead: Bool) {
        self.isRead = isRead
    }
    
    func updateIsOrderSituation(isNewOrder: Bool) {
        self.isNewOrder = isNewOrder
    }
}
