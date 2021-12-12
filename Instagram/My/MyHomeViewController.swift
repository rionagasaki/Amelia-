//
//  MyHomeViewController.swift
//  Instagram
//
//  Created by Rio Nagasaki on 2021/10/25.
//

import UIKit
import Firebase
import FirebaseStorageUI
import SVProgressHUD
import SwiftUI


class MyHomeViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout  {

    
    @IBOutlet private weak var name: UILabel!
    @IBOutlet private weak var textView: UITextView!
    @IBOutlet private weak var changeButton: UIButton!
    @IBOutlet private weak var collectionView: UICollectionView!
    
    
    @IBAction func change(_ sender: Any) {
        let uid = Auth.auth().currentUser?.uid
        let followRef = Firestore.firestore().collection(Const.FollowPath).document(uid!)
        followRef.updateData(["introduce": self.textView.text ?? ""])
        let success = UINotificationFeedbackGenerator()
        success.notificationOccurred(.success)
        success.prepare()
        SVProgressHUD.showSuccess(withStatus: "紹介文を変更しました。")
    }
    

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return selectedPostArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! FriendCollectionViewCell
        cell.layer.masksToBounds = false
        
        cell.layer.shadowOffset = CGSize(width: 0, height: 1)
        cell.layer.shadowOpacity = 0.5
        cell.layer.shadowRadius = 4
        
        
        cell.setPostData(selectedPostArray[indexPath.row])
        cell.postButton.addTarget(self, action: #selector(postButton(_:forEvent:)), for: .touchUpInside)
        return cell
    }
    
    
    
    @objc func postButton(_ sender: UIButton, forEvent event: UIEvent){
        let touch = event.allTouches?.first
        let point = touch!.location(in: self.collectionView)
        let indexPath = collectionView.indexPathForItem(at: point)
        let postData = selectedPostArray[indexPath!.row]
        
        let eachViewController = self.storyboard?.instantiateViewController(withIdentifier: "Each") as! EachViewController
        eachViewController.postId = postData.id
        self.present(eachViewController, animated: true, completion: nil)
        
    }
    
   
    

    
    private let cellId = "cellId"
    var postArray:[PostData] = []
    var selectedPostArray:[PostData] = []
    var followArray:[Following] = []
    var listener: ListenerRegistration?
    var friendCount: Int = 0
    @IBOutlet weak var myfriendLabel: UILabel!
    @IBOutlet weak var mypointLabel: UILabel!
    @IBOutlet weak var myImage: UIImageView!
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return .init(width: 129, height: 190)
    }
    
    override func  viewWillDisappear(_ animated: Bool) {
     
        super.viewWillAppear(animated)
        print (" DEBUG_PRINT: viewWillDisappear")
        listener?.remove()
        self.collectionView.reloadData()
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let uid = Auth.auth().currentUser?.uid
        
        let followRef = Firestore.firestore().collection(Const.FollowPath).document(uid!)
        followRef.getDocument{
            (document, error) in
            if error != nil {
                return
            }
            let followData = Following(document: document!)
            let updateCount = followData.count
            self.name.text = followData.name
            if followData.introduce != nil {
                self.textView.text = followData.introduce
            }
            let stringCount:String = updateCount!.description
            let storageRef = Storage.storage().reference().child("profile_image").child(uid! + stringCount)
            self.myImage.sd_imageIndicator = SDWebImageActivityIndicator.gray
            self.myImage.sd_setImage(with: storageRef)
            let count:String = (followData.follow.count - 1).description
            self.myfriendLabel.text = "友達\(count)人"
            self.mypointLabel.text = "\(followData.score ?? 0)pt"
        }
        
        
        let postRef = Firestore.firestore().collection(Const.PostPath).order(by: "date", descending: true).whereField("uid", isEqualTo: uid!)
        
        self.listener = postRef.addSnapshotListener(){
            (querySnapshot, error) in
            if error != nil {
                return
            }
            self.selectedPostArray = []
            self.postArray = querySnapshot!.documents.map{
                document in
                let postData = PostData(document: document)
                self.selectedPostArray.append(postData)
                return postData
            }
            self.collectionView.reloadData()
            
            
        }
}
    
    
    
    
    @IBAction func backButton(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @objc func dismissKeyboard() {
           self.view.endEditing(true)
       }
    
   
    
 
 
    var refreshControl: UIRefreshControl!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.overrideUserInterfaceStyle = .light
        collectionView.delegate = self
        collectionView.dataSource = self
        
        textView.layer.borderWidth = 1
        textView.layer.borderColor = UIColor.black.cgColor
        let tapGR: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
               tapGR.cancelsTouchesInView = false
               self.view.addGestureRecognizer(tapGR)
       
        
        let layout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: 10, left: 30, bottom: 0, right: 30)
        collectionView.collectionViewLayout = layout
        changeButton.layer.borderWidth = 1
        changeButton.layer.borderColor = UIColor.blue.cgColor
        
        changeButton.layer.shadowOffset = CGSize(width: 0.0, height: 2.0)
        changeButton.layer.shadowColor = UIColor.black.cgColor
        changeButton.layer.shadowOpacity = 0.5
        changeButton.layer.shadowRadius = 4
        changeButton.alpha = 0.9
        
       
        
        refreshControl = UIRefreshControl()
        refreshControl.attributedTitle = NSAttributedString(string: "読み込み中")
        refreshControl.addTarget(self, action: #selector(refresh), for: UIControl.Event.valueChanged)
        self.collectionView.refreshControl = refreshControl
        collectionView.addSubview(refreshControl)
        
       
        myImage.layer.cornerRadius = myImage.frame.size.width/2
        myImage.layer.borderWidth = 1
        myImage.layer.borderColor = #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1)
        myImage.clipsToBounds = true
        
        
        let nib = UINib(nibName: "FriendCollectionViewCell", bundle: nil)
        collectionView.register(nib, forCellWithReuseIdentifier: cellId)
        
    }
    @objc func refresh(){
        refreshControl.endRefreshing()
        collectionView.reloadData()
    }
    
    


}
