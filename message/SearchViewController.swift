//
//  SearchViewController.swift
//  message
//
//  Created by 小西椋磨 on 2018/03/06.
//  Copyright © 2018年 ryoma.konishi. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth
import SVProgressHUD
import JSQMessagesViewController
import FirebaseDatabase
import FirebaseStorage

class SearchViewController: UIViewController, UISearchBarDelegate {
    
    var searchID = ""
    var postArray: [PostAuth] = []
    var userId = ""
    var count = 0
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var button: UIButton!
    override func viewDidLoad() {
        postArray = []
        super.viewDidLoad()
        searchBar.delegate = self
        setupFirebase()
        userId = ""
        // 背景をタップしたらdismissKeyboardメソッドを呼ぶように設定する
        let tapGesture: UITapGestureRecognizer = UITapGestureRecognizer(target:self, action:#selector(dismissKeyboard))
        self.view.addGestureRecognizer(tapGesture)
        //ボタンの角を丸くする
        button.layer.cornerRadius = 10
    }
    @objc func dismissKeyboard(){
        // キーボードを閉じる
        view.endEditing(true)
    }


    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        for postAuth in postArray {
            if postAuth.userId == searchBar.text {
                userId = searchBar.text!
                label.text = postAuth.displayName
            }
        }
    }
    
    //追加ボタンを押した時
    @IBAction func addButton(_ sender: Any) {
        if let uid = Auth.auth().currentUser?.uid {
            for postAuth in postArray {
                if postAuth.userId == userId {
                    //自分であればリターン
                    if postAuth.receiver == uid {
                        SVProgressHUD.showError(withStatus: "自分は追加できません。")
                        return
                    }

                    let postsRef = Database.database().reference().child(Const2.PostAuth).child(postAuth.id!)
                    for myAuth in postArray {
                        let myRef = Database.database().reference().child(Const2.PostAuth).child(myAuth.id!)

                        if uid == myAuth.receiver {
                            //フォロワーがいない時
                            if postAuth.followers.count == 0 {
                                postAuth.followers.append(uid)
                                myAuth.follows.append(postAuth.receiver!)
                                let followers = ["followers": postAuth.followers]
                                let follows = ["follows": myAuth.follows]
                                postsRef.updateChildValues(followers)
                                myRef.updateChildValues(follows)
                            }else{
                                //フォロワーがいるとき
                                for follow in postAuth.followers {
                                    //既に追加しているかどうかを確かめる
                                    if follow != uid {
                                        self.count += 1
                                    }
                                    // フォロワーに自分がいなければ追加する
                                    if self.count == postAuth.followers.count {
                                        postAuth.followers.append(uid)
                                        myAuth.follows.append(postAuth.receiver!)
                                        let followers = ["followers": postAuth.followers]
                                        let follows = ["follows": myAuth.follows]
                                        postsRef.updateChildValues(followers)
                                        myRef.updateChildValues(follows)
                                        self.count = 0
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
        
        //キーボードを閉じる
        view.endEditing(true)

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
