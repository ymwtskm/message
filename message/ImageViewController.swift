//
//  ImageViewController.swift
//  message
//
//  Created by 小西椋磨 on 2018/03/05.
//  Copyright © 2018年 ryoma.konishi. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth
import SVProgressHUD
import JSQMessagesViewController
import FirebaseDatabase
import FirebaseStorage


class ImageViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    var tags:[String] = []
    var images: [UIImage] = []
    var tag = ""
    var index = 0

    
    @IBOutlet weak var collectionView: UICollectionView!
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.delegate = self
        collectionView.dataSource = self
        
        
        
    }
    override func viewWillAppear(_ animated: Bool) {
        images = []
        setupFirebase()
        collectionView.reloadData()
        print(tag)
    }
    
    func setupFirebase() {
        let postsRef = Database.database().reference().child(Const.PostPath)
        postsRef.observe(.childAdded, with: { snapshot in
            print("DEBUG_PRINT: .childAddedイベントが発生しました。")
                // PostDataクラスを生成して受け取ったデータを設定する
            if let uid = Auth.auth().currentUser?.uid {
                let postData = PostData(snapshot: snapshot, myId: uid)
                if postData.tag == self.tag {
                    if (postData.receiver == uid) || (postData.sender == uid) {
                        let imageString = postData.imageString
                        let image = UIImage(data: Data(base64Encoded: imageString!, options: .ignoreUnknownCharacters)!)
                        self.images.insert(image!, at: 0)
                        self.collectionView.reloadData()
                   }
                }
            }
        })
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return images.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "imageCell", for: indexPath)
        
        // Tag番号を使ってImageViewのインスタンス生成
        let imageView = cell.contentView.viewWithTag(1) as! UIImageView
        // 画像配列の番号で指定された要素の名前の画像をUIImageとする
        let cellImage = images[indexPath.row]
        // UIImageをUIImageViewのimageとして設定
        imageView.image = cellImage

        return cell
    }
    
    //余白
    let margin: CGFloat = 2.0
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let size = (self.view.frame.width - margin * 3)/4
        return CGSize(width: size, height: size)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        if section % 3 == 0 {
            return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        }else if section % 4 == 1 {
            return UIEdgeInsets(top: 0, left: margin, bottom: margin, right: margin/2)
        }else{
            return UIEdgeInsets(top: 0, left: margin/2, bottom: margin, right: margin)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return margin
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return margin
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.index = indexPath.row
        
        //画面変遷の処理
        let scrollViewController = self.storyboard?.instantiateViewController(withIdentifier: "Scroll")
            as? ScrollViewController
        scrollViewController?.tag = self.tag
        scrollViewController?.index = self.index
        self.present(scrollViewController!, animated: true, completion: nil)
    }


}
