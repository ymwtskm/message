//
//  SendImageViewController.swift
//  message
//
//  Created by 小西椋磨 on 2018/03/03.
//  Copyright © 2018年 ryoma.konishi. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth
import SVProgressHUD
import JSQMessagesViewController
import FirebaseDatabase
import FirebaseStorage

class SendImageViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    
    
    
    //uidを受け取る
    var receiver: String = ""
    var token: String = ""
    
    @IBOutlet weak var picker: UIPickerView!
    @IBOutlet weak var imageView: UIImageView!
    var tags = ["<なし>"]
    var tag = ""
    var image = UIImage()
    override func viewDidLoad() {
        super.viewDidLoad()
        imageView.image  = image
        picker.delegate = self
        picker.dataSource = self
        // Do any additional setup after loading the view.

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
                if uid == postAuth.receiver! {
                    for tag in postAuth.tags {
                        self.tags.append(tag)                    }
                    self.picker.reloadAllComponents()
                }
            }
        })
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return tags.count
    }

    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        let tag = tags[row]
        return tag
    }
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        let row = pickerView.selectedRow(inComponent: 0)
        self.tag = self.pickerView(picker, titleForRow: row, forComponent: 0)!
        print(String(tag))
        
    }

    @IBAction func backButton(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    @IBAction func sendButton(_ sender: Any) {
        //自分のsenderId, senderDisokayNameを設定
        let uid = Auth.auth().currentUser?.uid
        let userName = Auth.auth().currentUser?.displayName
        let imageData = UIImageJPEGRepresentation(image, 0.5)
        let imageString = imageData!.base64EncodedString(options: .lineLength64Characters)
        let postData = ["from": uid, "name": userName, "media": imageString, "to": self.receiver, "tag": self.tag,"token": token]
        let postsRef = Database.database().reference().child(Const.PostPath)
        postsRef.childByAutoId().setValue(postData)
        UIApplication.shared.keyWindow?.rootViewController?.dismiss(animated: true, completion: nil)
    }
    
}
