//
//  Type.swift
//  SearchLibraryApp
//
//  Created by t032fj on 2022/06/18.
//

import Foundation
import MessageKit

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

struct MessageSenderType: SenderType {
    
    var senderId: String
    var displayName: String

    static var me: MessageSenderType {
        return MessageSenderType(senderId: "0",
                              displayName: "me")
    }

    static var other: MessageSenderType {
        return MessageSenderType(senderId: "1",
                              displayName: "other")
    }
}

struct MessageEntity: MessageType {
    
    var userId: Int
    var userName: String
    var iconImageUrl: URL?
    var message: String
    var messageId: String
    var sentDate: Date

    var kind: MessageKind {
        return .attributedText(NSAttributedString(
            string: message,
            attributes: [.font: UIFont.systemFont(ofSize: 14.0),
                         .foregroundColor: isMe
                            ? UIColor.white
                            : UIColor.label]
        ))
    }

    var sender: SenderType {
        return isMe ? MessageSenderType.me : MessageSenderType.other
    }

    var isMe: Bool {
        userId == 0
    }

    var bottomText: String {
        return sentDate.toStringWithCurrentLocale()
    }

    static func new(my message: String,
                    date: Date = Date(),
                    isMarkAsRead: Bool = false) -> MessageEntity {
        return MessageEntity(
            userId: 0,
            userName: "自分",
            iconImageUrl: myIconImageUrl,
            message: message,
            messageId: UUID().uuidString,
            sentDate: date)
    }

    static func new(other message: String,
                    date: Date = Date()) -> MessageEntity {
        return MessageEntity(
            userId: 1,
            userName: "相手",
            iconImageUrl: otherIconImageUrl,
            message: message,
            messageId: UUID().uuidString,
            sentDate: date)
    }

    static var myIconImageUrl: URL = URL(string: "xxx")!
    static var otherIconImageUrl: URL = URL(string: "xxx")!

    static var mockMessages: [MessageEntity] {
        return []
    }
}
