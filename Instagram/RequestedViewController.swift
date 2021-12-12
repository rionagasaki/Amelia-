//
//  RequestedViewController.swift
//  Instagram
//
//  Created by Rio Nagasaki on 2021/10/12.
//

import UIKit
import Firebase
import SVProgressHUD

class RequestedViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    
    var followArray: [Following] = [Following]()
    var listener: ListenerRegistration?
    var requestedArray: [Following] = [Following]()
    
    @IBOutlet weak var tableView: UITableView!
    
    
    @IBAction func BackButton(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return requestedArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell =
            tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! FollowTableViewCell
        cell.setFollowing(requestedArray[indexPath.row])
        cell.handleFollow.addTarget(self, action: #selector(handleFollow(_:forEvent:)), for: .touchUpInside)
        
        
        return cell
    }
    
    @objc func handleFollow(_ sender: UIButton, forEvent event: UIEvent){
        let touch = event.allTouches?.first
        let point = touch!.location(in: self.tableView)
        let indexPath = tableView.indexPathForRow(at: point)
        
        let followData = requestedArray[indexPath!.row]
        if let myid = Auth.auth().currentUser?.uid{
            var updateValue, updateValue2, updateValue3, updateValue4: FieldValue
            updateValue = FieldValue.arrayRemove([myid])
            updateValue2 = FieldValue.arrayRemove([followData.id])
            let youridRef = Firestore.firestore().collection(Const.FollowPath).document(followData.id)
            youridRef.updateData(["requesting": updateValue])
            let myidRef = Firestore.firestore().collection(Const.FollowPath).document(myid)
            myidRef.updateData(["requested": updateValue2])
            
            
            updateValue3 = FieldValue.arrayUnion([myid])
            youridRef.updateData(["follow": updateValue3])
            updateValue4 = FieldValue.arrayUnion([followData.id])
            myidRef.updateData(["follow": updateValue4])
            
            
           let generator = UINotificationFeedbackGenerator()
            generator.notificationOccurred(.success)
            generator.prepare()
            SVProgressHUD.showSuccess(withStatus: "このユーザーを友達に追加しました。")
            
        }
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        print("DEBUG_PRINT: viewWillAppear")
        if Auth.auth().currentUser != nil{
            let postRef = Firestore.firestore().collection(Const.FollowPath).order(by: "name", descending: true)
            listener = postRef.addSnapshotListener(){ (querySnapshot, error) in
                if let error = error{
                    print("DEBUG_PRINT: snapshotの取得が失敗しました。\(error)")
                    return
                }
                self.requestedArray = []
                self.followArray = querySnapshot!.documents.map { document in
                    print("DEBUG_PRINT: document取得 \(document.documentID)")
                    let followData = Following(document: document)
                    let request = followData.requesting
                    let uid = Auth.auth().currentUser?.uid
                    if request.firstIndex(of: uid!) != nil{
                        self.requestedArray.append(followData)
                    }
                    return followData
                }
                self.tableView.reloadData() }
        }
        
    }
    
    var refreshControl: UIRefreshControl!
    
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
        

        let nib = UINib(nibName: "FollowTableViewCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: "Cell")
        self.navigationItem.title = "Requested"
        self.navigationController?.navigationBar.titleTextAttributes = [.foregroundColor: UIColor.white]
        
    }
    
    @objc func refresh(){
        refreshControl.endRefreshing()
        tableView.reloadData()
    }
    
    
    
    
}
