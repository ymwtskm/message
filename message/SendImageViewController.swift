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
    
    @IBOutlet weak var picker: UIPickerView!
    @IBOutlet weak var imageView: UIImageView!
    var tags = ["<なし>","家族","友達","旅行","食"]
    var tag = ""
    var image = UIImage()
    override func viewDidLoad() {
        super.viewDidLoad()
        imageView.image  = image
        picker.delegate = self
        picker.dataSource = self
        // Do any additional setup after loading the view.
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
        let postData = ["from": uid, "name": userName, "media": imageString, "to": self.receiver, "tag": self.tag]
        let postsRef = Database.database().reference().child(Const.PostPath)
        postsRef.childByAutoId().setValue(postData)
        UIApplication.shared.keyWindow?.rootViewController?.dismiss(animated: true, completion: nil)
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
