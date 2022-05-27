//
//  PopoverViewController.swift
//  Instagram
//
//  Created by Rio Nagasaki on 2021/12/14.
//

import UIKit
import Firebase
import FirebaseStorageUI

class PopoverViewController: UIViewController {
    
    var name = ""
    var image = ""
    var userId = ""

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.7)
        // Do any additional setup after loading the view.
        imageView.layer.cornerRadius = imageView.frame.size.width/2
        imageView.layer.borderWidth = 1
        imageView.layer.borderColor = #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1)
        imageView.clipsToBounds = true
    }
    @IBAction func backButton(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBOutlet weak var imageView: UIImageView!
    
    @IBOutlet weak var nameLabel: UILabel!
    
    
    
    @IBAction func deleteButton(_ sender: Any) {
        let myid = Auth.auth().currentUser?.uid
        var updateValue: FieldValue
                    var updateValue2: FieldValue
        updateValue = FieldValue.arrayRemove([myid!])
                    updateValue2 = FieldValue.arrayRemove([userId])
                    let followRef = Firestore.firestore().collection(Const.FollowPath).document(userId)
                    followRef.updateData(["follow": updateValue])
                    let followRef2 = Firestore.firestore().collection(Const.FollowPath).document(myid!)
                    followRef2.updateData(["follow": updateValue2])
        
        self.dismiss(animated: true, completion: nil)
        
    }
    override func viewWillAppear(_ animated: Bool) {
        
        let followRef = Firestore.firestore().collection(Const.FollowPath).document(userId)
        followRef.getDocument{ (document, error) in
            if error != nil{
                return
            }

            guard (document?.data()) != nil else { return }
        let followData = Following(document: document!)
        let updateCount = followData.count
            self.nameLabel.text = followData.name
        let stringCount:String = updateCount!.description
            let storageRef = Storage.storage().reference().child("profile_image").child(self.userId + stringCount)
        self.imageView.sd_imageIndicator = SDWebImageActivityIndicator.gray
        self.imageView.sd_setImage(with: storageRef)
        }
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
