//
//  ChatRoom.swift
//  SearchLibraryApp
//
//  Created by t032fj on 2022/06/26.
//

import Foundation
import Firebase
import FirebaseFirestore

class ChatRoom {
    
    let id: String
    let title: String
    let author: String
    let imageUrl: String
    let roomUser: String
    let roomUserUid: String
    var roomTitle: String
    var roomCaption: String
    var favoriteCount: Int
    let createdAt: Timestamp
    let favoriteClick: Bool
    
    init(dic: [String: Any]) {
        
        self.id = dic["id"] as? String ?? ""
        self.title = dic["title"] as? String ?? ""
        self.author = dic["author"] as? String ?? ""
        self.imageUrl = dic["imageUrl"] as? String ?? ""
        self.roomUser = dic["roomUser"] as? String ?? ""
        self.roomUserUid = dic["roomUserUid"] as? String ?? ""
        self.roomTitle = dic["roomTitle"] as? String ?? ""
        self.roomCaption = dic["roomCaption"] as? String ?? ""
        self.favoriteCount = dic["favoriteCount"] as? Int ?? 0
        self.createdAt = dic["createdAt"] as? Timestamp ?? Timestamp()
        self.favoriteClick = dic["favoriteClick"] as? Bool ?? false
    }
}
