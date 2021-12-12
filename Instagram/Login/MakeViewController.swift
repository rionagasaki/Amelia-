//
//  MakeViewController.swift
//  Instagram
//
//  Created by Rio Nagasaki on 2021/12/02.
//

import UIKit
import SVProgressHUD
import Firebase
import AuthenticationServices
import CryptoKit


class MakeViewController: UIViewController,ASAuthorizationControllerDelegate, ASAuthorizationControllerPresentationContextProviding {
    
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
    
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        return view.window!
    }
    
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
   
    
    @objc func appleIDButtonpush(){
        if MakeField.text == "" {
            SVProgressHUD.showError(withStatus: "ユーザー名の入力をしてから、行ってください。")
            return
            
        }
        let request = ASAuthorizationAppleIDProvider().createRequest()
        request.requestedScopes = [.fullName, .email]
        let controller = ASAuthorizationController(authorizationRequests: [request])
        controller.delegate = self
        controller.presentationContextProvider = self
        controller.performRequests()
        startSignInAppleFlow()
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
                
                let fullName = appleIDCredential.fullName
                let user = appleIDCredential.user
                if fullName != nil {
                print("\(fullName!)です１。")
                }
                
               
                    print("\(user)です２")
                
                
                
                
                
                let email = Auth.auth().currentUser?.email
               
                    let uid = Auth.auth().currentUser?.uid
                    let storageRef = Storage.storage().reference().child("profile_image").child(uid! + "0")
                    let panda = UIImage(named: "panda")
                    let imageData = panda!.jpegData(compressionQuality: 0.75)
                    storageRef.putData(imageData!)
                
             
                    let postDic = [
                        "name": self.MakeField.text!,
                        "email": email!,
                        "follow": [uid!],
                        "score": 0,
                        "count": 0
                    ]  as [String: Any]
                    Firestore.firestore().collection(Const.FollowPath).document(uid!).setData(postDic)
                    
                    SVProgressHUD.showSuccess(withStatus: "Ameliaへようこそ！")
                    let generator = UINotificationFeedbackGenerator()
                    generator.notificationOccurred(.success)
                    
                    
                    
                   
                
                UIApplication.shared.windows.first{ $0.isKeyWindow }?.rootViewController?.dismiss(animated: true, completion: nil)

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
       
        signInButton.frame = CGRect(x: CGFloat(widthGap), y: 540, width: 300, height: 40)
       
    }
    
    

    override func viewDidLoad() {
        super.viewDidLoad()
       
//        signInButton.translatesAutoresizingMaskIntoConstraints = false
        signInButton.addTarget(self, action: #selector(appleIDButtonpush), for: .touchUpInside)
        view.addSubview(signInButton)
//        startSignInAppleFlow()
        
        self.overrideUserInterfaceStyle = .light
        
        
        let tapGR: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
               tapGR.cancelsTouchesInView = false
               self.view.addGestureRecognizer(tapGR)
        
        terms.layer.cornerRadius = 15.0
        privacy.layer.cornerRadius = 15.0
        makeAccount.layer.cornerRadius = 15.0
        makeAccount.alpha = 0.9
        
        makeAccount.layer.shadowOffset = CGSize(width: 0.0, height: 2.0)
        makeAccount.layer.shadowColor = UIColor.black.cgColor
        makeAccount.layer.shadowOpacity = 0.5
        makeAccount.layer.shadowRadius = 4
        
        
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
