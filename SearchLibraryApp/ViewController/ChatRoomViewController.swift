//
//  ChatRoomViewController.swift
//  SearchLibraryApp
//
//  Created by t032fj on 2022/06/17.
//

import UIKit

class ChatRoomViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var chatRoomTableView: UITableView!
    
    let TODO = ["牛乳を買う", "掃除をする", "アプリ開発の勉強をする"] //追加②
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.hidesBackButton = true
        self.title = "チャットルーム"
        
        chatRoomTableView.delegate = self
        chatRoomTableView.dataSource = self
        chatRoomTableView.separatorInset = .zero
        chatRoomTableView.separatorColor = .black
        chatRoomTableView.layer.borderColor = UIColor.black.cgColor
        chatRoomTableView.layer.borderWidth = 0.5
        chatRoomTableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        
        chatRoomTableView.register(UINib(nibName: "TableViewCell", bundle: nil), forCellReuseIdentifier: "customCell")
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return TODO.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "customCell", for: indexPath) as! TableViewCell
        
        cell.label.text = TODO[indexPath.row]
        cell.authorLabel.text = TODO[indexPath.row]
        cell.isbnLabel.text = TODO[indexPath.row]
        cell.createdLabel.text = TODO[indexPath.row]
        cell.doneReadLabel.text = TODO[indexPath.row]
       
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        chatRoomTableView.deselectRow(at: indexPath, animated: true)
        
        performSegue(withIdentifier: "goChat", sender: nil)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        return 100
    }
    
    @IBAction func goBackView(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func goChat(_ sender: Any) {
        performSegue(withIdentifier: "goChat", sender: nil)
    }
}
