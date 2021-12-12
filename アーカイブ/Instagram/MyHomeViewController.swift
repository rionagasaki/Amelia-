//
//  MyHomeViewController.swift
//  Instagram
//
//  Created by Rio Nagasaki on 2021/10/25.
//

import UIKit
import Firebase
import FirebaseStorageUI

class MyHomeViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var postArray:[PostData] = []
    var selectedPostArray:[PostData] = []
    var followArray:[Following] = []
    var listener: ListenerRegistration?
    @IBOutlet weak var myfriendLabel: UILabel!
    @IBOutlet weak var mypointLabel: UILabel!
    @IBOutlet weak var myImage: UIImageView!
    
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return selectedPostArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell =
            tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! PostTableViewCell
        cell.setPostData(selectedPostArray[indexPath.row])
        let uid = Auth.auth().currentUser?.uid
        let post = selectedPostArray[indexPath.row]
        if post.uid != uid{
            cell.setDeleteButton(state: true)
            
        }else {
        cell.setDeleteButton(state: false)
        }
        
        
        cell.likeButton.addTarget(self, action:#selector(likeButton(_:forEvent:)), for: .touchUpInside)
        cell.commentButton.addTarget(self, action:#selector(commentButton(_:forEvent:)), for: .touchUpInside)
        cell.postDeleteButton.addTarget(self, action: #selector(postDeleteButton(_:forEvent:)), for: .touchUpInside)
        cell.postMap.addTarget(self, action: #selector(postMap(_:forEvent:)), for: .touchUpInside)
       
        
        
        
        return cell
    }
    
    
    
    override func  viewWillDisappear(_ animated: Bool) {
     
        super.viewWillAppear(animated)
        print (" DEBUG_PRINT: viewWillDisappear")
        listener?.remove()
        self.tableView.reloadData()
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
            let stringCount:String = updateCount!.description
            let storageRef = Storage.storage().reference().child("profile_image").child(uid! + stringCount)
            self.myImage.sd_imageIndicator = SDWebImageActivityIndicator.gray
            self.myImage.sd_setImage(with: storageRef)
            let count:String = followData.follow.count.description
            self.myfriendLabel.text = "友達\(count)人"
            self.mypointLabel.text = "現在\(followData.score ?? 0)pt"
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
            self.tableView.reloadData()
            
            
        }
        
        
        
        
    }
    
    @IBAction func backButton(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    
    
    
    @objc func postMap(_ sender: UIButton, forEvent event: UIEvent){
        
        let touch = event.allTouches?.first
        let point = touch!.location(in: self.tableView)
        let indexPath = tableView.indexPathForRow(at: point)
        
        let postData = selectedPostArray[indexPath!.row]
        let storyboard: UIStoryboard = self.storyboard!
        let postMapViewController = storyboard.instantiateViewController(identifier: "PostMap") as! PostMapViewController
        postMapViewController.latitude = postData.Latitude
        postMapViewController.longitude = postData.Longitude
        postMapViewController.placeMark = postData.placeMark
        present(postMapViewController, animated: true, completion: nil)
        
        
        
    }
    
    
    @objc func postDeleteButton(_ sender: UIButton, forEvent event: UIEvent){
        
        let touch = event.allTouches?.first
        let point = touch!.location(in: self.tableView)
        let indexPath = tableView.indexPathForRow(at: point)
        
        let postData = selectedPostArray[indexPath!.row]
        
        let alert: UIAlertController = UIAlertController(title: "投稿データの削除", message: "投稿データを削除します。本当に削除してもよろしいですか?", preferredStyle: UIAlertController.Style.alert)
        
        let cancelAction: UIAlertAction = UIAlertAction(title: "キャンセル", style: UIAlertAction.Style.default, handler: {_ in
            self.dismiss(animated: true, completion: nil)
        })
        
        
        let defaultAction: UIAlertAction = UIAlertAction(title: "確定", style: UIAlertAction.Style.default, handler: {_ in
            let alertRef = Firestore.firestore().collection(Const.PostPath).document(postData.id)
            alertRef.delete(){ error in
                if error != nil{
                return
            }
            print("delete成功")
        
            }
            })
        
      
        
        alert.addAction(defaultAction)
        alert.addAction(cancelAction)
        present(alert, animated: true, completion: nil)
        
        }
    
    
    
    @objc func likeButton(_ sender: UIButton, forEvent event: UIEvent){
        print("DEBUG_PRINT: likeボタンがタップされました。")
        
        
        let touch = event.allTouches?.first
        let point = touch!.location(in: self.tableView)
        let indexPath = tableView.indexPathForRow(at: point)
        
        let postData = selectedPostArray[indexPath!.row]
        
        if let myid = Auth.auth().currentUser?.uid{
            var updateValue: FieldValue
            if postData.isLiked == true{
                updateValue = FieldValue.arrayRemove([myid])
                
            }else{
                updateValue = FieldValue.arrayUnion([myid])
            }
            
            let postRef = Firestore.firestore().collection(Const.PostPath).document(postData.id)
            postRef.updateData(["likes": updateValue])
        }
    }
    
    @objc func commentButton(_ sender: UIButton, forEvent event: UIEvent){
        let touch = event.allTouches?.first
        let point = touch!.location(in: self.tableView)
        let indexPath = tableView.indexPathForRow(at: point)
        
        let postData = selectedPostArray[indexPath!.row]
        let storyboard: UIStoryboard = self.storyboard!
        let commentViewController = storyboard.instantiateViewController(identifier: "Comment") as! CommentViewController
        commentViewController.id = postData.id
        commentViewController.postImage = postData.postImage!
        commentViewController.uid = postData.uid
        present(commentViewController, animated: true, completion: nil)
        
        
        
        
        
    }
    
    
    
    
    
    
    
    

    @IBOutlet weak var tableView: UITableView!
    
    var refreshControl: UIRefreshControl!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        
        refreshControl = UIRefreshControl()
        refreshControl.attributedTitle = NSAttributedString(string: "読み込み中")
        refreshControl.addTarget(self, action: #selector(refresh), for: UIControl.Event.valueChanged)
        self.tableView.refreshControl = refreshControl
        tableView.addSubview(refreshControl)
        
        tableView.rowHeight = UITableView.automaticDimension
        
        myImage.layer.cornerRadius = myImage.frame.size.width/2
        myImage.layer.borderWidth = 1
        myImage.layer.borderColor = #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1)
        myImage.clipsToBounds = true
        
        let nib = UINib(nibName: "PostTableViewCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: "Cell")
        
    }
    @objc func refresh(){
        refreshControl.endRefreshing()
        tableView.reloadData()
    }
    
    


}
