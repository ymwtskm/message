//
//  ViewController.swift
//  message
//
//  Created by 小西椋磨 on 2018/02/25.
//  Copyright © 2018年 ryoma.konishi. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth
import SVProgressHUD
import JSQMessagesViewController
import FirebaseDatabase
import FirebaseStorage

class ViewController: JSQMessagesViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    //uidを受け取る
    var receiver: String = ""
    var friendIcon: UIImage?
    var myIcon: UIImage?
    
    var messages: [JSQMessage]?
    var incomingBubble: JSQMessagesBubbleImage!
    var outgoingBubble: JSQMessagesBubbleImage!
    var incomingAvatar: JSQMessagesAvatarImage!
    var outgoingAvatar: JSQMessagesAvatarImage!
    
    
    func setupFirebase() {
        let postsAuth = Database.database().reference().child(Const2.PostAuth)
        postsAuth.observe(.childAdded, with: { snapshot in
            if let uid = Auth.auth().currentUser?.uid {
                let postAuth = PostAuth(snapshot: snapshot, myId: uid)
                if uid == postAuth.receiver {
                    if postAuth.icon == "icon" {
                        self.myIcon = UIImage(named: "icon")
                    }else{
                        self.myIcon =  UIImage(data: Data(base64Encoded: postAuth.icon!, options: .ignoreUnknownCharacters)!)
                    }
                    //自分のアイコンを表示
                    self.outgoingAvatar = JSQMessagesAvatarImageFactory.avatarImage(with: self.myIcon, diameter: 64)

                }
            }
        })

        
        
        
        
        
        let postsRef = Database.database().reference().child(Const.PostPath)
        postsRef.observe(.childAdded, with: { snapshot in
            print("DEBUG_PRINT: .childAddedイベントが発生しました。")
            // PostDataクラスを生成して受け取ったデータを設定する
            if let uid = Auth.auth().currentUser?.uid {
                let postData = PostData(snapshot: snapshot, myId: uid)
                let sender = postData.sender
                let postReceiver = postData.receiver
                let name = postData.name
                
                //個別に送受信
                if (postReceiver == self.receiver) || (sender == self.receiver)  {
                    if (postReceiver == uid) || (sender == uid) {
                        if let imageString = postData.imageString {
                            let image = UIImage(data: Data(base64Encoded: imageString, options: .ignoreUnknownCharacters)!)
                            let photo = JSQPhotoMediaItem(image: image)
                            if sender == uid {
                                photo?.appliesMediaViewMaskAsOutgoing = true
                            } else {
                                photo?.appliesMediaViewMaskAsOutgoing = false
                            }
                            let message = JSQMessage(senderId: sender, displayName: name, media: photo)
                            self.messages?.append(message!)
                        }
                        
                        if let text = postData.text {
                            print("テキストが入力されました")
                            let message = JSQMessage(senderId: sender, displayName: name, text: text)
                            self.messages?.append(message!)
                        }
                        
                    }
                }
                
                self.finishReceivingMessage()
            }
        })
        
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        //自分のアイコンを空にする
        myIcon = nil
        
        // 背景をタップしたらdismissKeyboardメソッドを呼ぶように設定する
        let tapGesture: UITapGestureRecognizer = UITapGestureRecognizer(target:self, action:#selector(dismissKeyboard))
        self.view.addGestureRecognizer(tapGesture)
        
        //テキストフィールドの左のクリップマーク
        //inputToolbar!.contentView!.leftBarButtonItem = nil
        automaticallyScrollsToMostRecentMessage = true
        
        //吹き出しの設定
        let bubbleFactory = JSQMessagesBubbleImageFactory()
        self.incomingBubble = bubbleFactory?.incomingMessagesBubbleImage(with: UIColor.jsq_messageBubbleGreen())
        self.outgoingBubble = bubbleFactory?.outgoingMessagesBubbleImage(with: UIColor.jsq_messageBubbleBlue())
        
            //アバターの設定
        self.incomingAvatar = JSQMessagesAvatarImageFactory.avatarImage(with: friendIcon, diameter: 64)
        
        

        //自分のsenderId, senderDisokayNameを設定
        if let uid = Auth.auth().currentUser?.uid {
            self.senderId = String(uid)
        }
        if let userName = Auth.auth().currentUser?.displayName {
            self.senderDisplayName = String(userName)
        }
        //メッセージデータの配列を初期化
        self.messages = []

    }
    override func viewWillAppear(_ animated: Bool) {
        setupFirebase()
    }
    
    @objc func dismissKeyboard(){
        // キーボードを閉じる
        view.endEditing(true)
    }
    
    
    //Sendボタンが押された時に呼ばれる
    override func didPressSend(_ button: UIButton!, withMessageText text: String!, senderId: String!, senderDisplayName: String!, date: Date!) {
        
        //メッセージの送信処理を完了する(画面上にメッセージが表示される)
        self.finishReceivingMessage(animated: true)
        
        //firebaseにデータを送信、保存する
        let postData = ["from": senderId, "name": senderDisplayName, "text":text, "to": receiver]
        let postsRef = Database.database().reference().child(Const.PostPath)
        postsRef.childByAutoId().setValue(postData)
        print("テキストが入力されました")
        //textFieldをクリアにする
        self.finishSendingMessage(animated: true)
        // キーボードを閉じる
        view.endEditing(true)
    }
    
    // 表示するメッセージの内容
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, messageDataForItemAt indexPath: IndexPath!) -> JSQMessageData! {
        return messages?[indexPath.row]
    }
    //アイテムごとのMessageBubble(背景)を返す
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, messageBubbleImageDataForItemAt indexPath: IndexPath!) -> JSQMessageBubbleImageDataSource! {
        let message = self.messages?[indexPath.item]
        if message?.senderId == self.senderId {
            return self.outgoingBubble
        }
        return self.incomingBubble
    }
    
    //アイテムごとにアバター画像を返す
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, avatarImageDataForItemAt indexPath: IndexPath!) -> JSQMessageAvatarImageDataSource! {
        let message = self.messages?[indexPath.item]
        if message?.senderId == self.senderId {
            return self.outgoingAvatar
        }
        return self.incomingAvatar
    }
    
    //アイテムの総数を返す
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return (self.messages?.count)!
    }
    // 写真を撮影/選択したときに呼ばれるメソッド
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if info[UIImagePickerControllerOriginalImage] != nil {
            // 撮影/選択された画像を取得する
            let image = info[UIImagePickerControllerOriginalImage] as! UIImage
            
            //SendImageに変遷
            let sendImageViewController = self.storyboard?.instantiateViewController(withIdentifier: "SendImage") as? SendImageViewController
            sendImageViewController?.image = image
            sendImageViewController?.receiver = receiver
            
            picker.present(sendImageViewController!, animated: true, completion: nil)
            
            
            
        }
    }
    
    //閉じる
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        // 閉じる
        picker.dismiss(animated: true, completion: nil)
    }
    //クリップのアイコンを押して画像を送信する
    override func didPressAccessoryButton(_ sender: UIButton!) {
        
        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
            let pickerController = UIImagePickerController()
            pickerController.delegate = self
            pickerController.sourceType = .photoLibrary
            self.present(pickerController, animated: true, completion: nil)
        }
        
    }
    
    
}
