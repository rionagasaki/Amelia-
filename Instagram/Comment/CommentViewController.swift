//
//  CommentViewController.swift
//  Instagram
//
//  Created by Rio Nagasaki on 2021/09/24.
//

import UIKit
import Firebase
import SVProgressHUD

class CommentViewController: UIViewController, UITableViewDelegate, UITableViewDataSource{
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var handleComment: UITextField!
    @IBAction func endKeyboard(_ sender: Any) {
    }
    
    
    @IBAction func backButton(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    
    
    var commentArray: [Comment] = []
    var selectedComment: [Comment] = []
    var id: String = ""
    var postImage: String = ""
    var uid: String = ""
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return selectedComment.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell =
            tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! CommentTableViewCell
        cell.setCommentData(selectedComment[indexPath.row])
        
        let uid = Auth.auth().currentUser?.uid
        let comment = selectedComment[indexPath.row]
        if comment.uid != uid{
            cell.setDeleteButton(state: true)
            
        }else {
            cell.setDeleteButton(state: false)
        }
        cell.commentDelete.addTarget(self, action: #selector(commentDelete(_:forEvent:)), for: .touchUpInside )
        cell.rename.addTarget(self, action: #selector(rename(_:forEvent:)), for: .touchUpInside )
        
        return cell
    }
    
    @objc func rename(_ sender: UIButton, forEvent event: UIEvent){
        let touch = event.allTouches?.first
        let point = touch!.location(in: self.tableView)
        let indexPath = tableView.indexPathForRow(at: point)
        
        let commentData = selectedComment[indexPath!.row]
        self.handleComment.text = "\(handleComment.text ?? "")\(commentData.name ?? "")"
        
        
        
    }
    
    @objc func commentDelete(_ sender: UIButton, forEvent event: UIEvent){
        let touch = event.allTouches?.first
        let point = touch!.location(in: self.tableView)
        let indexPath = tableView.indexPathForRow(at: point)
        
        let commentData = selectedComment[indexPath!.row]
        
        let alert: UIAlertController = UIAlertController(title: "コメントの削除", message: "コメントを削除します。", preferredStyle: UIAlertController.Style.alert)
        
        let cancelAction: UIAlertAction = UIAlertAction(title: "キャンセル", style: UIAlertAction.Style.default, handler: {_ in
        })
        
        
        let defaultAction: UIAlertAction = UIAlertAction(title: "確定", style: UIAlertAction.Style.default, handler: {_ in
            let alertRef = Firestore.firestore().collection(Const.CommentPath).document(commentData.id)
            alertRef.delete(){ error in
                if error != nil{
                    return
                }
               
                print("delete成功")
                self.reload()
                
            }
            
        })
        
        
        
        alert.addAction(defaultAction)
        alert.addAction(cancelAction)
        present(alert, animated: true, completion: nil)
        
    }
    
    
    func reload(){
        
       let commentRef = Firestore.firestore().collection(Const.CommentPath).whereField("postID",isEqualTo: self.id).order(by: "date", descending: true)
        commentRef.getDocuments{
            (querySnapshot, error) in
            if error != nil{
                print("errorです\(error)")
                return
            }
            self.selectedComment.removeAll()
            self.selectedComment = []
            self.commentArray = querySnapshot!.documents.map{
                document in
                let commentData = Comment(document: document)
                if commentData.postID == self.id{
                    self.selectedComment.append(commentData)
                    self.tableView.reloadData()
                }
                return commentData
                
            }
            self.tableView.reloadData()
            
            
        }
        
    }
    
    
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        print("ID確認\(self.id)")
        
        let commentRef = Firestore.firestore().collection(Const.CommentPath).whereField("postID",isEqualTo: self.id).order(by: "date", descending: true)
        commentRef.getDocuments{
            (querySnapshot, error) in
            if error != nil{
                print("errorです\(error)")
                return
            }
            self.selectedComment.removeAll()
            self.selectedComment = []
            self.commentArray = querySnapshot!.documents.map{
                document in
                let commentData = Comment(document: document)
                if commentData.postID == self.id{
                    self.selectedComment.append(commentData)
                    self.tableView.reloadData()
                }
                return commentData
                
            }
            self.tableView.reloadData()
            
            
        }
        
    }
    @IBAction func commnetPostButton(_ sender: Any ) {
        let comment = handleComment.text
        if comment == "" {
            SVProgressHUD.showError(withStatus: "コメントを入力してください。")
            return
        }
        
        
        self.selectedComment.removeAll()
        let postRef = Firestore.firestore().collection(Const.CommentPath).document()
        let user = Auth.auth().currentUser?.displayName
        let uid = Auth.auth().currentUser?.uid
        let dbRef = Firestore.firestore().collection(Const.FollowPath).document(uid!)
        let notificationRef = Firestore.firestore().collection(Const.NotificationPath).document()
        dbRef.getDocument{ (snap, error) in
            if error != nil {
                print("errorですか")
            }
            let followData = Following(document: snap!)
            let updateCount = followData.count
            let stringCount:String = updateCount!.description
            let ref = Storage.storage().reference().child("profile_image").child(uid! + stringCount)
            ref.downloadURL{ (url, error) in
                if error != nil {
                    return
                }
                
                
                guard let urlString = url?.absoluteString else {return}
                
                let commentDic = [
                    "name": user!,
                    "profileImage": urlString ,
                    "uid": uid!,
                    "comment": comment!,
                    "postID": self.id,
                    "date": FieldValue.serverTimestamp()
                ]
                as [String: Any]
                postRef.setData(commentDic)
                print("\(comment!)")
                self.reload()
                self.handleComment.text = ""
               
               
                SVProgressHUD.showSuccess(withStatus: "コメントの入力に成功しました")
                
                if self.uid == uid! {
                    return
                }
                
                let notificationDic = [
                    "name": user!,
                    "profileImage": urlString,
                    "postImage": self.postImage,
                    "uid": self.uid,
                    "uid2":uid!,
                    "date": FieldValue.serverTimestamp(),
                    "notification": "\(user!)があなたの投稿にコメントしています。",
                    "postID": self.id
                ] as [String: Any]
                
                notificationRef.setData(notificationDic)
                
                
                
                
            }
        }
       
    }
    @objc func dismissKeyboard() {
           self.view.endEditing(true)
       }

    
   
    var refreshControl: UIRefreshControl!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.overrideUserInterfaceStyle = .light
        tableView.delegate = self
        tableView.dataSource = self
        
        refreshControl = UIRefreshControl()
        refreshControl.attributedTitle = NSAttributedString(string: "読み込み中")
        refreshControl.addTarget(self, action: #selector(refresh), for: UIControl.Event.valueChanged)
        self.tableView.refreshControl = refreshControl
        tableView.addSubview(refreshControl)
        
        let tapGR: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
               tapGR.cancelsTouchesInView = false
               self.view.addGestureRecognizer(tapGR)
        
        
        let nib = UINib(nibName: "CommentTableViewCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: "Cell")
        
    }
    
    @objc func refresh(){
        refreshControl.endRefreshing()
        tableView.reloadData()
    }
    
    
    
    
}
