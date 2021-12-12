//
//  PostVViewController.swift
//  Instagram
//
//  Created by Rio Nagasaki on 2021/09/21.
//

import UIKit
import Firebase
import SVProgressHUD
import MapKit
import CoreLocation
import Cosmos

class PostViewController: UIViewController, UITextViewDelegate{
    var image: UIImage!
    var latitude = ""
    var longitude = ""
    var placeMark = ""
    
    
    @IBOutlet weak var wordCountLabel: UILabel!
    
    @IBOutlet weak var handlePost: UIButton!
    
    @IBOutlet weak var handleLocation: UIButton!
    
    @IBOutlet weak var handleCancel: UIButton!
    
    @IBOutlet weak var ImageView: UIImageView!
    
    @IBOutlet weak var postContent: UITextView!
    
    @IBOutlet weak var place: UILabel!
    
    
    @IBOutlet weak var touchRating: CosmosView!
    
    var Star:Double?
    
    @IBAction func handlePostButton(_ sender: Any) {
        print("OK2")
        print(self.latitude)
        print(self.longitude)
        
        if latitude == "" || longitude == ""{
            SVProgressHUD.showError(withStatus: "位置情報を取得してね")
            return
            
        }
        
        if self.Star == nil {
            SVProgressHUD.showError(withStatus: "評価を入力してね")
            return
        }
        
        let imageData = self.image.jpegData(compressionQuality: 0.75)
        let postRef = Firestore.firestore().collection(Const.PostPath).document()
        
        let imageRef = Storage.storage().reference().child(Const.ImagePath).child(postRef.documentID + ".jpg")
        
        SVProgressHUD.show()
        let metadata = StorageMetadata()
        metadata.contentType = "image/jpeg"
        imageRef.putData(imageData!, metadata: metadata){(metadata, error) in
            if error != nil{
                print(error!)
                SVProgressHUD.showSuccess(withStatus: "画像のアップロードが失敗しました")
                UIApplication.shared.windows.first{ $0.isKeyWindow }?.rootViewController?.dismiss(animated: true, completion: nil)
                return
            }
            let name = Auth.auth().currentUser?.displayName
            let uid = Auth.auth().currentUser?.uid
            let dbRef = Firestore.firestore().collection(Const.FollowPath).document(uid!)
            dbRef.getDocument{ (snap, error) in
                if error != nil {
                    print("errorです")
                }
                
                
                let followData = Following(document: snap!)
                let updateCount = followData.count
                let stringCount:String = updateCount!.description
                
                let ref = Storage.storage().reference().child("profile_image").child(uid! + stringCount)
                ref.downloadURL{ (url, error) in
                    if error != nil {
                        return
                    }
                    imageRef.downloadURL{
                        (url2, error) in
                        if error != nil{
                            return
                        }
                        
                        
                        guard let urlString2 = url2?.absoluteString else { return }
                        
                        
                        guard let urlString = url?.absoluteString else {return}
                        
                        let postDic = [
                            "name": name!,
                            "caption": self.postContent.text!,
                            "profileImage": urlString ,
                            "latitude": self.latitude,
                            "longitude": self.longitude,
                            "postImage": urlString2,
                            "uid": uid!,
                            "placeMark": self.placeMark,
                            "star": self.Star as Any,
                            "date": FieldValue.serverTimestamp()]
                            as [String: Any]
                        postRef.setData(postDic)
                        let generator = UINotificationFeedbackGenerator()
                        generator.notificationOccurred(.success)
                        print("firestoreです\(postDic)")
                        
                      
                        
                    }
                    
                    SVProgressHUD.showSuccess(withStatus: "投稿しました")
                    
                    print("postRef\(self.placeMark)")
                    UIApplication.shared.windows.first{ $0.isKeyWindow }?.rootViewController?.dismiss(animated: true, completion: nil)
                }
            }
        }
    }
    
    
    
    
    
    @IBAction func handleLocation(_ sender: Any) {
        let mapSearchViewController = self.storyboard?.instantiateViewController(identifier: "Location")as! MapSearchViewController
        
        self.present(mapSearchViewController, animated: true, completion: nil)
        
        
    }
   
    let textLength = 80
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        let existingLines = postContent.text.components(separatedBy: .newlines)
        let newLines = text.components(separatedBy: .newlines)
        let lineAfterChange = existingLines.count + newLines.count - 1
        return lineAfterChange <= 5 && postContent.text.count + (text.count - range.length) <= textLength
    }
    
    func textViewDidChange(_ textView: UITextView) {
        print("OK!")
        let existingLines = postContent.text.components(separatedBy: .newlines)
        if existingLines.count <= 5 {
            self.wordCountLabel.text = "\(postContent.text.count)/\(textLength)"
        }
    }
    

    
   @IBAction func handleCancelButton(_ sender: Any) {
        
        
        self.dismiss(animated:  true, completion: nil)
    }
    
    
    func star(){
        touchRating.didFinishTouchingCosmos = {
            [self] rating in
                self.Star = rating
           
        }
        
        touchRating.didTouchCosmos = { rating in
            let generator = UINotificationFeedbackGenerator()
            generator.notificationOccurred(.warning)
            generator.prepare()
        }
    }
    
    
    
    
    
    @objc func dismissKeyboard() {
           self.view.endEditing(true)
       }
    
   
    
 
    
    override func viewDidLoad() {
        super.viewDidLoad()
        ImageView.image = image
        touchRating.settings.starSize = 30
        self.overrideUserInterfaceStyle = .light
        ImageView.layer.borderWidth = 3
        ImageView.layer.borderColor = UIColor.orange.cgColor
        postContent.layer.borderWidth = 3
        postContent.layer.borderColor = UIColor.orange.cgColor
        
        handlePost.layer.cornerRadius = 15.0
        handleLocation.layer.cornerRadius = 15.0
        handleCancel.layer.cornerRadius = 15.0
        
      
       
        
        let tapGR: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
               tapGR.cancelsTouchesInView = false
               self.view.addGestureRecognizer(tapGR)
       
            postContent.delegate = self
        star()
            
        }
        
       
    }
    
    
    
    

