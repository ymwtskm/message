//
//  LogoutViewController.swift
//  message
//
//  Created by 小西椋磨 on 2018/02/25.
//  Copyright © 2018年 ryoma.konishi. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth
import SVProgressHUD

class LogoutViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    var userId = ""
    var postArray:[PostAuth] = []
    
    @IBOutlet weak var textField: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()
        postArray = []
        textField.text = ""
        setupFirebase()
        // Do any additional setup after loading the view.
    }
    func setupFirebase() {
        let postsRef = Database.database().reference().child(Const2.PostAuth)
        postsRef.observe(.childAdded, with: { snapshot in
            print("DEBUG_PRINT: .childAddedイベントが発生しました。")
            // PostDataクラスを生成して受け取ったデータを設定する
            if let uid = Auth.auth().currentUser?.uid {
                let postAuth = PostAuth(snapshot: snapshot, myId: uid)
                self.postArray.insert(postAuth, at: 0)
                    if let ID = postAuth.userId {
                        self.textField.text = ID
                    }
            }
        })
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    @IBAction func handleLogoutButton(_ sender: Any) {
        // ログアウトする
        try! Auth.auth().signOut()
        
        // ログイン画面を表示する
        let loginViewController = self.storyboard?.instantiateViewController(withIdentifier: "Login")
        self.present(loginViewController!, animated: true, completion: nil)
        
        // ログイン画面から戻ってきた時のためにホーム画面（index = 0）を選択している状態にしておく
        //let tabBarController = parent as! ESTabBarController
        //tabBarController.setSelectedIndex(0, animated: false)
    }
    @IBAction func selectButton(_ sender: Any) {
        for postAuth in postArray {
            if postAuth.receiver == Auth.auth().currentUser?.uid {
                if postAuth.userId == textField.text! {
                    view.endEditing(true)
                    return
                }
            }
        }
        var count = 0
        
        if textField.text == nil {
            SVProgressHUD.showError(withStatus: "入力して下さい。")
            return
        }
        for postAuth in postArray {
            if postAuth.userId != textField.text! {
                count += 1
            }
        }
        if count != postArray.count {
            SVProgressHUD.showError(withStatus: "既に存在するIDです。")
            textField.text = ""
            return

        }
        for postAuth in postArray {

            if postAuth.receiver == Auth.auth().currentUser?.uid {
                postAuth.userId = textField.text!
                let postRef = Database.database().reference().child(Const2.PostAuth).child(postAuth.id!)
                let userId = ["userId": postAuth.userId]
                postRef.updateChildValues(userId)
                
            }
        }
        view.endEditing(true)
    }
    



}
    

