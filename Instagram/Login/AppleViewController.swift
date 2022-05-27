//
//  AppleViewController.swift
//  Instagram
//
//  Created by Rio Nagasaki on 2021/12/21.
//

import UIKit
import SVProgressHUD
import Firebase
import AuthenticationServices
import CryptoKit

class AppleViewController: UIViewController,ASAuthorizationControllerDelegate, ASAuthorizationControllerPresentationContextProviding {

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
    
    @objc func appleIDButtonpush(){
        if textField.text == "" {
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
    
    
    
    @IBOutlet weak var textField: UITextField!
    
    @IBOutlet weak var cancelButton: UIButton!
    
    
    
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
                
                    let uid = Auth.auth().currentUser?.uid
                    let storageRef = Storage.storage().reference().child("profile_image").child(uid! + "0")
                    let panda = UIImage(named: "panda")
                    let imageData = panda!.jpegData(compressionQuality: 0.75)
                    storageRef.putData(imageData!)
                
             
                    let postDic = [
                        "name": self.textField.text!,
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
       
        signInButton.frame = CGRect(x: CGFloat(widthGap), y: 430, width: 300, height: 40)
       
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        cancelButton.layer.cornerRadius = 15.0
        self.overrideUserInterfaceStyle = .light
        signInButton.addTarget(self, action: #selector(appleIDButtonpush), for: .touchUpInside)
        view.addSubview(signInButton)
        view.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.7)
    
        
    }
    
    
    
    @IBAction func cancel(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
   

}
