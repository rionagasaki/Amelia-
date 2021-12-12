//
//  EachViewController.swift
//  Instagram
//
//  Created by Rio Nagasaki on 2021/12/03.
//

import UIKit
import Firebase
import FirebaseStorageUI

class EachViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    

    var listener: ListenerRegistration?
    var postArray: [PostData] = []
    var followArray: [Following] = []
    var selectedPostArray: [PostData] = []
    var postId = ""
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return selectedPostArray.count
    }
    
    @IBAction func backButton(_ sender: Any) {
        self.dismiss(animated:true, completion: nil)
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell =
            tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! PostTableViewCell

        let uid = Auth.auth().currentUser?.uid
        cell.setPostData(selectedPostArray[indexPath.row])
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
        cell.postUser.addTarget(self, action: #selector(postUser(_:forEvent:)), for: .touchUpInside)
        cell.mapButton.addTarget(self, action: #selector(postMap(_:forEvent:)), for: .touchUpInside)
        cell.reportButton.addTarget(self, action: #selector(reportButton(_:forEvent:)), for: .touchUpInside)
        
        return cell


       
    }
    
    @IBOutlet weak var headerLabel: UILabel!
    
    override func viewWillAppear(_ animated: Bool) {
        print("aaaaaaa")
        super.viewWillAppear(animated)
        
        let followRef = Firestore.firestore().collection(Const.PostPath).whereField(FieldPath.documentID(), isEqualTo: postId)
        self.listener = followRef.addSnapshotListener() { (querySnapshot, error) in
            if error != nil {
                return
            }
            
            self.selectedPostArray = []
            self.postArray = querySnapshot!.documents.map { document in
            let postData = PostData(document: document)
            
            self.headerLabel.text = "\(postData.name!)の投稿"
            
            self.selectedPostArray.append(postData)
            return postData
        }
            self.tableView.reloadData()
        }
        
        self.tableView.reloadData()
        


}

    
    override func  viewWillDisappear(_ animated: Bool) {

        super.viewWillAppear(animated)
        print (" DEBUG_PRINT: viewWillDisappear")
        listener?.remove()
        self.tableView.reloadData()
    }
    
    

    
    @objc func reportButton(_ sender: UIButton, forEvent event: UIEvent){
        let touch = event.allTouches?.first
        let point = touch!.location(in: self.tableView)
        let indexPath = tableView.indexPathForRow(at: point)
        let postData = selectedPostArray[indexPath!.row]
        
        let alert: UIAlertController = UIAlertController(title: "報告とブロック", message: "投稿データに関して教えてください。", preferredStyle: UIAlertController.Style.alert)

        let cancelAction: UIAlertAction = UIAlertAction(title: "キャンセル", style: UIAlertAction.Style.default, handler: {_ in
            alert.dismiss(animated: true, completion: nil)
        })
        
        
        let disappearAction: UIAlertAction = UIAlertAction(title: "ユーザーの削除", style: UIAlertAction.Style.default, handler: {_ in
            let friendViewController = self.storyboard?.instantiateViewController(identifier: "GoodFriend") as! FriendViewController
            self.present(friendViewController, animated: true, completion: nil)
            print("delete成功")

            }
            )



        let defaultAction: UIAlertAction = UIAlertAction(title: "通報する", style: UIAlertAction.Style.default, handler: {_ in
            let reportViewController = self.storyboard?.instantiateViewController(identifier: "Report") as! ReportViewController
            reportViewController.reportID = postData.id
            reportViewController.reportUID = postData.uid
            reportViewController.reportName = postData.name!
            reportViewController.reportPlaceMark = postData.placeMark
            self.present(reportViewController, animated: true, completion: nil)
            print("delete成功")

            }
            )


        
        alert.addAction(defaultAction)
        alert.addAction(disappearAction)
        alert.addAction(cancelAction)
        present(alert, animated: true, completion: nil)

        
        
        
    }
    
  
    
    @objc func postUser(_ sender: UIButton, forEvent event: UIEvent){
        let touch = event.allTouches?.first
        let point = touch!.location(in: self.tableView)
        let indexPath = tableView.indexPathForRow(at: point)
        let postData = selectedPostArray[indexPath!.row]
        let uid2 = Auth.auth().currentUser?.uid
        if postData.uid != uid2 {
        let viewController = self.storyboard?.instantiateViewController(identifier: "Friend Home") as! ViewController
        viewController.friendUid = postData.uid
        present(viewController, animated: true, completion: nil)
        }
        else {
            let myhomeViewController = self.storyboard?.instantiateViewController(identifier: "My Home") as! MyHomeViewController
            present(myhomeViewController, animated: true, completion: nil)
            
        }
       
        
        
        
        
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
        postMapViewController.postImage = postData.postImage!
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
    
    
    @IBAction func userButton(_ sender: Any) {
        let adressViewController = self.storyboard?.instantiateViewController(withIdentifier: "Adress") as! AdressViewController
        self.present(adressViewController, animated: true, completion: nil)
    }
    


    @objc func likeButton(_ sender: UIButton, forEvent event: UIEvent){
        print("DEBUG_PRINT: likeボタンがタップされました。")


        let touch = event.allTouches?.first
        let point = touch!.location(in: self.tableView)
        let indexPath = tableView.indexPathForRow(at: point)

        let postData = selectedPostArray[indexPath!.row]
        
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.warning)
        generator.prepare()

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
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        
        self.overrideUserInterfaceStyle = .light
        
      

        
        let nib = UINib(nibName: "PostTableViewCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: "Cell")

        
    }
    


}
