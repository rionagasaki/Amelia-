//
//  LoginViewController.swift
//  Instagram
//
//  Created by Rio Nagasaki on 2021/09/21.
//

import UIKit
import Firebase
import SVProgressHUD
import AppTrackingTransparency
import AdSupport
import FirebaseFunctions


class LoginViewController: UIViewController {
    @IBOutlet weak var MailField: UITextField!
    
    @IBOutlet weak var PassField: UITextField!
    
    @IBOutlet weak var MakeField: UITextField!
    
    @IBOutlet weak var loginButton: UIButton!
    
    @IBOutlet weak var makingButton: UIButton!
    
    
    var followArray: [Following] = [Following]()
    var listener: ListenerRegistration?
    
    @IBAction func LoginButton(_ sender: Any) {
        if let address = MailField.text, let password = PassField.text{
            if address.isEmpty || password.isEmpty{
                SVProgressHUD.showError(withStatus: "何かが空文字です。")
                return
            }
            
            try! Auth.auth().signOut()
            
            Auth.auth().signIn(withEmail: address, password: password){ authResult, error in
                if let error = error as? NSError {
                    switch AuthErrorCode(rawValue: error.code) {
                    case .operationNotAllowed:
                        print("operationNotAllowed: " + error.localizedDescription)
                    case .userDisabled:
                        print("userDisabled: " + error.localizedDescription)
                    case .wrongPassword:
                        print("wrongPassword: " + error.localizedDescription)
                    case .invalidEmail:
                        print("invalidEmail: " + error.localizedDescription)
                    default:
                        print("Error: \(error.localizedDescription)")
                }
                }
                    
                SVProgressHUD.showSuccess(withStatus: "ログインに成功しました。")
                print("DEBUG_PRINT: ログインに成功しました。")
                self.dismiss(animated: true, completion: nil)
           
            }
                
        }
    }
    
    let firstImage = UIImageView(image: UIImage(named: "panda"))
    
    
    
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
                Auth.auth().languageCode = "ja_JP"
                Auth.auth().currentUser?.sendEmailVerification{ (mail) in
                    
                                                                print("DEBUG_PRINT: ユーザー作成に成功しました。")}
                
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
                        SVProgressHUD.showSuccess(withStatus: "認証メールを送信しました。")
                       
                        
                        }
                }
                
                }
                
            
        }
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loginButton.layer.cornerRadius = 15.0
        makingButton.layer.cornerRadius = 15.0
        ATTrackingManager()
       
        let functions = Functions.functions()
        functions.httpsCallable("Hello world").call(["text": "テスト"]){result, error in
            if let error = error as NSError?{
               print("予期せぬエラーが発生しました\(error)")
            }
            if let data = result?.data as? [String: Any],let text = data["text"]as? String{
                print("data\(data),text\(text)")
            }
        }
       
        
        
       
    }
    
    
    
}
extension LoginViewController {
    private func ATTrackingManager (){
        
        if #available(iOS 14, *) {
            switch AppTrackingTransparency.ATTrackingManager.trackingAuthorizationStatus {
            case .authorized:
                print("Allow Tracking")
                print("IDFA: \(ASIdentifierManager.shared().advertisingIdentifier)")
            case .denied:
                print("😭拒否")
            case .restricted:
                print("🥺制限")
            case .notDetermined:
                showRequestTrackingAuthorizationAlert()
            @unknown default:
                fatalError()
            }
        } else {// iOS14未満
            if ASIdentifierManager.shared().isAdvertisingTrackingEnabled {
                print("Allow Tracking")
                print("IDFA: \(ASIdentifierManager.shared().advertisingIdentifier)")
            } else {
                print("🥺制限")
            }
        }
    }
    
    private func showRequestTrackingAuthorizationAlert() {
        if #available(iOS 14, *) {
            AppTrackingTransparency.ATTrackingManager.requestTrackingAuthorization(completionHandler: { status in
                switch status {
                case .authorized:
                    print("🎉")
                    //IDFA取得
                    print("IDFA: \(ASIdentifierManager.shared().advertisingIdentifier)")
                case .denied, .restricted, .notDetermined:
                    print("😭")
                @unknown default:
                    fatalError()
                }
            })
        }
    }
    
}

