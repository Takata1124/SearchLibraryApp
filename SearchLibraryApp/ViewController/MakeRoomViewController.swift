//
//  MakeRoomViewController.swift
//  SearchLibraryApp
//
//  Created by t032fj on 2022/06/26.
//

import UIKit
import Alamofire
import AlamofireImage
import Firebase
import PKHUD

class MakeRoomViewController: UIViewController, UITextFieldDelegate {
    
    var item: Item?
    
    @IBOutlet weak var bookImageView: UIImageView!
    @IBOutlet weak var titleText: UITextField!
    @IBOutlet weak var captionText: UITextField!
    @IBOutlet weak var makeRoomButton: UIButton!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var authorLabel: UILabel!
    @IBOutlet weak var isbnLabel: UILabel!
    @IBOutlet weak var salesDateLabel: UILabel!
    
    private var _activeTextField: UITextField? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupLayout()
        
        titleText.delegate = self
        captionText.delegate = self
    }
    
    private func setupLayout() {
        
        titleText.layer.borderColor = UIColor.modeTextColor.cgColor
        titleText.layer.borderWidth = 0.5
        captionText.layer.borderColor = UIColor.modeTextColor.cgColor
        captionText.layer.borderWidth = 0.5
    }
    
    override func viewDidLayoutSubviews() {
        
        if let item = item {
            self.titleLabel.text = item.title
            self.authorLabel.text = item.author
            self.isbnLabel.text = item.isbn
            self.salesDateLabel.text = item.salesDate
            getUrlImage(imageUrl: item.largeImageUrl)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // キーボード開閉のタイミングを取得
        let notification = NotificationCenter.default
        notification.addObserver(self, selector: #selector(self.keyboardWillShow(_:)),
                                 name: UIResponder.keyboardWillShowNotification,
                                 object: nil)
        notification.addObserver(self, selector: #selector(self.keyboardWillHide(_:)),
                                 name: UIResponder.keyboardWillHideNotification,
                                 object: nil)
    }
    
    @objc func keyboardWillShow(_ notification: Notification) {
        // 編集中のtextFieldを取得
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            if self.view.frame.origin.y == 0 {
                self.view.frame.origin.y -= keyboardSize.height
            } else {
                let suggestionHeight = self.view.frame.origin.y + keyboardSize.height
                self.view.frame.origin.y -= suggestionHeight
            }
        }
    }
    
    @objc func keyboardWillHide(_ notification: Notification) {
        if self.view.frame.origin.y != 0 {
            self.view.frame.origin.y = 0
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    
    private func getUrlImage(imageUrl: String) {
        AF.request(imageUrl).responseImage { responseImage in
            if case .success(let uiImage) = responseImage.result {
                self.bookImageView.image = uiImage
            }
        }
    }
    
    @IBAction func goBackView(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    @IBAction func makeRoom(_ sender: Any) {
        
        guard let titleText = titleText.text else { return }
        guard let roomCaption = captionText.text else { return }
        
        HUD.show(.progress, onView: self.view)
    
        if let uid = Auth.auth().currentUser?.uid {
            
            if let item = item {
                
                let data = [
                    "id": UUID().uuidString,
                    "title": item.title,
                    "author": item.author,
                    "imageUrl": item.largeImageUrl,
                    "roomUser": "takashi",
                    "roomUserUid": uid,
                    "roomTitle": titleText,
                    "roomCaption": roomCaption,
                    "favoriteCount": 0,
                    "createdAt": Timestamp(),
                    "favoriteClick": false,
                ] as [String : Any]
                
                let uniqueId: String = UUID().uuidString
                
                Firestore.firestore().collection("chatRoom").document(uniqueId).setData(data) { error in
                    if let error = error {
                        print(error.localizedDescription)
                        return
                    }
                    
                    print("success")
                    HUD.hide()
                    self.navigationController?.popToViewController(self.navigationController!.viewControllers[2], animated: true)
                }
            } else {
                
                print("fail")
                HUD.hide()
            }
        }
    }
}
