//
//  SettingViewController.swift
//  Instagram
//
//  Created by Rio Nagasaki on 2021/09/21.
//

import UIKit
import Firebase
import SVProgressHUD
import FirebaseStorageUI
import Nuke
import MessageUI
import StoreKit

class SettingViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, MFMailComposeViewControllerDelegate {
    
    
   
    
    let firstImage = UIImageView(image: UIImage(named: "panda"))
    var postArray: [PostData] = []
    var postArray2: [PostData] = []
   
    
    @IBOutlet weak var displayNameTextField: UITextField!
    
    @IBAction func mailButton(_ sender: Any) {
        sendMail()
    }
    
    
    @IBAction func backButton(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    @IBOutlet weak var mailButton: UIButton!
    
    @IBOutlet weak var rankButton: UIButton!
    
    
    @IBOutlet weak var profileImage: UIButton!
    
    @IBOutlet weak var profileImageView: UIImageView!
    
    
    @IBAction func rankButton(_ sender: Any) {
        SKStoreReviewController.requestReview()
        
    }
    
    
    @IBAction func howtoButton(_ sender: Any) {
        let scrollViewController = self.storyboard?.instantiateViewController(withIdentifier: "HowTo") as! ScrollViewController
        self.present(scrollViewController, animated: true, completion: nil)
    }
    
    @IBOutlet weak var howTo: UIButton!
    
    
    @IBAction func LogoutButton(_ sender: Any) {
        let uid = Auth.auth().currentUser?.uid
        UserDefaults.standard.set(uid, forKey: "uid")
        try! Auth.auth().signOut()
        let loginViewController = self.storyboard?.instantiateViewController(identifier: "Login")
        self.present(loginViewController!, animated: true, completion: nil)
        tabBarController?.selectedIndex = 0
       
        }
    
    
    
    
    func sendMail(){
        if MFMailComposeViewController.canSendMail(){
            let mail = MFMailComposeViewController()
            mail.mailComposeDelegate = self
            mail.setToRecipients(["naga_ri@icloud.com"])
            mail.setSubject("[お問い合わせ]")
            mail.setMessageBody("Ameliaをご利用いただき、ありがとうございます。不具合、リクエスト等をお書きください。", isHTML: false)
            self.present(mail, animated: true, completion: nil)
        }else{
            SVProgressHUD.showError(withStatus: "送信可能なメールアドレスが見つかりません。")
            
            
        }
    }
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        if error != nil {
            print("error\(error)")
            SVProgressHUD.showError(withStatus: "メールの送信に失敗しました。")
        }else{
            switch result {
            case .saved:
                SVProgressHUD.showSuccess(withStatus: "下書き保存しました。")
            case .sent:
                SVProgressHUD.showSuccess(withStatus: "メールの送信に成功しました。")
            default: break
                
            }
            controller.dismiss(animated: true, completion: nil)
        }
        
    }
    
    
    
    
    @IBAction func profileButton(_ sender: Any) {
        
        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary){
            let imagePickerController = UIImagePickerController()
            imagePickerController.delegate = self
            imagePickerController.sourceType = .photoLibrary
            imagePickerController.allowsEditing = true
            self.present(imagePickerController, animated: true, completion: nil)
        }
        
        
        
    }
    
    
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        let uid = Auth.auth().currentUser?.uid
        let countRef = Firestore.firestore().collection(Const.FollowPath).document(uid!)
        countRef.getDocument{ [self] (snap, error) in
            if error != nil {
                print("errorです")
                return
            }
            let followData = Following(document: snap!)
            let updateCount = followData.count! + 1
            let Ref = Firestore.firestore().collection(Const.FollowPath).document(uid!)
            Ref.updateData(["count": updateCount])
            let reduceCount = updateCount - 1
            let stringReduce: String = reduceCount.description
            let stringCount:String = updateCount.description
            if let editImage = info[.editedImage] as? UIImage{
                self.profileImageView.image = editImage
            }else if let originalImage = info[.originalImage] as? UIImage{
                profileImageView.image = originalImage
                
            }
          
            guard let image = profileImageView.image else { return }
            let imageData = image.jpegData(compressionQuality: 0.75)
            let storageRef = Storage.storage().reference().child("profile_image")
            let StorageRef = storageRef.child(uid! + stringCount)
            let StorageRef2 = storageRef.child(uid! + stringReduce)
            StorageRef2.delete{
                error in
                if error != nil {
                    print("エラーでした")
                    return
                }
                print("delete成功")
            }
            
            if imageData != nil{
                let metadata = StorageMetadata()
                metadata.contentType = "image/jpeg"
                StorageRef.putData(imageData!, metadata: metadata){
                    (metadata, err) in
                    print("fireStorageへの保存成功")
                    if err != nil {
                        print("FireStorageへの保存失敗")
                        return
                    }
                    StorageRef.downloadURL{ [self] (url, error) in
                        if error != nil {
                            return
                        }
                        
                        guard let urlString = url?.absoluteString else {return}
                        let uid = Auth.auth().currentUser?.uid
                        let imageRef = Firestore.firestore().collection(Const.FollowPath).document(uid!)
                        imageRef.updateData(["profileImage": urlString])
                        print("URL\(urlString)")
                        
                        print("firestoreへの保存に成功した")
                        
                        let postRef = Firestore.firestore().collection(Const.PostPath)
                        postRef.getDocuments{ (querySnapshot, error) in
                            if error != nil {
                                fatalError("errorです")
                            }
                            guard let querySnapshot = querySnapshot else { return }
                            
                            self.postArray = querySnapshot.documents.map{ document in
                                let uid2 = Auth.auth().currentUser?.uid
                                let postData = PostData(document: document)
                                if postData.uid == uid2{
                                    print("ポストID\(postData.id)")
                                    postRef.document(postData.id).updateData(["profileImage": urlString])
                                    
                                }
                                return postData
                            }
                            
                        }
                        
                    }
                    print("firestoreへの保存に成功した")
                    
                    
                    self.dismiss(animated: true, completion: nil)
                    
                }
                
                
            }
        }
    }
    
    @IBAction func ChangeButton(_ sender: Any) {
        if let displayName = displayNameTextField.text{
            if displayName.isEmpty{
                SVProgressHUD.showError(withStatus: "新しい名前を入力して下さい")
                return
            }
            let user = Auth.auth().currentUser
            if let user = user{
                let changeRequest = user.createProfileChangeRequest()
                changeRequest.displayName = displayName
                changeRequest.commitChanges{
                    error in
                    if let error = error{
                        SVProgressHUD.showError(withStatus: "名前の変更に失敗しました")
                        print("DEBUG_PRINT: " + error.localizedDescription)
                        return
                    }
                    let uid = Auth.auth().currentUser?.uid
                    let nameRef = Firestore.firestore().collection(Const.FollowPath).document(uid!)
                    nameRef.updateData(["name": user.displayName!])
                    let postRef = Firestore.firestore().collection(Const.PostPath).whereField("uid", isEqualTo: uid!)
                    postRef.getDocuments{ (querySnapshot, error) in
                        if error != nil {
                            print("errorです")
                            return
                        }
                        self.postArray2 = querySnapshot!.documents.map{
                            document in
                            let postData = PostData(document: document)
                            let postRef2 = Firestore.firestore().collection(Const.PostPath).document(postData.id)
                            postRef2.updateData(["name": user.displayName!])
                            return postData
                        }
                        
                    }
                    
                    print("DEBUG_PRINT: [displayName = \(user.displayName!)]の設定に成功しました。")
                    SVProgressHUD.showSuccess(withStatus: "名前の変更に成功しました")
                }
            }
        }
        self.view.endEditing(true)
        
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if #available(iOS 13.0, *) {
                presentingViewController?.beginAppearanceTransition(false, animated: animated)
            
        }
        let user = Auth.auth().currentUser
        if let user = user{
            displayNameTextField.text = user.displayName
            let uid = Auth.auth().currentUser?.uid
            let ref = Firestore.firestore().collection(Const.FollowPath).document(uid!)
            ref.getDocument{
                (snap, error) in
                if error != nil {
                    print("error2です")
                    return
                }
                let followData = Following(document: snap!)
                let updateCount = followData.count
                let stringCount:String = updateCount!.description
                let storageRef = Storage.storage().reference().child("profile_image").child(uid! + stringCount)
                self.profileImageView.sd_imageIndicator = SDWebImageActivityIndicator.gray
                self.profileImageView.sd_setImage(with: storageRef)
            }
            
        }
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if #available(iOS 13.0, *) {

            presentingViewController?.beginAppearanceTransition(true, animated: animated)
            presentingViewController?.endAppearanceTransition()
        }
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if #available(iOS 13.0, *) {
            presentingViewController?.endAppearanceTransition()
        }
    }
    
    @IBOutlet weak var nameButton: UIButton!
    @IBOutlet weak var logoutButton: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        nameButton.layer.cornerRadius = 15.0
        logoutButton.layer.cornerRadius = 15.0
        
        mailButton.layer.cornerRadius = 15.0
        rankButton.layer.cornerRadius = 15.0
        howTo.layer.cornerRadius = 15.0
        
        profileImage.layer.cornerRadius = profileImage.frame.size.width/2
        profileImage.layer.borderWidth = 1
        profileImage.layer.borderColor = #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1)
        profileImage.clipsToBounds = true
        
        profileImageView.layer.cornerRadius = 170/2
        profileImageView.layer.borderWidth = 1
        profileImageView.layer.borderColor = #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1)
        profileImageView.clipsToBounds = true
        
        
        
    }
    
    
}



