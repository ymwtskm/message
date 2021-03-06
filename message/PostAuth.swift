//
//  PostAuth.swift
//  message
//
//  Created by 小西椋磨 on 2018/02/28.
//  Copyright © 2018年 ryoma.konishi. All rights reserved.
//

import Foundation
import UIKit
import Firebase
import FirebaseDatabase

class PostAuth: NSObject {
    var id: String?
    var receiver: String?
    var icon: String?
    var displayName: String?
    var userId: String?
    var followers: [String] = []
    var follows: [String] = []
    var tags: [String] = []
    var token: String?

    init(snapshot: DataSnapshot, myId: String) {
        self.id = snapshot.key
        
        let valueDictionary = snapshot.value as! [String: Any]
        
        self.receiver = valueDictionary["to"] as? String
        
        self.icon = valueDictionary["icon"] as? String
        
        self.displayName = valueDictionary["displayName"] as? String
        
        self.userId = valueDictionary["userId"] as? String
        
        self.token = valueDictionary["token"] as? String

        
        if let followers = valueDictionary["followers"] as? [String] {
            self.followers = followers
        }
        if let follows = valueDictionary["follows"] as? [String] {
            self.follows = follows
        }
        if let tags = valueDictionary["tags"] as? [String] {
            self.tags = tags
        }


        
    }
}
