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
    
    init(snapshot: DataSnapshot, myId: String) {
        self.id = snapshot.key
        
        let valueDictionary = snapshot.value as! [String: Any]
        
        self.receiver = valueDictionary["to"] as? String
        
        self.icon = valueDictionary["image"] as? String
        
        
    }
}
