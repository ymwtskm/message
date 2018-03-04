//
//  CollectionViewController.swift
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

class CollectionViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {
    
    var images:[UIImage] = []
    
    @IBOutlet weak var collectionView: UICollectionView!
    override func viewDidLoad() {
        super.viewDidLoad()
        images = []
        setupFirebase()
        collectionView.delegate = self
        collectionView.dataSource = self
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    override func viewWillAppear(_ animated: Bool) {
        print(images)
    }
    func setupFirebase() {
        let postsRef = Database.database().reference().child(Const.PostPath)
        postsRef.observe(.childAdded, with: { snapshot in
            print("DEBUG_PRINT: .childAddedイベントが発生しました。")
            // PostDataクラスを生成して受け取ったデータを設定する
            if let uid = Auth.auth().currentUser?.uid {
                let postData = PostData(snapshot: snapshot, myId: uid)
                if postData.imageString != nil {
                    let imageString = postData.imageString
                    let image = UIImage(data: Data(base64Encoded: imageString!, options: .ignoreUnknownCharacters)!)
                    self.images.insert(image!, at: 0)
                    self.collectionView.reloadData()
                }
            }
        })
        
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return images.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "collectionCell", for: indexPath)
        let imageView = cell.contentView.viewWithTag(1) as! UIImageView
        imageView.image = images[indexPath.row]
        return cell
    }

}
