//
//  ChatViewController.swift
//  SearchLibraryApp
//
//  Created by t032fj on 2022/06/14.
//

import UIKit
import MessageKit
import InputBarAccessoryView

struct Sender: SenderType {
    var senderId: String
    var displayName: String
}

struct Message: MessageType {
    var sender: SenderType
    var messageId: String
    var sentDate: Date
    var kind: MessageKind
}

class ChatViewController: MessagesViewController, MessagesDataSource, MessagesLayoutDelegate, MessagesDisplayDelegate, MessageCellDelegate, InputBarAccessoryViewDelegate {

    let currrentUser = Sender(senderId: "self", displayName: "iOS Academy")
    let otherUser = Sender(senderId: "other", displayName: "John Smith")
    
    var messages = [MessageType]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        messages.append(Message(sender: currrentUser,
//                                messageId: "1",
//                                sentDate: Date().addingTimeInterval(-86400),
//                                kind: .text("hello world")))
//        
//        messages.append(Message(sender: otherUser,
//                                messageId: "2",
//                                sentDate: Date().addingTimeInterval(-66400),
//                                kind: .text("hello world")))
        
        messagesCollectionView.messagesDataSource = self
        messagesCollectionView.messagesLayoutDelegate = self
        messagesCollectionView.messagesDisplayDelegate = self
        messagesCollectionView.messageCellDelegate = self
        messageInputBar.delegate = self
        messageInputBar.sendButton.tintColor = UIColor.red
    }
    
    func inputBar(_ inputBar: InputBarAccessoryView, didPressSendButtonWith text: String) {
        
        print(text)
        
        messages.append(Message(sender: otherUser,
                                messageId: "3",
                                sentDate: Date().addingTimeInterval(-46400),
                                kind: .text("\(text)")))
        
        self.messagesCollectionView.reloadData()
    
        
        inputBar.inputTextView.text = String()
        messagesCollectionView.scrollToLastItem()
    }
    
//    func inputBar(_ inputBar: InputBarAccessoryView, didChangeIntrinsicContentTo size: CGSize) {
//        <#code#>
//    }
//
//    func inputBar(_ inputBar: InputBarAccessoryView, textViewTextDidChangeTo text: String) {
//        <#code#>
//    }
//
//    func inputBar(_ inputBar: InputBarAccessoryView, didSwipeTextViewWith gesture: UISwipeGestureRecognizer) {
//        <#code#>
//    }
    
//    func didTapBackground(in cell: MessageCollectionViewCell) {
//        <#code#>
//    }
    
    func didTapMessage(in cell: MessageCollectionViewCell) {
        print("message tap")
    }
    
//    func didTapAvatar(in cell: MessageCollectionViewCell) {
//        <#code#>
//    }
//
//    func didTapCellTopLabel(in cell: MessageCollectionViewCell) {
//        <#code#>
//    }
//
//    func didTapCellBottomLabel(in cell: MessageCollectionViewCell) {
//        <#code#>
//    }
//
//    func didTapMessageTopLabel(in cell: MessageCollectionViewCell) {
//        <#code#>
//    }
//
//    func didTapMessageBottomLabel(in cell: MessageCollectionViewCell) {
//        <#code#>
//    }
//
//    func didTapAccessoryView(in cell: MessageCollectionViewCell) {
//        <#code#>
//    }
//
//    func didTapImage(in cell: MessageCollectionViewCell) {
//        <#code#>
//    }
//
//    func didTapPlayButton(in cell: AudioMessageCell) {
//        <#code#>
//    }
//
//    func didStartAudio(in cell: AudioMessageCell) {
//        <#code#>
//    }
//
//    func didPauseAudio(in cell: AudioMessageCell) {
//        <#code#>
//    }
//
//    func didStopAudio(in cell: AudioMessageCell) {
//        <#code#>
//    }
    
    func currentSender() -> SenderType {
        return currrentUser
    }
    
    func messageForItem(at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageType {
        return messages[indexPath.row]
    }
    
    func numberOfSections(in messagesCollectionView: MessagesCollectionView) -> Int {
        return messages.count
    }
}
