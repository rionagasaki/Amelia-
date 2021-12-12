//
//  ViewController.swift
//  Instagram
//
//  Created by Rio Nagasaki on 2021/11/18.
//

import UIKit
import Firebase
import FirebaseStorageUI

class ViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout  {
    
    private let cellId = "cellId"
    private var Offset: CGPoint = .init(x: 0, y: 0)
    
    @IBOutlet weak var headerView: UIView!
    @IBOutlet weak var headerTop: NSLayoutConstraint!
    @IBOutlet weak var headerHight: NSLayoutConstraint!
    
    
    @IBOutlet weak var postCount: UILabel!
    @IBOutlet weak var scoreCount: UILabel!
    @IBOutlet weak var name: UILabel!
    
    @IBOutlet weak var textView: UITextView!
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return .init(width: 129, height: 190)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return selectedPostArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! FriendCollectionViewCell
        
        cell.layer.masksToBounds = false
        
        cell.layer.shadowOffset = CGSize(width: 0, height: 1)
        cell.layer.shadowOpacity = 0.5
        cell.layer.shadowRadius = 4
        
        
        cell.setPostData(selectedPostArray[indexPath.row])
        cell.postButton.addTarget(self, action: #selector(postButton(_:forEvent:)), for: .touchUpInside)
        return cell
    }
    var refreshControl: UIRefreshControl!
   
    
    
    @objc func postButton(_ sender: UIButton, forEvent event: UIEvent){
        let touch = event.allTouches?.first
        let point = touch!.location(in: self.collectionView)
        let indexPath = collectionView.indexPathForItem(at: point)
        let postData = selectedPostArray[indexPath!.row]
        
        
        
        
        
        let eachViewController = self.storyboard?.instantiateViewController(withIdentifier: "Each") as! EachViewController
        eachViewController.postId = postData.id
        self.present(eachViewController, animated: true, completion: nil)
        
        
        
    }
    
//    private var prevContentOffset: CGPoint = .init(x: 0, y: 0)
//
//    func scrollViewDidScroll(_ scrollView: UIScrollView) {
//        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5){
//            self.prevContentOffset = scrollView.contentOffset
//        }
//
//        if self.prevContentOffset.y < scrollView.contentOffset.y{
//            if headerTop.constant  <= -headerHight.constant{ return }
//            headerTop.constant -= 8
//
//
//        } else if self.prevContentOffset.y > scrollView.contentOffset.y {
//            if headerTop.constant >= 10 { return }
//            headerTop.constant += 10
//
//        }
//        
//        print("scrollView.contentOffset" , scrollView.contentOffset)
//    }
//
    var postArray:[PostData] = []
    var selectedPostArray:[PostData] = []
    var followArray:[Following] = []
    var listener: ListenerRegistration?
    
    var friendUid = ""
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    
    @IBAction func backButton(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    
    @IBOutlet weak var topImage: UIImageView!
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let followRef = Firestore.firestore().collection(Const.FollowPath).document(friendUid)
        followRef.getDocument{
            (document, error) in
            if error != nil {
                return
            }
            let followData = Following(document: document!)
            if followData.introduce != nil {
                self.textView.text = followData.introduce
            }
            self.name.text = followData.name
            self.scoreCount.text = "\(followData.score ?? 0)pt"
            
            let updateCount = followData.count
            let stringCount:String = updateCount!.description
            let storageRef = Storage.storage().reference().child("profile_image").child(self.friendUid + stringCount)
            self.topImage.sd_imageIndicator = SDWebImageActivityIndicator.gray
            self.topImage.sd_setImage(with: storageRef)
            
        }
        
        
        let postRef = Firestore.firestore().collection(Const.PostPath).order(by: "date", descending: true).whereField("uid", isEqualTo: friendUid)
        
        self.listener = postRef.addSnapshotListener(){
            (querySnapshot, error) in
            if error != nil {
                return
            }
            self.selectedPostArray = []
            self.postArray = querySnapshot!.documents.map{
                document in
                let postData = PostData(document: document)
                self.selectedPostArray.append(postData)
               
                self.postCount.text = "投稿数\(self.selectedPostArray.count)"
                
                return postData
            }
            self.collectionView.reloadData()
            
            
        }
        
        
        
        
    }
    
    @objc func refresh(){
        refreshControl.endRefreshing()
        collectionView.reloadData()
    }
    
    override func  viewWillDisappear(_ animated: Bool) {
        
        super.viewWillAppear(animated)
        print (" DEBUG_PRINT: viewWillDisappear")
        listener?.remove()
        self.collectionView.reloadData()
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.overrideUserInterfaceStyle = .light
        collectionView.delegate = self
        collectionView.dataSource = self
        
        self.textView.isEditable = false
        self.textView.isSelectable = false
        
        let layout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: 10, left: 30, bottom: 0, right: 30)
        collectionView.collectionViewLayout = layout
        
        textView.layer.borderWidth = 1
        textView.layer.borderColor = UIColor.black.cgColor
        
        topImage.layer.cornerRadius = topImage.frame.size.width/2
        topImage.layer.borderWidth = 1
        topImage.layer.borderColor = #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1)
        topImage.clipsToBounds = true
        
        refreshControl = UIRefreshControl()
        refreshControl.attributedTitle = NSAttributedString(string: "読み込み中")
        refreshControl.addTarget(self, action: #selector(refresh), for: UIControl.Event.valueChanged)
        self.collectionView.refreshControl = refreshControl
        collectionView.addSubview(refreshControl)
        
        
        let nib = UINib(nibName: "FriendCollectionViewCell", bundle: nil)
        collectionView.register(nib, forCellWithReuseIdentifier: cellId)
        
        
    }
    
    
    
    
}
