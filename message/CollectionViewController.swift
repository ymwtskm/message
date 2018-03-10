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

class CollectionViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    var tags:[String] = ["家族","友達","旅行","食"]
    var tag = ""
    var index = 0
    
    @IBOutlet weak var collectionView: UICollectionView!
    override func viewDidLoad() {
        super.viewDidLoad()
//        tags = []
//        setupFirebase()
        collectionView.delegate = self
        collectionView.dataSource = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    override func viewWillAppear(_ animated: Bool) {
        
    }
//    func setupFirebase() {
//        let postsRef = Database.database().reference().child(Const.PostPath)
//        postsRef.observe(.childAdded, with: { snapshot in
//            print("DEBUG_PRINT: .childAddedイベントが発生しました。")
//            // PostDataクラスを生成して受け取ったデータを設定する
//            if let uid = Auth.auth().currentUser?.uid {
//                let postData = PostData(snapshot: snapshot, myId: uid)
//                if let tag = postData.tag{
//                    self.tags.insert(tag, at: 0)
//                    self.collectionView.reloadData()
//                }
//            }
//        })
//
//    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return tags.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "collectionCell", for: indexPath)
        let label = cell.contentView.viewWithTag(1) as! UILabel
        label.text = tags[indexPath.row]
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.index = indexPath.row
        performSegue(withIdentifier: "imageSegue", sender: nil)
        
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let imageViewController: ImageViewController = segue.destination as! ImageViewController
        imageViewController.tag = tags[index]
    }

    let margin: CGFloat = 3.0
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        // if indexPath.row % 3 == 0 {
        let size = (self.view.frame.width)/4 - (margin * 2)
        return CGSize(width: size, height: size)
        // }
        // return CGSize(width: 60.0, height: 60.0)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: margin, left: margin, bottom: margin, right: margin)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return margin
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return margin
    }

}
