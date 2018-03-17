//
//  TagViewController.swift
//  message
//
//  Created by 小西椋磨 on 2018/03/12.
//  Copyright © 2018年 ryoma.konishi. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth
import SVProgressHUD
import JSQMessagesViewController
import FirebaseDatabase
import FirebaseStorage

class TagViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate {
    
    var postArray: [PostAuth] = []
    var tags: [String] = []
    
    @IBOutlet weak var tableView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        setupFirebase()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
    func setupFirebase() {
        let postsRef = Database.database().reference().child(Const2.PostAuth)
        postsRef.observe(.childAdded, with: { snapshot in
            print("DEBUG_PRINT: .childAddedイベントが発生しました。")
            // PostDataクラスを生成して受け取ったデータを設定する
            if let uid = Auth.auth().currentUser?.uid {
                let postAuth = PostAuth(snapshot: snapshot, myId: uid)
                self.postArray.insert(postAuth, at: 0)
                if uid == postAuth.receiver! {
                    self.tags = postAuth.tags
                }
            }
            self.tableView.reloadData()
        })

    }

    @IBAction func addButton(_ sender: Any) {
        let alert = UIAlertController(title: "タグを追加してください", message: nil, preferredStyle: .alert)
        alert.addTextField { (textField) -> Void in
            textField.delegate = self

        }
        let okButton = UIAlertAction(title: "追加", style: .default) { (action) in
        }
        let cancel = UIAlertAction(title: "キャンセル", style: .cancel, handler: nil)
        alert.addAction(okButton)
        alert.addAction(cancel)
        self.present(alert, animated: true, completion: nil)
        }
    
        func textFieldDidEndEditing(_ textField: UITextField) {
            if let tag = textField.text {
                for postAuth in postArray {
                    let postsRef = Database.database().reference().child(Const2.PostAuth).child(postAuth.id!)
                
                    if let uid = Auth.auth().currentUser?.uid {
                        if postAuth.receiver! == uid {
                            self.tags.insert(tag, at: 0)
                            postAuth.tags = self.tags
                            let tags = ["tags": postAuth.tags]
                            if postAuth.tags.count == 0 {
                                postsRef.setValue(tags)
                            }else{
                                postsRef.updateChildValues(tags)
                            }
                        }
                    }
                }
            }
            self.tableView.reloadData()
        }
    
    //タグを削除
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        
        let deleteButton: UITableViewRowAction = UITableViewRowAction(style: .normal, title: "削除") { (action, index) -> Void in
            self.tags.remove(at: indexPath.row)
            for postAuth in self.postArray {
                let postsRef = Database.database().reference().child(Const2.PostAuth).child(postAuth.id!)
                if let uid = Auth.auth().currentUser?.uid {
                    if postAuth.receiver! == uid {
                        postAuth.tags = self.tags
                        let tags = ["tags": postAuth.tags]
                            postsRef.updateChildValues(tags)
                        }
                    }
                }
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
        //削除の色
        deleteButton.backgroundColor = UIColor.red
        self.tableView.reloadData()
        return [deleteButton]
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tags.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        let tag = tags[indexPath.row]
        cell.textLabel?.text = tag
        return cell
    }
    
}
