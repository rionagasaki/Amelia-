//
//  SelectedHomeViewController.swift
//  Instagram
//
//  Created by Rio Nagasaki on 2021/10/06.
//

import UIKit
import Firebase
import SVProgressHUD


class SelectedHomeViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    var latitude2:String = ""
    var longitude2: String = ""
    var placeMark: String = ""
    var followArray: [Following] = []
    var postArray: [PostData] = []
    var selectedPostArray: [PostData] = []
    var listener: ListenerRegistration?
    @IBOutlet weak var nameLabel: UILabel!
    
  
    
    
    @IBAction func backButton(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    
    
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
        
        return cell
        
    }
    
    @objc func reportButton(_ sender: UIButton, forEvent event: UIEvent){
        let touch = event.allTouches?.first
        let point = touch!.location(in: self.tableView)
        let indexPath = tableView.indexPathForRow(at: point)
        let postData = selectedPostArray[indexPath!.row]
        
        let alert: UIAlertController = UIAlertController(title: "報告とブロック", message: "この投稿データに関して教えてください。", preferredStyle: UIAlertController.Style.alert)

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
        self.tableView.reloadData()
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
        
        
        self.tableView.reloadData()
        
        
    }
    
    @IBOutlet weak var copyButton: UIButton!
    
    @IBAction func searchButton(_ sender: Any) {
        print("ラベル\(nameLabel.text!)")
        UIPasteboard.general.string = "\(nameLabel.text!)"
        SVProgressHUD.showSuccess(withStatus: "テキストをコピーしました。")
    }
    
    
    
    @IBOutlet weak var tableView: UITableView!
    var refreshControl: UIRefreshControl!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.overrideUserInterfaceStyle = .light
        tableView.delegate = self
        tableView.dataSource = self
        
        nameLabel.adjustsFontSizeToFitWidth = true
        
        copyButton.setTitle("", for: .normal)
        
        nameLabel.text = placeMark
        nameLabel.textAlignment = .center
        nameLabel.layer.cornerRadius = 15.0
        nameLabel.clipsToBounds = true
        
        refreshControl = UIRefreshControl()
        refreshControl.attributedTitle = NSAttributedString(string: "読み込み中")
        refreshControl.addTarget(self, action: #selector(refresh), for: UIControl.Event.valueChanged)
        self.tableView.refreshControl = refreshControl
        tableView.addSubview(refreshControl)
        
        
        let nib = UINib(nibName: "PostTableViewCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: "Cell")
    }
    
    @objc func refresh(){
        refreshControl.endRefreshing()
        tableView.reloadData()
    }
    
    
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let uid = Auth.auth().currentUser?.uid
        let followRef = Firestore.firestore().collection(Const.FollowPath).document(uid!)
        followRef.getDocument{ (document, error) in
            if error != nil{
                return
            }
            else {
                guard (document?.data()) != nil else { return }
                let followData = Following(document: document!)
                if followData.follow.count > 0 {
                    let Ref = Firestore.firestore().collection(Const.PostPath).order(by: "date", descending: true).whereField("uid", in: followData.follow)
                    self.listener = Ref.addSnapshotListener(){ (querySnapshot, error) in
                        Ref.getDocuments(){ [self] (querySnapshot, error) in
                            if let error = error{
                                print(error)
                                return
                            }
                            selectedPostArray = []
                            self.postArray = querySnapshot!.documents.map { document in
                                let postData = PostData(document: document)
                                let latitude = postData.Latitude
                                let longitude = postData.Longitude
                                if latitude == latitude2, longitude == longitude2{
                                    selectedPostArray.append(postData)
                                    
                                    
                                    
                                }
                                
                                self.tableView.reloadData()
                                return postData
                            }
                           
                            self.tableView.reloadData()
                            
                            
                        }
                    }
                    
                }
            }
        }
    }
    
    override func  viewWillDisappear(_ animated: Bool) {
        super.viewWillAppear(animated)
        print (" DEBUG_PRINT: viewWillDisappear")
        listener?.remove()
    }
    
}
