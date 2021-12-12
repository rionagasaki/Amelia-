//
//  FriendViewController.swift
//  Instagram
//
//  Created by Rio Nagasaki on 2021/10/19.
//

import UIKit
import Firebase

class FriendViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    
    var followArray: [Following] = [Following]()
    var listener: ListenerRegistration?
    var selectedFollowArray: [Following] = [Following]()
    
    
    @IBAction func backButton(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return selectedFollowArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! FriendTableViewCell
        cell.setFollowing(selectedFollowArray[indexPath.row])
        cell.friendDelete.addTarget(self, action:#selector(friendDelete(_:forEvent:)), for: .touchUpInside)
        cell.friendMap.addTarget(self, action:#selector(friendMap(_sender:forEvent:)), for: .touchUpInside)
        
        return cell
    }
    
    @objc func friendMap(_sender: UIButton, forEvent event: UIEvent){
        
        let alert = UIAlertController(title: "友達の詳細", message: "友達の投稿が見れます。", preferredStyle: .actionSheet)
        
        let post = UIAlertAction(title: "投稿一覧", style: .default) { [self] (action) in
            let touch = event.allTouches?.first
            let point = touch!.location(in: self.tableView)
            let indexPath = tableView.indexPathForRow(at: point)
            let postData = selectedFollowArray[indexPath!.row]
            let viewController = self.storyboard?.instantiateViewController(identifier: "Friend Home") as! ViewController
            viewController.friendUid = postData.id
            present(viewController, animated: true, completion: nil)
        }
        
        let map = UIAlertAction(title: "マップ", style: .default) { [self] (action) in
            let touch = event.allTouches?.first
            let point = touch!.location(in: self.tableView)
            let indexPath = tableView.indexPathForRow(at: point)
            let followData = selectedFollowArray[indexPath!.row]
            let friendMapViewController = self.storyboard?.instantiateViewController(identifier: "Friend") as! FriendMapViewController
            friendMapViewController.id = followData.id
            present(friendMapViewController, animated: true, completion: nil)
        }
        
        let cancel: UIAlertAction = UIAlertAction(title: "キャンセル", style: UIAlertAction.Style.default, handler: {_ in
            alert.dismiss(animated: true, completion: nil)
        })
        
       
        
        
        alert.addAction(post)
        alert.addAction(map)
        alert.addAction(cancel)
        present(alert, animated: true, completion: nil)
       
    }
    
    
    
    
    @objc func friendDelete(_ sender: UIButton, forEvent event: UIEvent){
        let touch = event.allTouches?.first
        let point = touch!.location(in: self.tableView)
        let indexPath = tableView.indexPathForRow(at: point)
        let followData = selectedFollowArray[indexPath!.row]
        
        let alert: UIAlertController = UIAlertController(title: "友達の削除", message: "友達を削除します。本当に削除してもよろしいですか?", preferredStyle: UIAlertController.Style.alert)
        
        let cancelAction: UIAlertAction = UIAlertAction(title: "キャンセル", style: UIAlertAction.Style.default, handler: {_ in
            alert.dismiss(animated: true, completion: nil)
        })
        
        let defaultAction: UIAlertAction = UIAlertAction(title: "確定", style: UIAlertAction.Style.default, handler: {_ in
        if let myid = Auth.auth().currentUser?.uid{
            var updateValue: FieldValue
            var updateValue2: FieldValue
            updateValue = FieldValue.arrayRemove([myid])
            updateValue2 = FieldValue.arrayRemove([followData.id])
            let followRef = Firestore.firestore().collection(Const.FollowPath).document(followData.id)
            followRef.updateData(["follow": updateValue])
            let followRef2 = Firestore.firestore().collection(Const.FollowPath).document(myid)
            followRef2.updateData(["follow": updateValue2])
            
        }
        }
        )
        alert.addAction(defaultAction)
        alert.addAction(cancelAction)
        present(alert, animated: true, completion: nil)
    }
    
    var refreshControl:UIRefreshControl!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        self.overrideUserInterfaceStyle = .light
        refreshControl = UIRefreshControl()
        refreshControl.attributedTitle = NSAttributedString(string: "読み込み中")
        refreshControl.addTarget(self, action: #selector(refresh), for: UIControl.Event.valueChanged)
        self.tableView.refreshControl = refreshControl
        tableView.addSubview(refreshControl)
        let nib = UINib(nibName: "FriendTableViewCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: "Cell")
        
        self.navigationItem.title = "Friend"
        self.navigationController?.navigationBar.titleTextAttributes = [.foregroundColor: UIColor.white]
    }
    
    @objc func refresh(){
        refreshControl.endRefreshing()
        tableView.reloadData()
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let uid = Auth.auth().currentUser?.uid
        print("DEBUG_PRINT: viewWillAppear")
        if Auth.auth().currentUser != nil{
            let postRef = Firestore.firestore().collection(Const.FollowPath)
            listener = postRef.addSnapshotListener(){ (querySnapshot, error) in
                if let error = error{
                    print("DEBUG_PRINT: snapshotの取得が失敗しました。\(error)")
                    return
                }
                self.selectedFollowArray = []
                self.followArray = querySnapshot!.documents.compactMap { document in
                    print("DEBUG_PRINT: document取得 \(document.documentID)")
                    let followData = Following(document: document)
                    guard followData.name != nil else { return nil }
                    let follow = followData.follow
                    if follow.firstIndex(of: uid!) != nil {
                        self.selectedFollowArray.append(followData)
                    }
                    return followData
                }
                self.tableView.reloadData()
                
            }
        }
        
    }
    
    
    
    
}
