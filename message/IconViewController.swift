//
//  IconViewController.swift
//  message
//
//  Created by 小西椋磨 on 2018/03/10.
//  Copyright © 2018年 ryoma.konishi. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth
import SVProgressHUD
import JSQMessagesViewController
import FirebaseDatabase
import FirebaseStorage

class IconViewController: UIViewController {
   
    var image = UIImage()
    var postArray:[PostAuth] = []



    @IBOutlet weak var iconImage: UIImageView!
    override func viewDidLoad() {
        super.viewDidLoad()
        iconImage.image  = image
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
            }
        })
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    @IBAction func iconButton(_ sender: Any) {
        
        for postAuth in postArray {
            
            if postAuth.receiver == Auth.auth().currentUser?.uid {
                let iconData = UIImageJPEGRepresentation(image, 0.5)
                let iconString = iconData!.base64EncodedString(options: .lineLength64Characters)

                postAuth.icon = iconString
                let postRef = Database.database().reference().child(Const2.PostAuth).child(postAuth.id!)
                let icon = ["icon": postAuth.icon]
                postRef.updateChildValues(icon)
                UIApplication.shared.keyWindow?.rootViewController?.dismiss(animated: true, completion: nil)
                
            }
        }


    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
