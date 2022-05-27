//
//  MenuViewController.swift
//  Instagram
//
//  Created by Rio Nagasaki on 2021/12/15.
//

import UIKit
import Firebase
import FirebaseStorageUI

class MenuViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.7)
        imageView.layer.cornerRadius = imageView.frame.size.width/2
        imageView.layer.borderWidth = 1
        imageView.layer.borderColor = #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1)
        imageView.clipsToBounds = true
        // Do any additional setup after loading the view.
    }
    
    @IBAction func backButton(_ sender: Any) {
        dismiss(animated: true, completion: nil)
        
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let uid = Auth.auth().currentUser?.uid
        let db = Firestore.firestore()
        let followRef = db.collection(Const.FollowPath).document(uid!)
        followRef.getDocument{ (document, error) in
            if error != nil{
                return
            }

            guard (document?.data()) != nil else { return }
            let followData = Following(document: document!)
            let updateCount = followData.count
            self.nameLabel.text = followData.name
            let stringCount:String = updateCount!.description
            let storageRef = Storage.storage().reference().child("profile_image").child(uid! + stringCount)
            self.imageView.sd_imageIndicator = SDWebImageActivityIndicator.gray
            self.imageView.sd_setImage(with: storageRef)
    }
    }
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    
    
    @IBAction func cancelButton(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func friendButton(_ sender: Any) {
        let friendViewController = self.storyboard?.instantiateViewController(withIdentifier: "GoodFriend")as! FriendViewController
        
        self.present(friendViewController, animated: true, completion: nil)
    }
    
    @IBAction func requestButton(_ sender: Any) {
        let requestedViewController = self.storyboard?.instantiateViewController(withIdentifier: "Request")as! RequestedViewController
        
        self.present(requestedViewController, animated: true, completion: nil)
    }
    
    
}
