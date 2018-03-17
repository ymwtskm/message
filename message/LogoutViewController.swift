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
    @IBOutlet weak var iconImage: UIImageView!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        // 背景をタップしたらdismissKeyboardメソッドを呼ぶように設定する
        let tapGesture: UITapGestureRecognizer = UITapGestureRecognizer(target:self, action:#selector(dismissKeyboard))
        self.view.addGestureRecognizer(tapGesture)
        postArray = []
    }
    @objc func dismissKeyboard(){
        // キーボードを閉じる
        view.endEditing(true)
    }
    override func viewWillAppear(_ animated: Bool) {
        setupFirebase()
    }
    
    func setupFirebase() {
        
        let postsRef = Database.database().reference().child(Const2.PostAuth)
        postsRef.observe(.childAdded, with: { snapshot in
            print("DEBUG_PRINT: .childAddedイベントが発生しました。")
            // PostDataクラスを生成して受け取ったデータを設定する
            if let uid = Auth.auth().currentUser?.uid {
                let postAuth = PostAuth(snapshot: snapshot, myId: uid)
                self.postArray.insert(postAuth, at: 0)
                if uid == postAuth.receiver {
                    self.textField.text = postAuth.userId
                    if let imageString = postAuth.icon {
                        if imageString == "icon" {
                            self.iconImage.image = UIImage(named: "icon")
                        }else{
                            let image = UIImage(data: Data(base64Encoded: imageString, options: .ignoreUnknownCharacters)!)
                            self.iconImage.image = image
                        }
                    }
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
                
                //既に設定している場合
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
    
    //アイコン設定ボタンを押したとき
    @IBAction func iconButton(_ sender: Any) {
        
        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
            let pickerController = UIImagePickerController()
            pickerController.delegate = self
            pickerController.sourceType = .photoLibrary
            self.present(pickerController, animated: true, completion: nil)
        }
        
    }
    
    //キャンセルを押したとき
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        // 閉じる
        picker.dismiss(animated: true, completion: nil)
    }
    // 写真を撮影/選択したときに呼ばれるメソッド
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if info[UIImagePickerControllerOriginalImage] != nil {
            // 撮影/選択された画像を取得する
            let image = info[UIImagePickerControllerOriginalImage] as! UIImage
            
            //SendImageに変遷
            let iconViewController = self.storyboard?.instantiateViewController(withIdentifier: "Icon") as? IconViewController
            iconViewController?.image = image
            picker.present(iconViewController!, animated: true, completion: nil)
            
            
            
        }
    }   

}
    

