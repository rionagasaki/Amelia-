//
//  FriendHomeViewController.swift
//  Instagram
//
//  Created by Rio Nagasaki on 2021/10/20.
//

import UIKit
import Firebase

class FriendHomeViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var latitude2 = ""
    var longitude2 = ""
    var id = ""
    var postArray:[PostData] = []
    var selectedPostArray:[PostData] = []
    var listener: ListenerRegistration?
   
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return selectedPostArray.count
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
        
        
        return cell
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
        let nib = UINib(nibName: "PostTableViewCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: "Cell")
        self.tableView.reloadData()
        
    }
    
    
    @objc func refresh(){
        refreshControl.endRefreshing()
        tableView.reloadData()
    }
    
    
    
    @IBAction func backButton(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let ref = Firestore.firestore().collection(Const.PostPath)
        ref.getDocuments{ (querySnapshot, error) in
            if error != nil {
                print("errorでした")
                return
            }
            self.selectedPostArray = []
            self.postArray = querySnapshot!.documents.map{ document in
                let postData = PostData(document: document)
                if postData.uid == self.id && postData.Latitude == self.latitude2 && postData.Longitude == self.longitude2 {
                    self.selectedPostArray.append(postData)
                    
                }
                return postData
            }
            self.tableView.reloadData()
        }
        
        
        
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
        
        let postRef = Firestore.firestore().collection(Const.PostPath)
        
        let postRef2
            = postRef.document(postData.id)
        
        let storyboard: UIStoryboard = self.storyboard!
        
        
        let comment = storyboard.instantiateViewController(identifier: "Comment") as! CommentViewController
        
        
        
        
        present(comment, animated: true, completion: nil)
        
        
    }
    
    override func  viewWillDisappear(_ animated: Bool) {
        super.viewWillAppear(animated)
        print (" DEBUG_PRINT: viewWillDisappear")
        listener?.remove()
        self.tableView.reloadData()
    }
    
  
}
