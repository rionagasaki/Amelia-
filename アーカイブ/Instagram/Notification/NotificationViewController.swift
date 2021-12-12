//
//  NotificationViewController.swift
//  Instagram
//
//  Created by Rio Nagasaki on 2021/10/23.
//

import UIKit
import Firebase

class NotificationViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
    var notificationArray:[Notification] = []
    var selectedNotification:[Notification] = []
    var reselectedNotificaion:[Notification] = []
    
    @IBAction func backButton(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return selectedNotification.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell =
            tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! NotificationTableViewCell
        cell.setNotify(selectedNotification[indexPath.row])
        cell.notificationButton.addTarget(self, action:#selector(notificationButton(_:forEvent:)) , for: .touchUpInside)
      
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == UITableViewCell.EditingStyle.delete{
            self.selectedNotification.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .automatic)
        }
    }
    
    @objc func notificationButton(_ sender: UIButton, forEvent event: UIEvent){
        
        let touch = event.allTouches?.first
        let point = touch!.location(in: self.tableView)
        let indexPath = tableView.indexPathForRow(at: point)
        
        let notifyData = selectedNotification[indexPath!.row]
        
        let storyboard: UIStoryboard = self.storyboard!
        let commentViewController = storyboard.instantiateViewController(identifier: "Comment") as! CommentViewController
        
        commentViewController.id = notifyData.postID!
        self.present(commentViewController, animated: true, completion: nil)
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let uid = Auth.auth().currentUser?.uid
        let postRef = Firestore.firestore().collection(Const.NotificationPath).whereField("uid", isEqualTo: uid!).order(by: "date", descending: true)
        postRef.getDocuments{
            (querySnapshot, error) in
            if error != nil{
                print("エラーエラー\(error)")
                return
            }
            self.selectedNotification = []
            self.notificationArray = querySnapshot!.documents.map{
                document in
                let notifyData = Notification(document: document)
                if notifyData.uid2 != uid {
                    self.selectedNotification.append(notifyData)
                   
                }
                
                return notifyData
            }
            self.tableView.reloadData()
            
        }
        self.tableView.reloadData()
    }
    
    
    
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
        let nib = UINib(nibName: "NotificationTableViewCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: "Cell")
        
        
    }
    
    
    @objc func refresh(){
        refreshControl.endRefreshing()
        tableView.reloadData()
    }
    
    
    
    
}
