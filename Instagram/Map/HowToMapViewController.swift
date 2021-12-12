//
//  HowToMapViewController.swift
//  Instagram
//
//  Created by Rio Nagasaki on 2021/11/06.
//

import UIKit
import Lottie
import MessageUI
import SVProgressHUD


class HowToMapViewController: UIViewController, MFMailComposeViewControllerDelegate {
    
    
    
    @IBOutlet weak var sendMail: UIButton!
    
    
    @IBAction func sendMailButton(_ sender: Any) {
        
        sendMail2()
    }
    
    func sendMail2(){
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
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.overrideUserInterfaceStyle = .light
        sendMail.layer.cornerRadius = 15.0
        let animationView = AnimationView(name: "78072-map-pin-location")
        animationView.frame = CGRect(x: 0, y: 0, width:300, height: 300)
        animationView.layer.position = CGPoint(x: self.view.frame.width/2, y:600 )
        animationView.contentMode = .scaleAspectFit
        animationView.loopMode = .repeat(2)
        animationView.backgroundBehavior = .pauseAndRestore
        animationView.play()
        
        view.addSubview(animationView)
        
    }
    
    
    @IBAction func backButton(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    

}
