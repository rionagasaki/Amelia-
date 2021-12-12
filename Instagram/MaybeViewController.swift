//
//  MaybeViewController.swift
//  Instagram
//
//  Created by Rio Nagasaki on 2021/11/30.
//

//import UIKit
//import Firebase
//import SVProgressHUD
//
//class MaybeViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
//
//    var followArray: [Following] = [Following]()
//    var listener: ListenerRegistration?
//    @IBOutlet weak var tableView: UITableView!
//    var selectedFollowArray: [Following] = [Following]()
//
//
//    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        return selectedFollowArray.count
//
//    }
//
//    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        let cell =
//        tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! FollowTableViewCell
//
//
//        print("GoOK?2")
//        cell.setFollowing(selectedFollowArray[indexPath.row])
//        cell.handleFollow.addTarget(self, action:#selector(handleFollow(_:forEvent:)), for: .touchUpInside)
//        return cell
//
//
//
//    }
//
//
//
//    @objc func handleFollow(_ sender: UIButton, forEvent event: UIEvent){
//        let touch = event.allTouches?.first
//        let point = touch!.location(in: self.tableView)
//        let indexPath = tableView.indexPathForRow(at: point)
//
//        let followData = selectedFollowArray[indexPath!.row]
//
//        if let myid = Auth.auth().currentUser?.uid{
//
//            if followData.isFollowed == false {
//                print("1です")
//                var updateValue: FieldValue
//                updateValue = FieldValue.arrayUnion([myid])
//                var updateValue2: FieldValue
//                updateValue2 = FieldValue.arrayUnion([followData.id])
//                let requestedRef = Firestore.firestore().collection(Const.FollowPath).document(followData.id)
//                requestedRef.updateData(["requested": updateValue])
//                let requestingRef = Firestore.firestore().collection(Const.FollowPath).document(myid)
//                requestingRef.updateData(["requesting": updateValue2])
//                SVProgressHUD.showSuccess(withStatus: "フォロー申請を送りました")
//                sender.setTitle("リクエスト", for: .normal)
//                sender.setTitleColor(#colorLiteral(red: 0.7450980544, green: 0.1568627506, blue: 0.07450980693, alpha: 1), for: .normal)
//                return
//
//            } else {
//                print("2です")
//                var updateValue3, updateValue4: FieldValue
//                updateValue3 = FieldValue.arrayRemove([myid])
//                updateValue4 = FieldValue.arrayRemove([followData.id])
//                let requestedRef = Firestore.firestore().collection(Const.FollowPath)
//                requestedRef.document(followData.id).updateData(["requested":updateValue3])
//                requestedRef.document(myid).updateData(["requesting":updateValue4])
//                SVProgressHUD.showSuccess(withStatus: "フォロー申請をキャンセルしました")
//                sender.setTitle("フォローする", for: .normal)
//                sender.setTitleColor(#colorLiteral(red: 1, green: 1, blue: 1, alpha: 1), for: .normal)
//                return
//
//
//            }
//
//        }
//
//    }
//
//
//
//
//    var refreshControl: UIRefreshControl!
//
//
//    override func viewDidLoad() {
//        print("viewDidLoad")
//        super.viewDidLoad()
//        refreshControl = UIRefreshControl()
//        refreshControl.attributedTitle = NSAttributedString(string: "読み込み中")
//        refreshControl.addTarget(self, action: #selector(refresh), for: UIControl.Event.valueChanged)
//        self.tableView.refreshControl = refreshControl
//        tableView.addSubview(refreshControl)
//        tableView.delegate = self
//        tableView.dataSource = self
//
//
//        let tapGR: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
//               tapGR.cancelsTouchesInView = false
//               self.view.addGestureRecognizer(tapGR)
//
//        let nib = UINib(nibName: "FollowTableViewCell", bundle: nil)
//        tableView.register(nib, forCellReuseIdentifier: "Cell")
//
//
//
//    }
//
//    @objc func refresh(){
//        tableView.reloadData()
//        refreshControl.endRefreshing()
//    }
//
//    @objc func dismissKeyboard() {
//           self.view.endEditing(true)
//       }
//
//    override func viewWillAppear(_ animated: Bool) {
//        super.viewWillAppear(animated)
//
//        print("DEBUG_PRINT: viewWillAppear")
//        if Auth.auth().currentUser != nil{
//            let postRef = Firestore.firestore().collection(Const.FollowPath)
//            listener = postRef.addSnapshotListener(){ (querySnapshot, error) in
//                if let error = error{
//                    print("DEBUG_PRINT: snapshotの取得が失敗しました。\(error)")
//                    return
//                }
//                let uid = Auth.auth().currentUser?.uid
//                postRef.document(uid!).getDocument{ (document, error) in
//                    if error != nil {
//                        return
//                    }
//                    let selfFollow = Following(document: document!)
//                    let selfAddress = selfFollow.address
//                self.selectedFollowArray = []
//                self.followArray = querySnapshot!.documents.compactMap { document in
//                    print("DEBUG_PRINT: document取得 \(document.documentID)")
//                    let uid = Auth.auth().currentUser?.uid
//                    let followData = Following(document: document)
//                    guard followData.name != nil else { return nil }
//                    let follow = followData.follow
//                    if followData.address == selfAddress && follow.firstIndex(of: uid!) == nil{
//                        self.selectedFollowArray.append(followData)
//                    }
//
//                    return followData
//                }
//
//                self.tableView.reloadData()
//
//            }
//        }
//        }
//    }
//
//
//}
