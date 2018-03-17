//
//  AddViewController.swift
//  message
//
//  Created by 小西椋磨 on 2018/03/17.
//  Copyright © 2018年 ryoma.konishi. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth
import SVProgressHUD
import JSQMessagesViewController
import FirebaseDatabase
import FirebaseStorage

class AddViewController: UIViewController {
    
    //アイコン設定
    var friendIcon: UIImage?
    var displayName: String = ""
    var receiver: String = ""
    var postArray: [PostAuth] = []


    @IBOutlet weak var iconView: UIImageView!
    @IBOutlet weak var label: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        postArray = []
        iconView.image = friendIcon
        label.text = displayName
        
    }
    override func viewWillAppear(_ animated: Bool) {
        setupFirebase()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    @IBAction func addFriendButton(_ sender: Any) {
      
        //追加ボタンを押した時
        if let uid = Auth.auth().currentUser?.uid {
            for postAuth in postArray {
                //相手のフォロワーに自分を追加
                if postAuth.receiver! == receiver {
                    
                    let postsRef = Database.database().reference().child(Const2.PostAuth).child(postAuth.id!)
                        postAuth.followers.append(uid)
                        let followers = ["followers": postAuth.followers]
                            //フォロワーがいない時
                            if postAuth.followers.count == 0 {
                                postsRef.setValue(followers)
                            }else{
                                postsRef.updateChildValues(followers)
                            }
                    }
                //自分のfollowに相手を追加
                if postAuth.receiver! == uid {
                    let postsRef = Database.database().reference().child(Const2.PostAuth).child(postAuth.id!)
                    postAuth.follows.append(receiver)
                    let follows = ["follows": postAuth.follows]
                        
                    //フォローがいない時
                    if postAuth.follows.count == 0 {
                        postsRef.setValue(follows)
                    }else{
                        postsRef.updateChildValues(follows)
                    }
                }
            }
        }
        //戻る
        self.navigationController?.popViewController(animated: true)
    }
    
    func setupFirebase() {
        let postsRef = Database.database().reference().child(Const2.PostAuth)
        postsRef.observe(.childAdded, with: { snapshot in
            print("DEBUG_PRINT: .childAddedイベントが発生しました。")
            // PostDataクラスを生成して受け取ったデータを設定する
            if let uid = Auth.auth().currentUser?.uid {
                let postAuth = PostAuth(snapshot: snapshot, myId: uid)
                self.postArray.insert(postAuth, at: 0)
            }
        })
    }
    


}
