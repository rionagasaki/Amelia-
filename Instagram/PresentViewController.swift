//
//  PresentViewController.swift
//  Instagram
//
//  Created by Rio Nagasaki on 2021/11/04.
//

import UIKit
import Lottie
import MessageUI
import SVProgressHUD
import Firebase

class PresentViewController: UIViewController, MFMailComposeViewControllerDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()
        self.overrideUserInterfaceStyle = .light
        let animationView = AnimationView(name: "42172-presents")
        animationView.frame = CGRect(x: 0, y: 100, width: 300, height: 300)
        animationView.center = view.center
        animationView.contentMode = .scaleAspectFit
        animationView.loopMode = .loop
        animationView.play()
        animationView.backgroundBehavior = .pauseAndRestore
        
        view.addSubview(animationView)
    }
    
    @IBAction func presentButton(_ sender: Any) {
        sendMail()
    }
    
    
    func sendMail(){
        let uid = Auth.auth().currentUser?.uid
        let ref = Firestore.firestore().collection(Const.FollowPath).document(uid!)
        ref.getDocument{ (documentSnapshot, error) in
            if error != nil {
                return
            }
            let followData = Following(document: documentSnapshot!)
            let name = followData.name
        if MFMailComposeViewController.canSendMail(){
            let mail = MFMailComposeViewController()
            mail.mailComposeDelegate = self
            mail.setToRecipients(["naga_ri@icloud.com"])
            mail.setSubject("[1000円プレゼント_\(name!)様]")
            mail.setMessageBody("Ameliaをご利用いただき、ありがとうございます。Amazonギフト券1000円分贈呈いたしますので、このメール送信後,しばらくお待ちください。これからもご利用よろしくお願いします。(uid \(uid!)", isHTML: false)
            self.present(mail, animated: true, completion: nil)
        }else{
            SVProgressHUD.showError(withStatus: "送信可能なメールアドレスが見つかりません。")
            
            
        }
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
                SVProgressHUD.showSuccess(withStatus: "プレゼントリクエストの送信に成功しました。")
            default: break
                
            }
            controller.dismiss(animated: true, completion: nil)
        }
        dismiss(animated: true, completion: nil)
    }
    
    

}
