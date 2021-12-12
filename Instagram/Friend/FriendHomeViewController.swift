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
        cell.reportButton.addTarget(self, action:#selector(reportButton(_:forEvent:)), for: .touchUpInside)
        cell.mapButton.addTarget(self, action:#selector(postMap(_:forEvent:)), for: .touchUpInside)
        cell.postMap.addTarget(self, action: #selector(postMap(_:forEvent:)), for: .touchUpInside)
        return cell
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
    
    @objc func reportButton(_ sender: UIButton, forEvent event: UIEvent){
        let touch = event.allTouches?.first
        let point = touch!.location(in: self.tableView)
        let indexPath = tableView.indexPathForRow(at: point)
        let postData = selectedPostArray[indexPath!.row]
        
        let alert: UIAlertController = UIAlertController(title: "報告とブロック", message: "この投稿データに関して教えてください。", preferredStyle: UIAlertController.Style.alert)

        let cancelAction: UIAlertAction = UIAlertAction(title: "キャンセル", style: UIAlertAction.Style.default, handler: {_ in
            self.dismiss(animated: true, completion: nil)
        })
        
        
        let disappearAction: UIAlertAction = UIAlertAction(title: "ユーザーの削除", style: UIAlertAction.Style.default, handler: {_ in
            let friendViewController = self.storyboard?.instantiateViewController(identifier: "GoodFriend") as! FriendViewController
            self.present(friendViewController, animated: true, completion: nil)
            print("delete成功")

            }
            )



        let defaultAction: UIAlertAction = UIAlertAction(title: "通報", style: UIAlertAction.Style.default, handler: {_ in
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
