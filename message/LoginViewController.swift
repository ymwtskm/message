//
//  LoginViewController.swift
//  message
//
//  Created by 小西椋磨 on 2018/02/25.
//  Copyright © 2018年 ryoma.konishi. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth
import SVProgressHUD

class LoginViewController: UIViewController {
    
    @IBOutlet weak var mailAddressTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var displayNameTextField: UITextField!
    
    var displayNames: [String] = []
    var count = 0
    // ログインボタンをタップしたときに呼ばれるメソッド
    @IBAction func handleLoginButton(_ sender: Any) {
        if let address = mailAddressTextField.text, let password = passwordTextField.text {
            
            // アドレスとパスワード名のいずれかでも入力されていない時は何もしない
            if address.isEmpty || password.isEmpty {
                SVProgressHUD.showError(withStatus: "必要項目を入力して下さい")
                return
            }
            
            // HUDで処理中を表示
            SVProgressHUD.show()
            
            Auth.auth().signIn(withEmail: address, password: password) { user, error in
                if let error = error {
                    print("DEBUG_PRINT: " + error.localizedDescription)
                    SVProgressHUD.showError(withStatus: "サインインに失敗しました。")
                    return
                } else {
                    print("DEBUG_PRINT: ログインに成功しました。")

                    // HUDを消す
                    SVProgressHUD.dismiss()
                    
                    // 画面を閉じてViewControllerに戻る
                    self.dismiss(animated: true, completion: nil)
                }
            }
        }
    }
    
    // アカウント作成ボタンをタップしたときに呼ばれるメソッド
    @IBAction func handleCreateAcountButton(_ sender: Any) {
        if let address = mailAddressTextField.text, let password = passwordTextField.text, let displayName = displayNameTextField.text {
            
            // アドレスとパスワードと表示名のいずれかでも入力されていない時は何もしない
            if address.isEmpty || password.isEmpty || displayName.isEmpty {
                print("DEBUG_PRINT: 何かが空文字です。")
                SVProgressHUD.showError(withStatus: "必要項目を入力して下さい")
                return
            }
            
            // HUDで処理中を表示
            SVProgressHUD.show()
            
                
                // アドレスとパスワードでユーザー作成。ユーザー作成に成功すると、自動的にログインする
                Auth.auth().createUser(withEmail: address, password: password) { user, error in
                    if let error = error {
                        // エラーがあったら原因をprintして、returnすることで以降の処理を実行せずに処理を終了する
                        print("DEBUG_PRINT: " + error.localizedDescription)
                        SVProgressHUD.showError(withStatus: "ユーザー作成に失敗しました。")
                        return
                    }
                    print("DEBUG_PRINT: ユーザー作成に成功しました。")
                    
                    // 表示名を設定する
                    let user = Auth.auth().currentUser
                    if let user = user {
                        let changeRequest = user.createProfileChangeRequest()
                        changeRequest.displayName = displayName
                        changeRequest.commitChanges { error in
                            if let error = error {
                                SVProgressHUD.showError(withStatus: "ユーザー作成時にエラーが発生しました。")
                                print("DEBUG_PRINT: " + error.localizedDescription)
                            }
                            print("DEBUG_PRINT: [displayName = \(String(describing: user.displayName))]の設定に成功しました。")
                            
                            // HUDを消す
                            SVProgressHUD.dismiss()
                            
                            // 画面を閉じてViewControllerに戻る
                            self.dismiss(animated: true, completion: nil)
//                            // TableView画面を表示する
//                            let tableViewController = self.storyboard?.instantiateViewController(withIdentifier: "TableView")
//                            self.present(tableViewController!, animated: true, completion: nil)
                        }
                    } else {
                        print("DEBUG_PRINT: displayNameの設定に失敗しました。")
                    }
                    let receiver = Auth.auth().currentUser?.uid
                    let postsRef = Database.database().reference().child(Const2.PostAuth)
                    let postAuth = ["to": receiver, "displayName": displayName]
                    postsRef.childByAutoId().setValue(postAuth)

                    //メールを送る
                    Auth.auth().currentUser?.sendEmailVerification { (error) in
                        // ...
                    }
                }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}
