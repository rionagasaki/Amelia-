//
//  FollowViewController.swift
//  Instagram
//
//  Created by Rio Nagasaki on 2021/10/08.
//

import UIKit
import Firebase
import SVProgressHUD
import FirebaseFunctions

class FollowViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate  {
    
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var friendButton: UIButton!
    
    @IBOutlet weak var requestedButton: UIButton!
    @IBOutlet weak var notificationLabel: UILabel!
    
    @IBAction func RequestButton(_ sender: Any) {
        let requestedViewController = self.storyboard?.instantiateViewController(withIdentifier: "Request")as! RequestedViewController
        
        self.present(requestedViewController, animated: true, completion: nil)
    }
    
    @IBAction func FriendButton(_ sender: Any) {
        
        let friendViewController = self.storyboard?.instantiateViewController(withIdentifier: "GoodFriend")as! FriendViewController
        
        self.present(friendViewController, animated: true, completion: nil)
        
        
    }
    
    
    
    
    
    var followArray: [Following] = [Following]()
    var listener: ListenerRegistration?
    var selectedFollowArray: [Following] = [Following]()
    var searchResult:[Following] = [Following]()
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print("tableViewCount\(searchBar.text)")
        if searchBar.text == ""{
            print("GoOK?")
        return selectedFollowArray.count
        }else {
            print("こっち")
            return searchResult.count
    }
    }
    
    
    
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        print("tableViewCell\(searchBar.text)")
        let cell =
            tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! FollowTableViewCell
        
        if searchBar.text == "" {
            print("GoOK?2")
        cell.setFollowing(selectedFollowArray[indexPath.row])
            cell.handleFollow.addTarget(self, action:#selector(handleFollow(_:forEvent:)), for: .touchUpInside)
            return cell
        }else {
            print("こっち２")
            cell.setFollowing(searchResult[indexPath.row])
            cell.handleFollow.addTarget(self, action:#selector(handleFollow(_:forEvent:)), for: .touchUpInside)
            return cell
            
        }
        
    }
    
    @objc func handleFollow(_ sender: UIButton, forEvent event: UIEvent){
        let touch = event.allTouches?.first
        let point = touch!.location(in: self.tableView)
        let indexPath = tableView.indexPathForRow(at: point)
        if searchBar.text == ""{
        let followData = selectedFollowArray[indexPath!.row]
            if let myid = Auth.auth().currentUser?.uid{
                
                if followData.isFollowed == false {
                    print("1です")
                    var updateValue: FieldValue
                    updateValue = FieldValue.arrayUnion([myid])
                    var updateValue2: FieldValue
                    updateValue2 = FieldValue.arrayUnion([followData.id])
                    let requestedRef = Firestore.firestore().collection(Const.FollowPath).document(followData.id)
                    requestedRef.updateData(["requested": updateValue])
                    let requestingRef = Firestore.firestore().collection(Const.FollowPath).document(myid)
                    requestingRef.updateData(["requesting": updateValue2])
                    SVProgressHUD.showSuccess(withStatus: "フォロー申請を送りました")
                    sender.setTitle("リクエスト", for: .normal)
                    sender.setTitleColor(#colorLiteral(red: 0.7450980544, green: 0.1568627506, blue: 0.07450980693, alpha: 1), for: .normal)
                    return
                    
                } else {
                    print("2です")
                    var updateValue3, updateValue4: FieldValue
                    updateValue3 = FieldValue.arrayRemove([myid])
                    updateValue4 = FieldValue.arrayRemove([followData.id])
                    let requestedRef = Firestore.firestore().collection(Const.FollowPath)
                    requestedRef.document(followData.id).updateData(["requested":updateValue3])
                    requestedRef.document(myid).updateData(["requesting":updateValue4])
                    SVProgressHUD.showSuccess(withStatus: "フォロー申請をキャンセルしました")
                    sender.setTitle("フォローする", for: .normal)
                    sender.setTitleColor(#colorLiteral(red: 1, green: 1, blue: 1, alpha: 1), for: .normal)
                    return
                    
                    
                }
                
            }
            
        }else{
            let followData2 = searchResult[indexPath!.row]
            if let myid = Auth.auth().currentUser?.uid{
                
                if followData2.isFollowed == false {
                    print("3です")
                    var updateValue: FieldValue
                    updateValue = FieldValue.arrayUnion([myid])
                    var updateValue2: FieldValue
                    updateValue2 = FieldValue.arrayUnion([followData2.id])
                    let requestedRef = Firestore.firestore().collection(Const.FollowPath).document(followData2.id)
                    requestedRef.updateData(["requested": updateValue])
                    let requestingRef = Firestore.firestore().collection(Const.FollowPath).document(myid)
                    requestingRef.updateData(["requesting": updateValue2])
                    SVProgressHUD.showSuccess(withStatus: "フォロー申請を送りました")
                    sender.setTitle("リクエスト", for: .normal)
                    sender.setTitleColor(#colorLiteral(red: 0.7450980544, green: 0.1568627506, blue: 0.07450980693, alpha: 1), for: .normal)
                    return
                    
                } else {
                    print("4です")
                    var updateValue3, updateValue4: FieldValue
                    updateValue3 = FieldValue.arrayRemove([myid])
                    updateValue4 = FieldValue.arrayRemove([followData2.id])
                    let requestedRef = Firestore.firestore().collection(Const.FollowPath)
                    requestedRef.document(followData2.id).updateData(["requested":updateValue3])
                    requestedRef.document(myid).updateData(["requesting":updateValue4])
                    SVProgressHUD.showSuccess(withStatus: "フォロー申請をキャンセルしました")
                    sender.setTitle("フォローする", for: .normal)
                    sender.setTitleColor(#colorLiteral(red: 1, green: 1, blue: 1, alpha: 1), for: .normal)
                    return
                    
                    
                }
                
            }
        }
        

    }
   
    var refreshControl: UIRefreshControl!
  
    
    override func viewDidLoad() {
        print("viewDidLoad")
        super.viewDidLoad()
        
        refreshControl = UIRefreshControl()
        refreshControl.attributedTitle = NSAttributedString(string: "読み込み中")
        refreshControl.addTarget(self, action: #selector(refresh), for: UIControl.Event.valueChanged)
        self.tableView.refreshControl = refreshControl
        tableView.addSubview(refreshControl)
        
        tableView.delegate = self
        
        tableView.dataSource = self
        searchBar.delegate = self
        let nib = UINib(nibName: "FollowTableViewCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: "Cell")
        
        self.navigationItem.title = "User"
        
    }
    
    @objc func refresh(){
        tableView.reloadData()
        refreshControl.endRefreshing()
    }
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchResult.removeAll()
        view.endEditing(true)
        print("セレクト\(selectedFollowArray)")
        print("検索したよ")
        if let text = searchBar.text{
            if text == "" {
                tableView.reloadData()
                return
            } else{
            for data in selectedFollowArray{
                print("OKOK\(data.name ?? "")")
                if ((data.name?.contains("\(text)")) == true){
                    self.searchResult.append(data)
                   print("検索データはこちら\(searchResult)")
                }
            }
        }
        }
        self.tableView.reloadData()
        }
    
    func search(){
        searchResult.removeAll()
        view.endEditing(true)
        print("セレクト2\(selectedFollowArray)")
        print("検索したよ2")
        if let text = searchBar.text{
            if text == "" {
                tableView.reloadData()
                return
            } else{
            for data in selectedFollowArray{
                print("OKOK22\(data.name ?? "")")
                if ((data.name?.contains("\(text)")) == true){
                    self.searchResult.append(data)
                   print("検索データはこちら2\(searchResult)")
                }
            }
                self.tableView.reloadData()
        }
        }
    }
    
    
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchBar.showsCancelButton = true
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.showsCancelButton = false
        searchBar.resignFirstResponder()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        print("DEBUG_PRINT: viewWillAppear")
        if Auth.auth().currentUser != nil{
            let postRef = Firestore.firestore().collection(Const.FollowPath)
            listener = postRef.addSnapshotListener(){ (querySnapshot, error) in
                if let error = error{
                    print("DEBUG_PRINT: snapshotの取得が失敗しました。\(error)")
                    return
                }
                self.selectedFollowArray = []
                self.searchResult = []
                self.followArray = querySnapshot!.documents.compactMap { document in
                    print("DEBUG_PRINT: document取得君 \(document.documentID)")
                    let uid = Auth.auth().currentUser?.uid
                    let followData = Following(document: document)
                    guard followData.name != nil else { return nil }
                    if followData.id == uid {
                    if followData.requested.count != 0{
                        self.notificationLabel.textColor = .red
                        self.notificationLabel.text = "🔴"
                       print("Come")
                    }else{
                        self.notificationLabel.text = ""
                        print("NotCome")
                    }
                    }
                    let follow = followData.follow
                    if follow.firstIndex(of: uid!) == nil {
                        if self.searchBar.text != "" {
                            print("サーチ関数")
                            self.search()
                        }
                        self.selectedFollowArray.append(followData)
                    }
                    return followData
                }
                
                    self.tableView.reloadData()
                
            }
        }
        
    }
    
}



