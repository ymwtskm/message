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
    
    
    var members: [String] = []
    var displayNames: [String] = []
    //アイコン設定
    var friendIcon: UIImage?
    var friendIcons: [UIImage] = []
    
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


    }

    override func viewDidAppear(_ animated: Bool) {
        members = []
        displayNames = []
        friendIcon = nil
        friendIcons = []
        setupFirebase()

    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "Segue", sender: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
       //セルを選択した時
        if segue.identifier == "Segue" {
            let viewController: ViewController = segue.destination as! ViewController
            let indexPath = self.tableView.indexPathForSelectedRow
            viewController.friendIcon = friendIcons[indexPath!.row]
            viewController.receiver = members[indexPath!.row]
        }
    }
    
    func setupFirebase() {
        let postsRef = Database.database().reference().child(Const2.PostAuth)
        postsRef.observe(.childAdded, with: { snapshot in
            print("DEBUG_PRINT: .childAddedイベントが発生しました。")
            // PostDataクラスを生成して受け取ったデータを設定する
            if let uid = Auth.auth().currentUser?.uid {
                let postAuth = PostAuth(snapshot: snapshot, myId: uid)
                let receiver = postAuth.receiver
                let displayName = postAuth.displayName
                let followers = postAuth.followers
                if let friendIconString = postAuth.icon {
                    if friendIconString == "icon" {
                        self.friendIcon = UIImage(named: "icon")
                    }else{
                        self.friendIcon = UIImage(data: Data(base64Encoded: friendIconString, options: .ignoreUnknownCharacters)!)
                    }
                }
                for follower in followers {
                    if follower == uid {
                        self.friendIcons.append(self.friendIcon!)
                        self.displayNames.append(String(displayName!))
                        self.members.append(String(receiver!))
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
        return displayNames.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        cell.textLabel?.text = displayNames[indexPath.row]
        return cell
    }


}
