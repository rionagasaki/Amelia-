//
//  MakeViewController.swift
//  Instagram
//
//  Created by Rio Nagasaki on 2021/12/02.
//

import UIKit
import SVProgressHUD
import Firebase



class MakeViewController: UIViewController {
    
    
    
    
    @IBOutlet weak var apple: UIButton!
    @IBOutlet weak var terms: UIButton!
    @IBOutlet weak var privacy: UIButton!
    @IBOutlet weak var makeAccount: UIButton!
    
    @IBOutlet weak var MailField: UITextField!
    
    @IBOutlet weak var PassField: UITextField!
    
    @IBOutlet weak var MakeField: UITextField!
    
//    @IBOutlet weak var appleButton: UIButton!
    
    
    @IBAction func termsButton(_ sender: Any) {
        let termsViewController = storyboard?.instantiateViewController(withIdentifier: "Terms") as! TermsViewController
        
        present(termsViewController, animated: true, completion: nil)
        
    }
    
   
    @IBAction func appleButton(_ sender: Any) {
        let appleViewController = self.storyboard?.instantiateViewController(withIdentifier: "Apple") as! AppleViewController
        
        self.present(appleViewController, animated: true, completion: nil)
        
    }
    
  
    
    @IBAction func privacyButton(_ sender: Any) {
        let privacyViewController = storyboard?.instantiateViewController(withIdentifier: "Privacy") as! PrivacyViewController
        
        present(privacyViewController, animated: true, completion: nil)
        
        
    }
    
    @objc func dismissKeyboard() {
           self.view.endEditing(true)
       }
    
    @IBAction func LoginButton(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func MakeButton(_ sender: Any) {
        if let address = MailField.text, let password = PassField.text, let displayName = MakeField.text{
            if address.isEmpty || password.isEmpty || displayName.isEmpty{
                print("DEBUG_PRINT: 何かが空文字です。")
                SVProgressHUD.showError(withStatus: "必要項目を入力して下さい")
                return
            }
            SVProgressHUD.show()
            
            Auth.auth().createUser(withEmail: address, password: password){ authResult, error in
                if let error = error {
                    print("DEBUG_PRINT: " + error.localizedDescription)
                    SVProgressHUD.showError(withStatus: "ユーザー作成に失敗しました。")
                    return
                    }
              
                
                let user = Auth.auth().currentUser
                if let user = user{
                    let changeRequest = user.createProfileChangeRequest()
                    changeRequest.displayName = displayName
                    let uid = Auth.auth().currentUser?.uid
                    let storageRef = Storage.storage().reference().child("profile_image").child(uid! + "0")
                    let panda = UIImage(named: "panda")
                    let imageData = panda!.jpegData(compressionQuality: 0.75)
                    storageRef.putData(imageData!)
                    let postDic = [
                        "name": self.MakeField.text!,
                        "email": address,
                        "follow": [uid!],
                        "score": 0,
                        "count": 0
                    ]  as [String: Any]
                    Firestore.firestore().collection(Const.FollowPath).document(uid!).setData(postDic)
                    
                    changeRequest.commitChanges{
                        error in
                        if let error = error{
                            print("DEBUG_PRINT " + error.localizedDescription)
                            SVProgressHUD.showError(withStatus: "表示名の設定に失敗しました。")
                            return
                        }
                        print("DEBUG_PRINT: [displayName = \(user.displayName!)の設定に成功しました。]")
                        SVProgressHUD.showSuccess(withStatus: "アカウント作成に成功しました。ログインしてください。")
                        let generator = UINotificationFeedbackGenerator()
                        generator.notificationOccurred(.success)
                        
                        }
                }
                
                }
                
            
        }
        
    }
    
    
    
    
    
    
    

    override func viewDidLoad() {
        super.viewDidLoad()
       
//        signInButton.translatesAutoresizingMaskIntoConstraints = false
       
//        startSignInAppleFlow()
        
        self.overrideUserInterfaceStyle = .light
        
        
        let tapGR: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
               tapGR.cancelsTouchesInView = false
               self.view.addGestureRecognizer(tapGR)
        
        apple.layer.cornerRadius = 15.0
        apple.alpha = 0.9
        
        terms.layer.cornerRadius = 15.0
        privacy.layer.cornerRadius = 15.0
        makeAccount.layer.cornerRadius = 15.0
        makeAccount.alpha = 0.9
        
        makeAccount.layer.shadowOffset = CGSize(width: 0.0, height: 2.0)
        makeAccount.layer.shadowColor = UIColor.black.cgColor
        makeAccount.layer.shadowOpacity = 0.5
        makeAccount.layer.shadowRadius = 4
        
        apple.layer.shadowOffset = CGSize(width: 0.0, height: 2.0)
        apple.layer.shadowColor = UIColor.black.cgColor
        apple.layer.shadowOpacity = 0.5
        apple.layer.shadowRadius = 4
        
        
        
        terms.layer.shadowOffset = CGSize(width: 0.0, height: 2.0)
        terms.layer.shadowColor = UIColor.black.cgColor
        terms.layer.shadowOpacity = 0.5
        terms.layer.shadowRadius = 4
        terms.alpha = 0.9
        
        
        privacy.layer.shadowOffset = CGSize(width: 0.0, height: 2.0)
        privacy.layer.shadowColor = UIColor.black.cgColor
        privacy.layer.shadowOpacity = 0.5
        privacy.layer.shadowRadius = 4
        privacy.alpha = 0.9

        
        
        
    }
    

   
}
//extension ASAuthorization.Scope {
//    public static let fullName: ASAuthorization.Scope
//    public static let email: ASAuthorization.Scope
//
//}
