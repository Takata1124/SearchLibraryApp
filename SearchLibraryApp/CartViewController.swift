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

class CartViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    private var cartItemModel: [CartItem] = [] {
        didSet{
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorInset = .zero
        tableView.separatorColor = .black
        
        tableView.register(UINib(nibName: "TableViewCell", bundle: nil), forCellReuseIdentifier: "customCell")
        
        fetchAllItem()
    }
    
    @IBAction func goBackView(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    private func fetchAllItem() {
        do {
            cartItemModel = try context.fetch(CartItem.fetchRequest())
        } catch {
            
        }
    }
    
    private func allDeleteItem() {
        
    }
    
    private func selectDeleteItem(item: CartItem) {
        
        context.delete(item)
        
        do {
            try context.save()
        } catch {
            
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return cartItemModel.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "customCell", for: indexPath) as! TableViewCell
        cell.label.text = cartItemModel[indexPath.row].title
        cell.authorLabel.text = cartItemModel[indexPath.row].author
        cell.isbnLabel.text = cartItemModel[indexPath.row].isbn
        getUrlImage(imageUrl: cartItemModel[indexPath.row].imageUrl ?? "") { uiImage in
            cell.img.image = uiImage
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        print(indexPath.row)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let commit = cartItemModel[indexPath.row]
            context.delete(commit)
            cartItemModel.remove(at: indexPath.row)
            
            do {
                try context.save()
            } catch {
                
            }
        }
    }
    
    private func getUrlImage(imageUrl: String, completion: @escaping(UIImage) -> Void) {
        
        AF.request(imageUrl).responseImage { responseImage in
            if case .success(let uiImage) = responseImage.result {
                completion(uiImage)
            }
        }
    }
}
