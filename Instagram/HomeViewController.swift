
import UIKit
import Firebase
import Nuke
import FirebaseStorageUI

class HomeViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {


    @IBOutlet weak var newPost: UIButton!
    
    @IBOutlet weak var emptyLabel: UILabel!
    @IBAction func new(_ sender: Any) {
        let imageSelectViewController = self.storyboard?.instantiateViewController(withIdentifier: "ImageSelect")as! ImageSelectViewController
        
        self.present(imageSelectViewController, animated: true, completion: nil)
    }
    
    
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var myHomeButton: UIButton!

    @IBOutlet weak var topImage: UIImageView!
    var postArray: [PostData] = []
    var listener: ListenerRegistration?
    var followArray: [Following] = []
    var selectedPostArray: [PostData] = []
    var notificationListener: ListenerRegistration?
    
    

    @IBAction func myHomeButton(_ sender: Any) {
        let myhomeViewController = (self.storyboard?.instantiateViewController(identifier: "My Home"))!
        present(myhomeViewController, animated: true, completion: nil)

    }

    @IBOutlet weak var notificationLabel: UIButton!

    @IBAction func notificationButton(_ sender: Any) {
        let notificationViewController = self.storyboard?.instantiateViewController(identifier: "Notification")
        present(notificationViewController!, animated: true, completion: nil)

    }




    var refreshControl: UIRefreshControl!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        newPost.layer.cornerRadius = 30
        newPost.layer.shadowOpacity = 0.7
        newPost.layer.shadowRadius = 3
        newPost.layer.shadowOffset = CGSize(width: 2, height: 2)
        
        tableView.delegate = self
        tableView.dataSource = self
        self.overrideUserInterfaceStyle = .light
        refreshControl = UIRefreshControl()
        refreshControl.attributedTitle = NSAttributedString(string: "読み込み中")
        refreshControl.addTarget(self, action: #selector(refresh), for: UIControl.Event.valueChanged)
        self.tableView.refreshControl = refreshControl
        tableView.addSubview(refreshControl)

        topImage.layer.cornerRadius = topImage.frame.size.width/2
        topImage.layer.borderWidth = 1
        topImage.layer.borderColor = #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1)
        topImage.clipsToBounds = true

        tableView.separatorColor = #colorLiteral(red: 0.09431516379, green: 0.2704899311, blue: 0.5240489244, alpha: 1)
        tableView.rowHeight = UITableView.automaticDimension
        
       


        let nib = UINib(nibName: "PostTableViewCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: "Cell")

       }


    @objc func refresh(){
        refreshControl.endRefreshing()
        tableView.reloadData()
    }


    override func viewDidAppear(_ animated: Bool) {
        self.overrideUserInterfaceStyle = .light
        let uid = Auth.auth().currentUser?.uid
        if uid == nil{
            let firstViewController = self.storyboard?.instantiateViewController(identifier: "Movie") as? FirstMovieViewController
            present(firstViewController!, animated: true, completion: nil)
        }


    }



    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        

        let uid2 = UserDefaults.standard.string(forKey: "uid")
        if uid2 != Auth.auth().currentUser?.uid {
            selectedPostArray.removeAll()
            tableView.reloadData()
            print("カウント\(selectedPostArray.count)")
        }
       


        print("DEBUG_PRINT: viewWillAppear")
        if Auth.auth().currentUser != nil{
            let settings = FirestoreSettings()
            settings.isPersistenceEnabled = false
            let db = Firestore.firestore()
            db.settings = settings
            let uid = Auth.auth().currentUser?.uid



            let followRef = db.collection(Const.FollowPath).document(uid!)
            followRef.getDocument{ (document, error) in
                if error != nil{
                    return
                }

                guard (document?.data()) != nil else { return }
                let followData = Following(document: document!)
                let updateCount = followData.count
                let stringCount:String = updateCount!.description
                let storageRef = Storage.storage().reference().child("profile_image").child(uid! + stringCount)
                self.topImage.sd_imageIndicator = SDWebImageActivityIndicator.gray
                self.topImage.sd_setImage(with: storageRef)
                if followData.follow.count > 0 {
                    let postRef = Firestore.firestore().collection(Const.PostPath).order(by: "date", descending: true).whereField("uid", in: followData.follow )

                    self.listener = postRef.addSnapshotListener(){ (querySnapshot, error) in
                        if let error = error{
                            print("DEBUG_PRINT: querySnapshotの取得が失敗しました。\(error)")
                            return
                        }
                        self.selectedPostArray = []
                        self.postArray = querySnapshot!.documents.map { document in
                            let postData = PostData(document: document)
                            self.selectedPostArray.append(postData)
                            print("ポストデータ\(postData)")
                            print("ポストアレイ\(self.postArray)")
                            return postData
                        }
                        self.tableView.reloadData()
                        if self.selectedPostArray.count == 0{
                            self.emptyLabel.isHidden = false
                            self.tableView.bringSubviewToFront(self.emptyLabel)
                            
                        }else {
                            self.emptyLabel.isHidden = true
                        }


                    }

                }


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
        cell.postDeleteButton.addTarget(self, action: #selector(postDeleteButton(_:forEvent:)), for: .touchUpInside)
        cell.postMap.addTarget(self, action: #selector(postMap(_:forEvent:)), for: .touchUpInside)
        cell.postUser.addTarget(self, action: #selector(postUser(_:forEvent:)), for: .touchUpInside)
        cell.mapButton.addTarget(self, action: #selector(postMap(_:forEvent:)), for: .touchUpInside)
        cell.reportButton.addTarget(self, action: #selector(reportButton(_:forEvent:)), for: .touchUpInside)
//        cell.goodDetail.addTarget(self, action: #selector(goodDetail(_:forEvent:)), for: .touchUpInside)
        
        return cell


    }
    
//    @objc func goodDetail(_ sender: UIButton, forEvent event: UIEvent){
//        print("いいね詳細")
//        let touch = event.allTouches?.first
//        let point = touch!.location(in: self.tableView)
//        let indexPath = tableView.indexPathForRow(at: point)
//        let postData = selectedPostArray[indexPath!.row]
//        let goodViewController = self.storyboard?.instantiateViewController(withIdentifier: "Heart") as! GoodViewController
//        
//        goodViewController.likes = postData.likes
//        goodViewController.postImage = postData.postImage!
//        self.present(goodViewController, animated: true, completion: nil)
//        
//        
//        
//    }
//    
   
    
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
            let popoverViewController = self.storyboard?.instantiateViewController(identifier: "popoverVC") as! PopoverViewController
            popoverViewController.userId = postData.uid
            self.present(popoverViewController, animated: true, completion: nil)
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
                let success = UINotificationFeedbackGenerator()
                success.notificationOccurred(.success)
            print("delete成功")

            }
            })



        alert.addAction(defaultAction)
        alert.addAction(cancelAction)
        present(alert, animated: true, completion: nil)

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

}




