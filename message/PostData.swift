//
//  Postdata.swift
//  message
//
//  Created by 小西椋磨 on 2018/02/25.
//  Copyright © 2018年 ryoma.konishi. All rights reserved.
//

import Foundation

import UIKit
import Firebase
import FirebaseDatabase

class PostData: NSObject {
    var id: String?
    var text: String?
    var sender: String?
    var name: String?

    
    
    init(snapshot: DataSnapshot, myId: String) {
        self.id = snapshot.key
        
        let valueDictionary = snapshot.value as! [String: Any]
        
        self.text = valueDictionary["text"] as? String
        
        self.sender = valueDictionary["from"] as? String
        
        self.name = valueDictionary["name"] as? String


        

    }
}
