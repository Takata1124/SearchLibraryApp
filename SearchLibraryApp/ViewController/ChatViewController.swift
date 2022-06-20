//
//  ChatViewController.swift
//  SearchLibraryApp
//
//  Created by t032fj on 2022/06/14.
//

import UIKit
import MessageKit
import InputBarAccessoryView

class ChatViewController: MessagesViewController, MessageCellDelegate {
    
    let currentUser = Sender(senderId: "self", displayName: "iOS Academy")
    let otherUser = Sender(senderId: "other", displayName: "John Smith")
    
    private var messageList: [MessageEntity] = [] {
        didSet {
            messagesCollectionView.reloadData()
            messagesCollectionView.scrollToLastItem(at: .bottom, animated: true)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "チャット"
        self.navigationItem.hidesBackButton = true

        messagesCollectionView.backgroundColor = UIColor.secondarySystemBackground
        messagesCollectionView.messagesDataSource = self
        messagesCollectionView.messagesLayoutDelegate = self
        messagesCollectionView.messagesDisplayDelegate = self
        messageInputBar.delegate = self
        
        setupButton()
        setupInputBar()
    }
    
    private func setupInputBar() {
        
        messageInputBar.inputTextView.placeholder = "入力"
        messageInputBar.inputTextView.layer.cornerRadius = 10.0
        messageInputBar.inputTextView.layer.masksToBounds = true
        messageInputBar.inputTextView.tintColor = .black
        messageInputBar.backgroundView.backgroundColor = .systemTeal
        messageInputBar.inputTextView.backgroundColor = .white
        messageInputBar.inputTextView.layer.borderColor = UIColor.black.cgColor
        messageInputBar.inputTextView.layer.borderWidth = 0.5
        messageInputBar.layer.borderWidth = 0.5
        messageInputBar.layer.borderColor = UIColor.black.cgColor
        
        let clipBarButtonItem = InputBarButtonItem()
            .configure {
                $0.image = UIImage(systemName: "arrowshape.turn.up.left")
                $0.setSize(CGSize(width: 24.0, height: 36.0), animated: false)
                $0.onTouchUpInside { _ in
                    self.navigationController?.popViewController(animated: true)
                }
            }
        
        clipBarButtonItem.tintColor = .black
        
        messageInputBar.setStackViewItems([clipBarButtonItem, .flexibleSpace], forStack: .left, animated: false)
        messageInputBar.setLeftStackViewWidthConstant(to: 45.0, animated: false)
    }
    
    private func setupButton() {
        
        messageInputBar.sendButton.title = nil
        messageInputBar.sendButton.image = UIImage(systemName: "paperplane")
        messageInputBar.sendButton.tintColor = .black
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
    
    func messageTopLabelAttributedText(for message: MessageType, at indexPath: IndexPath) -> NSAttributedString? {
        return NSAttributedString(
            string: messageList[indexPath.section].userName,
            attributes: [.font: UIFont.systemFont(ofSize: 12.0),
                         .foregroundColor: UIColor.systemBlue])
    }
    
    func messageBottomLabelAttributedText(for message: MessageType, at indexPath: IndexPath) -> NSAttributedString? {
        return NSAttributedString(
            string: messageList[indexPath.section].bottomText,
            attributes: [.font: UIFont.systemFont(ofSize: 12.0),
                         .foregroundColor: UIColor.secondaryLabel])
    }
}

extension ChatViewController: MessagesDisplayDelegate {
    func backgroundColor(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> UIColor {
        return isFromCurrentSender(message: message) ? UIColor.systemBlue : UIColor.systemBackground
    }
    
    func messageStyle(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageStyle {
        let corner: MessageStyle.TailCorner = isFromCurrentSender(message: message) ? .bottomRight : .bottomLeft
        return .bubbleTail(corner, .curved)
    }
    
    func configureAvatarView(_ avatarView: AvatarView, for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) {
        //        avatarView.setImage(url: messageList[indexPath.section].iconImageUrl)
        avatarView.set( avatar: Avatar(initials: message.sender.senderId == "0" ? "😊" : "🥳") )
    }
}

extension ChatViewController: MessagesLayoutDelegate {
    func headerViewSize(for section: Int, in messagesCollectionView: MessagesCollectionView) -> CGSize {
        return CGSize.zero
    }
    
    func messageTopLabelHeight(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> CGFloat {
        return 24
    }
    
    func messageBottomLabelHeight(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> CGFloat {
        return 24
    }
}

extension ChatViewController: InputBarAccessoryViewDelegate {
    func inputBar(_ inputBar: InputBarAccessoryView, didPressSendButtonWith text: String) {
        messageList.append(MessageEntity.new(my: text))
        messageInputBar.inputTextView.text = String()
    }
}
