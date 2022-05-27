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
import AuthenticationServices
import CryptoKit



class LoginViewController: UIViewController,ASAuthorizationControllerDelegate, ASAuthorizationControllerPresentationContextProviding{
    
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        return view.window!
    }
    
    var followArray: [Following] = []
    var selectedFollowArray: [Following] = []
    
    @IBOutlet weak var MailField: UITextField!
    
    @IBOutlet weak var PassField: UITextField!
    
   
    
    @IBOutlet weak var loginButton: UIButton!
    
   

    
    
    
    var listener: ListenerRegistration?
    
    fileprivate var currentNonce: String?
    
    private func randomNonceString(length: Int = 32)-> String{
        precondition(length > 0)
        let charset : Array<Character> = Array("0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxya-._")
        var result = ""
        var remainingLength = length
        
        while remainingLength > 0 {
            let randoms: [UInt8] = (0..<16).map { _ in
                var random: UInt8 = 0
                let errorCode = SecRandomCopyBytes(kSecRandomDefault, 1, &random)
                if errorCode != errSecSuccess{
                    fatalError("appleサインイン中、予期せぬ挙動。")
                }
                return random
            }
            randoms.forEach { random in
            if remainingLength == 0 {
                return
            }
                if random < charset.count {
                    result.append(charset[Int(random)])
                    remainingLength -= 1
                }
            
            }
            
        }
        return result
        
    }
    
    
    
    @available(iOS 13, *)
    func startSignInAppleFlow() {
        let nonce = randomNonceString()
        currentNonce = nonce
        let appleIDProvider = ASAuthorizationAppleIDProvider()
        let request = appleIDProvider.createRequest()
         request.requestedScopes = [.fullName, .email]
         request.nonce = sha256(nonce)

         let authorizationController = ASAuthorizationController(authorizationRequests: [request])
         authorizationController.delegate = self
         authorizationController.presentationContextProvider = self
         authorizationController.performRequests()
       }

       @available(iOS 13, *)
       private func sha256(_ input: String) -> String {
         let inputData = Data(input.utf8)
         let hashedData = SHA256.hash(data: inputData)
         let hashString = hashedData.compactMap {
           return String(format: "%02x", $0)
         }.joined()

         return hashString
    }
    private let signInButton = ASAuthorizationAppleIDButton()
    
    @objc func appleIDButtonpush(){
        let request = ASAuthorizationAppleIDProvider().createRequest()
        request.requestedScopes = [.email, .fullName]
        let controller = ASAuthorizationController(authorizationRequests: [request])
        controller.delegate = self
        controller.presentationContextProvider = self
        controller.performRequests()
        startSignInAppleFlow()
    }
    
    
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
                    SVProgressHUD.showError(withStatus: "ログインに失敗しました。")
                    return
                }
//                        let settings = FirestoreSettings()
//                        settings.isPersistenceEnabled = false
//                        Firestore.firestore().collection(Const.FollowPath).firestore.settings = settings
//                let uid = Auth.auth().currentUser?.uid
//                Firestore.firestore().collection(Const.FollowPath).document(uid!).getDocument{ (document, error) in
//                    if error != nil {
//                        return
//                    }
//
                        SVProgressHUD.showSuccess(withStatus: "Amelia!へようこそ。")
                        let generator = UINotificationFeedbackGenerator()
                        generator.notificationOccurred(.success)
                        generator.prepare()
                        print("DEBUG_PRINT: ログインに成功しました。")
                UIApplication.shared.windows.first{ $0.isKeyWindow }?.rootViewController?.dismiss(animated: true, completion: nil)
                   
                   
                        
                    }
                    
                
                    
            }
                
        }
    
  
    
    
    @available(iOS 13.0, *)
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        if let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential{
            guard let nonce = currentNonce else {
                print("currentNonce\(currentNonce ?? "")")
                fatalError("appleでサインイン中に予期せぬエラー２")
            }
            guard let appleIDToken = appleIDCredential.identityToken else {
                return
            }
            guard let idTokenString = String(data: appleIDToken, encoding: .utf8) else {
                return
            }
            let credential = OAuthProvider.credential(withProviderID: "apple.com", idToken: idTokenString, rawNonce: nonce)
            
            
            Auth.auth().signIn(with: credential){ (authResult, error) in
                if error != nil {


                    print(error?.localizedDescription)
                    return
                }
                let email = Auth.auth().currentUser?.email
                let mailRef = Firestore.firestore().collection(Const.FollowPath).whereField("email", isEqualTo: email!)
                mailRef.getDocuments{ (snap, error) in
                    if error != nil {
                        return
                    }
                    if snap?.documents.count == 0 {
                        let user = Auth.auth().currentUser
                        user?.delete{ error in
                            if error != nil {
                                return
                            }
                            print("deleteしました")
                        }
                        try! Auth.auth().signOut()
                        SVProgressHUD.showError(withStatus: "アカウントエラー")
                      
                    }else {
                        SVProgressHUD.showSuccess(withStatus: "Ameliaへようこそ。")
                             let generator = UINotificationFeedbackGenerator()
                             generator.notificationOccurred(.success)
                             
                             
                             
                            
                         
                         UIApplication.shared.windows.first{ $0.isKeyWindow }?.rootViewController?.dismiss(animated: true, completion: nil)
                    }
                    
                }
                
              

                }
                
                
            }
                   




    }
    
    
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        print("appleでサインイン中に予期せぬエラー3\(error)")
    }

    
    
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
       
        let width = Float(UIScreen.main.bounds.width)
        let widthGap = (width - Float(signInButton.frame.width))/2
        self.signInButton.cornerRadius = 15.0
       
        signInButton.frame = CGRect(x: CGFloat(widthGap), y: 450, width: 300, height: 40)
       
    }
    
    
    
    
    let firstImage = UIImageView(image: UIImage(named: "panda"))
    
    
    
//    @IBAction func MakeButton(_ sender: Any) {
//        if let address = MailField.text, let password = PassField.text, let displayName = MakeField.text{
//            if address.isEmpty || password.isEmpty || displayName.isEmpty{
//                print("DEBUG_PRINT: 何かが空文字です。")
//                SVProgressHUD.showError(withStatus: "必要項目を入力して下さい")
//                return
//            }
//            SVProgressHUD.show()
//
//            Auth.auth().createUser(withEmail: address, password: password){ authResult, error in
//                if let error = error {
//                    print("DEBUG_PRINT: " + error.localizedDescription)
//                    SVProgressHUD.showError(withStatus: "ユーザー作成に失敗しました。")
//                    return
//                    }
//
//
//                let user = Auth.auth().currentUser
//                if let user = user{
//                    let changeRequest = user.createProfileChangeRequest()
//                    changeRequest.displayName = displayName
//                    let uid = Auth.auth().currentUser?.uid
//                    let storageRef = Storage.storage().reference().child("profile_image").child(uid! + "0")
//                    let panda = UIImage(named: "panda")
//                    let imageData = panda!.jpegData(compressionQuality: 0.75)
//                    storageRef.putData(imageData!)
//
//                    let postDic = [
//                        "name": self.MakeField.text!,
//                        "email": address,
//                        "follow": [uid!],
//                        "score": 0,
//                        "count": 0
//                    ]  as [String: Any]
//                    Firestore.firestore().collection(Const.FollowPath).document(uid!).setData(postDic)
//
//                    changeRequest.commitChanges{
//                        error in
//                        if let error = error{
//                            print("DEBUG_PRINT " + error.localizedDescription)
//                            SVProgressHUD.showError(withStatus: "表示名の設定に失敗しました。")
//                            return
//                        }
//                        print("DEBUG_PRINT: [displayName = \(user.displayName!)の設定に成功しました。]")
//                        SVProgressHUD.showSuccess(withStatus: "アカウント作成に成功しました。ログインしてください。")
//                        let generator = UINotificationFeedbackGenerator()
//                        generator.notificationOccurred(.success)
//
//                        }
//                }
//
//                }
//
//
//        }
//
//    }
//
//
    

    
    
    @IBOutlet weak var privacy: UIButton!
    @IBOutlet weak var terms: UIButton!

   
    @IBAction func termsButton(_ sender: Any) {
        let termsViewController = storyboard?.instantiateViewController(withIdentifier: "Terms") as! TermsViewController
        
        present(termsViewController, animated: true, completion: nil)
        
    }
    
    @IBAction func privacyButton(_ sender: Any) {
        let privacyViewController = storyboard?.instantiateViewController(withIdentifier: "Privacy") as! PrivacyViewController
        
        present(privacyViewController, animated: true, completion: nil)
        
        
    }
    
    
    @IBAction func makeButton(_ sender: Any) {
        let makeViewController = self.storyboard?.instantiateViewController(withIdentifier: "Make") as! MakeViewController
        
        self.present(makeViewController, animated: true, completion: nil)
    }
    
    
    @objc func dismissKeyboard() {
           self.view.endEditing(true)
       }
    
//    func loginButton(_ button: LoginButton, didSucceedLogin loginResult: LoginResult) {
//            hideIndicator()
//            print("Login Succeeded.")
//        }
//
//        func loginButton(_ button: LoginButton, didFailLogin error: LineSDKError) {
//            hideIndicator()
//            print("Error: \(error)")
//        }
//
//        func loginButtonDidStartLogin(_ button: LoginButton) {
//            showIndicator()
//            print("Login Started.")
//        }
//
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        signInButton.addTarget(self, action: #selector(appleIDButtonpush), for: .touchUpInside)
        view.addSubview(signInButton)
//        let loginButton = LineSDK.LoginButton()
//           loginButton.delegate = self
//
//           // Configuration for permissions and presenting.
//           loginButton.permissions = [.profile]
//           loginButton.presentingViewController = self
//
//           // Add button to view and layout it.
//           view.addSubview(loginButton)
//           loginButton.translatesAutoresizingMaskIntoConstraints = false
//           loginButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
//           loginButton.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        self.overrideUserInterfaceStyle = .light
//        loginButton.layer.cornerRadius = 15.0
//
        terms.layer.cornerRadius = 15.0
      
        privacy.layer.cornerRadius = 15.0
        loginButton.layer.cornerRadius = 15.0
        
        loginButton.layer.shadowOffset = CGSize(width: 0.0, height: 2.0)
        loginButton.layer.shadowColor = UIColor.black.cgColor
        loginButton.layer.shadowOpacity = 0.5
        loginButton.layer.shadowRadius = 4
        loginButton.alpha = 0.9
        
        
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
        
       
        ATTrackingManager()
        
        
        
        let tapGR: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
               tapGR.cancelsTouchesInView = false
               self.view.addGestureRecognizer(tapGR)
       
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

