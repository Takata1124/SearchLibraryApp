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

    private var cartItemModel: [CartItem] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "記録"
        
        searchBar.delegate = self
        
        coreDataTableView.delegate = self
        coreDataTableView.dataSource = self
        coreDataTableView.separatorInset = .zero
        coreDataTableView.separatorColor = .black
        
        coreDataTableView.register(UINib(nibName: "TableViewCell", bundle: nil), forCellReuseIdentifier: "customCell")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        fetchAllItem()
        
        coreDataTableView.reloadData()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "goDetail" {
            let isbnView = segue.destination as! IsbnViewController
            isbnView.item = self.item
            isbnView.isRead = self.read
            isbnView.isStar = self.star
            isbnView.isHiddenItems = true
        }
    }
    
    @IBAction func goBackView(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    private func fetchAllItem() {
        do {
            cartItemModel = try context.fetch(CartItem.fetchRequest())
        } catch {
            print("error")
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return cartItemModel.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "customCell", for: indexPath) as! TableViewCell
        
        getUrlImage(imageUrl: cartItemModel[indexPath.row].imageUrl ?? "") { uiImage in
            
            cell.img.image = uiImage
            cell.label.text = self.cartItemModel[indexPath.row].title
            cell.authorLabel.text = self.cartItemModel[indexPath.row].author
            cell.isbnLabel.text = self.cartItemModel[indexPath.row].isbn
            cell.createdLabel.text = self.cartItemModel[indexPath.row].createdAt?.toStringWithCurrentLocale()
            cell.isRead = self.cartItemModel[indexPath.row].read
            cell.isStar = self.cartItemModel[indexPath.row].star
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        coreDataTableView.deselectRow(at: indexPath, animated: true)
        
        let commit = cartItemModel[indexPath.row]
        
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
            
            let commit = cartItemModel[indexPath.row]
            context.delete(commit)
            
            do {
                try context.save()
            } catch {
                print("CoreDataに保存できませんでした")
            }
            
            cartItemModel.remove(at: indexPath.row)
            
            coreDataTableView.reloadData()
        }
    }
    
    private func getUrlImage(imageUrl: String, completion: @escaping(UIImage) -> Void) {
        
        AF.request(imageUrl).responseImage { responseImage in
            if case .success(let uiImage) = responseImage.result {
                completion(uiImage)
            }
        }
    }
    
    @IBAction func confirmReadButton(_ sender: Any) {
        
        let fetchRequest = NSFetchRequest<CartItem>(entityName: "CartItem")
        
        if isRead == false {
            fetchRequest.predicate = NSPredicate(format: "read = %d", true)
        } else {
            fetchRequest.predicate = NSPredicate(format: "read = %d", false)
        }
        
        do {
            cartItemModel = try context.fetch(fetchRequest)
        } catch {
            print(error)
        }
        
        isRead.toggle()
 
        coreDataTableView.reloadData()
    }
    
    @IBAction func orderButton(_ sender: Any) {
        
        let fetchRequest = NSFetchRequest<CartItem>(entityName: "CartItem")
        
        let sort: NSSortDescriptor?
        
        if isNewOrder == false {
            sort = NSSortDescriptor(key: "pubDate", ascending: true)
        } else {
            sort = NSSortDescriptor(key: "pubDate", ascending: false)
        }
        
        guard let sort = sort else {
            return
        }

        fetchRequest.sortDescriptors = [sort]
        
        do {
            cartItemModel = try context.fetch(fetchRequest)
        } catch {
            print(error)
        }
        
        isNewOrder.toggle()
 
        coreDataTableView.reloadData()
    }
    
    @IBAction func opneKeyboard(_ sender: Any) {
        
        searchBar.becomeFirstResponder()
    }
    
    @IBAction func allItemButton(_ sender: Any) {
   
        fetchAllItem()
        
        coreDataTableView.reloadData()
    }

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
 
        self.searchBar.endEditing(true)
        
        let fetchRequest = NSFetchRequest<CartItem>(entityName: "CartItem")
     
        if searchBar.text != "" {

            cartItemModel.removeAll()

            fetchRequest.predicate = NSPredicate(format:"title CONTAINS %@ || author CONTAINS %@", "\(searchBar.text!)", "\(searchBar.text!)")
     
            do {
                cartItemModel = try context.fetch(fetchRequest)
            } catch {
                print(error)
            }

            coreDataTableView.reloadData()
        }
    }
    
    @IBAction func filterStar(_ sender: Any) {
        
        let fetchRequest = NSFetchRequest<CartItem>(entityName: "CartItem")
        
        if isStarFilter == false {
            fetchRequest.predicate = NSPredicate(format: "star = %d", true)
        } else {
            fetchRequest.predicate = NSPredicate(format: "star = %d", false)
        }
        
        isStarFilter.toggle()
     
        do {
            cartItemModel = try context.fetch(fetchRequest)
        } catch {
            print(error)
        }
 
        coreDataTableView.reloadData()
    }
}
