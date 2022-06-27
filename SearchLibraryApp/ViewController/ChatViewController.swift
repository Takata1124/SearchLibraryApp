//
//  ChatViewController.swift
//  SearchLibraryApp
//
//  Created by t032fj on 2022/06/14.
//

import UIKit
import MessageKit
import InputBarAccessoryView
import FirebaseCore
import FirebaseFirestore
import FirebaseAuth
import FirebaseDatabase
import Alamofire
import AlamofireImage

class ChatViewController: MessagesViewController, MessageCellDelegate {
    
    let currentUser = Sender(senderId: "self", displayName: "iOS Academy")
    let otherUser = Sender(senderId: "other", displayName: "John Smith")
    
    private var messageList: [MessageEntity] = [] {
        didSet {
            self.messagesCollectionView.reloadData()
            self.messagesCollectionView.scrollToLastItem(at: .bottom, animated: true)
        }
    }
    
    var roomId: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "チャット"
        self.navigationItem.hidesBackButton = true
        
        messagesCollectionView.backgroundColor = UIColor.secondarySystemBackground
        messagesCollectionView.messagesDataSource = self
        messagesCollectionView.messagesLayoutDelegate = self
        messagesCollectionView.messagesDisplayDelegate = self
        messagesCollectionView.messageCellDelegate = self
        messageInputBar.delegate = self
        
        setupButton()
        setupInputBar()
   
        fetchData()
    }
    
    private func setupInputBar() {
        
        messageInputBar.inputTextView.placeholder = "ここにテキストを入力してください"
        messageInputBar.backgroundView.backgroundColor = .systemTeal
        messageInputBar.inputTextView.backgroundColor = UIColor.secondarySystemBackground
        
        let clipBarButtonItem = InputBarButtonItem()
            .configure {
                $0.image = UIImage(systemName: "chevron.backward")
                $0.setSize(CGSize(width: 24.0, height: 36.0), animated: false)
                $0.onTouchUpInside { _ in
                    self.navigationController?.popViewController(animated: true)
                }
            }
        
        clipBarButtonItem.tintColor = .black
        
        messageInputBar.setStackViewItems([clipBarButtonItem, .flexibleSpace], forStack: .left, animated: false)
        messageInputBar.setLeftStackViewWidthConstant(to: 40.0, animated: false)
    }
    
    private func setupButton() {
        
        messageInputBar.sendButton.title = nil
        messageInputBar.sendButton.image = UIImage(systemName: "paperplane")
        messageInputBar.sendButton.tintColor = .black
    }
    
    @IBAction func goBackView(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    private func fetchData() {
        
        Database.database().reference().child(roomId).observe(.childAdded) { snapShot in
            if let snapShotData = snapShot.value {
                
                guard let userUid = (snapShotData as AnyObject).value(forKeyPath: "userUid") else { return }
                guard let message = (snapShotData as AnyObject).value(forKeyPath: "message") else { return }
                guard let date = (snapShotData as AnyObject).value(forKeyPath: "date") else { return }
                guard let imageUrl = (snapShotData as AnyObject).value(forKeyPath: "imageUrl") else { return }
                
                let df = DateFormatter()
                df.dateFormat = "yyyy-MM-dd HH:mm:ss"
                df.locale = Locale(identifier: "en_US_POSIX")
                df.timeZone = TimeZone(identifier: "Asia/Tokyo")
                let dfDate = df.date(from: date as! String)

                if userUid as! String == Auth.auth().currentUser!.uid {
                    self.messageList.append(MessageEntity.new(my: message as! String, date: dfDate!, imageUrl: imageUrl as! String))
                } else {
                    self.messageList.append(MessageEntity.new(other: message as! String, imageUrl: imageUrl as! String, date: dfDate!))
                }
            }
        }
    }
}

extension ChatViewController: MessagesDataSource {
    func currentSender() -> SenderType {
        return MessageSenderType.me
    }
    
    func otherSender() -> SenderType {
        return MessageSenderType.other
    }
    
    func numberOfSections(in messagesCollectionView: MessagesCollectionView) -> Int {
        return messageList.count
    }
    
    func messageForItem(at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageType {
        return messageList[indexPath.section]
    }
    
    func cellTopLabelAttributedText(
        for message: MessageType,
        at indexPath: IndexPath
    ) -> NSAttributedString? {
        let text = messageList[indexPath.section].sentDate.toStringWithCurrentLocale().prefix(10)
        return NSAttributedString(
            string: String((text == Date().toStringWithCurrentLocale().prefix(10)) ? "今日" : text),
            attributes: [.font: UIFont.systemFont(ofSize: 12.0),
                         .foregroundColor: UIColor.darkGray
                        ])
    }
    
    func messageBottomLabelAttributedText(for message: MessageType, at indexPath: IndexPath) -> NSAttributedString? {
        
        let str = messageList[indexPath.section].sentDate.toStringWithCurrentLocale()
        let middleStr: String = String(str[str.index(str.startIndex, offsetBy: 10)...str.index(str.startIndex, offsetBy: 15)])
        
        return NSAttributedString(
            string: middleStr,
            attributes: [.font: UIFont.systemFont(ofSize: 12.0),
                         .foregroundColor: UIColor.secondaryLabel])
    }
}

extension ChatViewController: MessagesDisplayDelegate {
    
    func backgroundColor(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> UIColor {
        return isFromCurrentSender(message: message) ? UIColor.systemTeal : UIColor.systemBackground
    }
    
    func messageStyle(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageStyle {
        let corner: MessageStyle.TailCorner = isFromCurrentSender(message: message) ? .bottomRight : .bottomLeft
        return .bubbleTail(corner, .curved)
    }
    
    func configureAvatarView(_ avatarView: AvatarView, for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) {
        
        let imageUrl = messageList[indexPath.section].imageUrl
  
        getUrlImage(imageUrl: imageUrl) { uiImage in
            if message.sender.senderId == "0" {
                avatarView.set(avatar: Avatar(image: uiImage))
            } else {
                avatarView.set(avatar: Avatar(image: uiImage))
            }
        }

//        avatarView.set( avatar: Avatar(initials: message.sender.senderId == "0" ? "😊" : "🥳") )
    }
    
    private func getUrlImage(imageUrl: String, completion: @escaping(UIImage) -> Void) {
        
        AF.request(imageUrl).responseImage { responseImage in
            if case .success(let uiImage) = responseImage.result {
                completion(uiImage)
            }
        }
    }
}

extension ChatViewController: MessagesLayoutDelegate {
    
    func cellTopLabelHeight(
        for message: MessageType,
        at indexPath: IndexPath,
        in messagesCollectionView: MessagesCollectionView
    ) -> CGFloat {
        let message = messageList[indexPath.section]
        let firstDate = messageList
            .filter { $0.sentDate.toStringWithCurrentLocale().prefix(10) == message.sentDate.toStringWithCurrentLocale().prefix(10) }
            .first
        return message.messageId.prefix(10) == firstDate?.messageId.prefix(10)
        ? 40
        : CGFloat.zero
    }
    
    func headerViewSize(for section: Int, in messagesCollectionView: MessagesCollectionView) -> CGSize {
        return CGSize.zero
    }
    
    func messageTopLabelHeight(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> CGFloat {
        return 10
    }
    
    func messageBottomLabelHeight(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> CGFloat {
        return 20
    }
}

extension ChatViewController: InputBarAccessoryViewDelegate {
    
    func inputBar(_ inputBar: InputBarAccessoryView, didPressSendButtonWith text: String) {
//        messageList.append(MessageEntity.new(my: text))
        //        messageList.append(MessageEntity.new(other: text))
        saveChatData(message: text)
        messageInputBar.inputTextView.text = String()
    }
    
    private func saveChatData(message: String) {
        
        let userUid = Auth.auth().currentUser?.uid
        let date = Date().toStringWithCurrentLocale()
        let messageData = ["userUid": userUid, "message": message,  "date": date, "imageUrl": "https://www.eternalcollegest.com/wp-content/uploads/2020/04/gorira-3-44.jpg"]
        Database.database().reference().child(roomId).child("\(date)").setValue(messageData)
    }
}
