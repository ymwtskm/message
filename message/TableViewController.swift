//
//  TableViewController.swift
//  message
//
//  Created by 小西椋磨 on 2018/02/28.
//  Copyright © 2018年 ryoma.konishi. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth
import SVProgressHUD
import JSQMessagesViewController
import FirebaseDatabase
import FirebaseStorage


class TableViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!
    
    //セクションのタイトル
    let stutus:[String] = ["自分","知り合いかも？","友達"]
    
    //知り合い？のreceiver
    var unknowns: [PostAuth] = []
    var followers: [String] = []
    
    //アイコン設定
    var friendIcon: UIImage?
    
    
    var postArray:[PostAuth] = []
    
    //自分のアカウント
    var myAuth:[PostAuth] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        

        // currentUserがnilならログインしていない
        if Auth.auth().currentUser == nil {
            // ログインしていないときの処理
            let loginViewController = self.storyboard?.instantiateViewController(withIdentifier: "Login")
            self.present(loginViewController!, animated: true, completion: nil)
        }
        
        //トークン
        let token = Messaging.messaging().fcmToken
        print("FCM tokenトークン: \(token ?? "")")
        print("ここまで↑")
    }

    override func viewWillAppear(_ animated: Bool) {
        friendIcon = nil
        unknowns = []
        followers = []
        postArray = []
        myAuth = []
        setupFirebase()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        //友達かどうかで場合わけ
        if indexPath.section == 0 {
            return
        }else if indexPath.section == 1 {
            performSegue(withIdentifier: "Segue2", sender: nil)
            print("Segue2")
        }else if indexPath.section == 2 {
            performSegue(withIdentifier: "Segue", sender: nil)
            print("Segue")
        }

    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        //セルを選択した時
        if segue.identifier == "Segue2" {
            let addViewController: AddViewController = segue.destination as! AddViewController
            
            //友達じゃないセルを選択したとき
            let indexPath = self.tableView.indexPathForSelectedRow
            let postAuth = unknowns[indexPath!.row]
            if let friendIconString = postAuth.icon {
                if friendIconString == "icon" {
                    self.friendIcon = UIImage(named: "icon")
                }else{
                    self.friendIcon = UIImage(data: Data(base64Encoded: friendIconString, options: .ignoreUnknownCharacters)!)
                }
            }
            addViewController.friendIcon = friendIcon
            addViewController.displayName = postAuth.displayName!
            addViewController.receiver = postAuth.receiver!
            
        }

       //友達のセルを選択したとき
        if segue.identifier == "Segue" {
            let viewController: ViewController = segue.destination as! ViewController
            
            //変更必要
            let indexPath = self.tableView.indexPathForSelectedRow
            let postAuth = postArray[indexPath!.row]
            if let friendIconString = postAuth.icon {
                if friendIconString == "icon" {
                    self.friendIcon = UIImage(named: "icon")
                }else{
                    self.friendIcon = UIImage(data: Data(base64Encoded: friendIconString, options: .ignoreUnknownCharacters)!)
                }
            }
            viewController.token = postAuth.token!
            viewController.friendIcon = friendIcon
            viewController.receiver = postAuth.receiver!
            
        }
    }
    
    func setupFirebase() {
        let postsRef = Database.database().reference().child(Const2.PostAuth)
        postsRef.observe(.childAdded, with: { snapshot in
            print("DEBUG_PRINT: .childAddedイベントが発生しました。")
            // PostDataクラスを生成して受け取ったデータを設定する
            if let uid = Auth.auth().currentUser?.uid {
                let postAuth = PostAuth(snapshot: snapshot, myId: uid)
                
                //自分の取り出し
                if uid == postAuth.receiver! {
                    self.myAuth.append(postAuth)
                }
                
                //友達の取り出し
                let followers = postAuth.followers
                for follower in followers {
                    if follower == uid {
                        self.postArray.insert(postAuth, at: 0)
                    }
                }
                
                //友達かも？を取り出し
                let follows = postAuth.follows
                for follow in follows {
                    if follow == uid {
                        var index = 0
                        for follower in followers {
                            if follower != uid {
                                index += 1
                            }
                        }
                        if index == followers.count {
                            self.unknowns.append(postAuth)
                        }
                    }
                }
                //トークンが変更されていないかどうか、変わっていれば変更
                if uid == postAuth.receiver {
                    let token = Messaging.messaging().fcmToken
                    if postAuth.token == token {
                        return
                    }else{
                        postAuth.token = token
                        let postRef = Database.database().reference().child(Const2.PostAuth).child(postAuth.id!)
                        let token:[String: Any] = ["token": postAuth.token!]
                        postRef.updateChildValues(token)

                    }
                }
                
            }
            self.tableView.reloadData()
        })
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return myAuth.count
        }else if section == 1 {
           return unknowns.count
        }else if section == 2 {
            return postArray.count
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        if indexPath.section == 0 {
            let myAccount = myAuth[indexPath.row]
            cell.textLabel?.text = myAccount.displayName
//            var myIcon: UIImage?
//            if myAccount.icon == "icon" {
//                myIcon = UIImage(named: "icon")
//            }else{
//                myIcon =  UIImage(data: Data(base64Encoded: myAccount.icon!, options: .ignoreUnknownCharacters)!)
//            }
//            cell.imageView?.image = myIcon

            // アクセサリに「none」を指定する場合
            cell.accessoryType = UITableViewCellAccessoryType.none
            
        }else if indexPath.section == 1 {
            let unknown = unknowns[indexPath.row]
            cell.textLabel?.text = unknown.displayName
//            var myIcon: UIImage?
//            if unknown.icon == "icon" {
//                myIcon = UIImage(named: "icon")
//            }else{
//                myIcon =  UIImage(data: Data(base64Encoded: unknown.icon!, options: .ignoreUnknownCharacters)!)
//            }
//            cell.imageView?.image = myIcon
        }else if indexPath.section == 2 {
            let postAuth = postArray[indexPath.row]
            cell.textLabel?.text = postAuth.displayName
//          var myIcon: UIImage?
//            if postAuth.icon == "icon" {
//                myIcon = UIImage(named: "icon")
//            }else{
//                myIcon =  UIImage(data: Data(base64Encoded: postAuth.icon!, options: .ignoreUnknownCharacters)!)
//            }
//            cell.imageView?.image = myIcon
        }
        return cell
    }
    
    //セクションの設定
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return stutus[section]
    }
    
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return stutus.count
    }
    func tableView(_ table: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80.0
    }



}
