//
//  ChatRoomViewController.swift
//  SearchLibraryApp
//
//  Created by t032fj on 2022/06/17.
//

import UIKit
import Firebase
import Alamofire
import AlamofireImage

class ChatRoomViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
 
    @IBOutlet weak var segmentControl: UISegmentedControl!
    @IBOutlet weak var chatRoomTableView: UITableView!
    
    var chatRooms: [ChatRoom] = [] {
        didSet {
            chatRoomTableView.reloadData()
        }
    }
    
    var roomId: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.hidesBackButton = true
        self.title = "チャットルーム"
        
        chatRoomTableView.delegate = self
        chatRoomTableView.dataSource = self
        chatRoomTableView.separatorInset = .zero
        chatRoomTableView.separatorColor = .modeTextColor
        chatRoomTableView.layer.borderColor = UIColor.modeTextColor.cgColor
        chatRoomTableView.layer.borderWidth = 0.5
        chatRoomTableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        
        chatRoomTableView.register(UINib(nibName: "TableViewCell", bundle: nil), forCellReuseIdentifier: "customCell")
        
        segmentControl.selectedSegmentTintColor = UIColor.systemTeal
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        setupData()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "goCart" {
            let cartViewController = segue.destination as! CartViewController
            cartViewController.isMakeRoom = true
        }
        
        if segue.identifier == "goChat" {
            let chatViewController = segue.destination as! ChatViewController
            chatViewController.roomId = roomId
        }
    }
    
    private func setupData() {
        
        Firestore.firestore().collection("chatRoom")
            .order(by: "title", descending: false)
            .getDocuments { documents, err in
                
                if let err = err {
                    print("err")
                }
                
                documents?.documents.forEach({ document in
                    
                    let dic = document.data()
                    let chatroom = ChatRoom(dic: dic)
                    if !self.chatRooms.contains(where: { room in
                        room.id == chatroom.id
                    }){
                        self.chatRooms.append(chatroom)
                    }
                })
            }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return chatRooms.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "customCell", for: indexPath) as! TableViewCell
        let imageUrl = chatRooms[indexPath.row].imageUrl
        let createdDate:String = String(chatRooms[indexPath.row].createdAt.dateValue().toStringWithCurrentLocale().prefix(10))
        
        getUrlImage(imageUrl: imageUrl) { uiImage in
            
            cell.img.image = uiImage
            cell.label.text =  self.chatRooms[indexPath.row].title
            cell.authorLabel.text = self.chatRooms[indexPath.row].author
            cell.isbnLabel.text = self.chatRooms[indexPath.row].roomTitle
            cell.createdLabel.text = createdDate
            cell.doneReadLabel.text = String(self.chatRooms[indexPath.row].favoriteCount)
        }
        
        return cell
    }
    
    private func getUrlImage(imageUrl: String, completion: @escaping(UIImage) -> Void) {
        
        AF.request(imageUrl).responseImage { responseImage in
            if case .success(let uiImage) = responseImage.result {
                completion(uiImage)
            }
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        chatRoomTableView.deselectRow(at: indexPath, animated: true)
        roomId = chatRooms[indexPath.row].id
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
    
    @IBAction func goCartView(_ sender: Any) {
        performSegue(withIdentifier: "goCart", sender: nil)
    }
    
    @IBAction func ValueChanged(_ sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case 0:
            print("新着")
        case 1:
            print("人気")
        case 2:
            print("マイルーム")
        default:
            print("存在しない番号")
        }
    }
}
