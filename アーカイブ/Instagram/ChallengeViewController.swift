//
//  ChallengeViewController.swift
//  Instagram
//
//  Created by Rio Nagasaki on 2021/10/24.
//

import UIKit
import Firebase
import SVProgressHUD

class ChallengeViewController: UIViewController {
    
    

 
    @IBOutlet weak var computerImage: UIImageView!
    @IBOutlet weak var resultLabel: UILabel!
    @IBOutlet weak var rock: UIButton!
    @IBOutlet weak var scissors: UIButton!
    @IBOutlet weak var paper: UIButton!
    
    
    
    @IBOutlet weak var userImage: UIImageView!
    @IBAction func stoneButton(_ sender: Any) {
        let randomNum = Int.random(in: 0..<3)
        userImage.image = UIImage(named: "0")
        let random:String = randomNum.description
        computerImage.image = UIImage(named: random)
        result()
        
    }
    @IBAction func ScissorsButton(_ sender: Any) {
        let randomNum = Int.random(in: 0..<3)
        userImage.image = UIImage(named: "2")
        let random:String = randomNum.description
        computerImage.image = UIImage(named: random)
        result()
        
        
    }
    
    @IBAction func paperButton(_ sender: Any) {
        let randomNum = Int.random(in: 0..<3)
        userImage.image = UIImage(named: "1")
        let random:String = randomNum.description
        computerImage.image = UIImage(named: random)
        result()
        
    }
    
    @IBAction func backButton(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.rock.isEnabled = true
        self.scissors.isEnabled = true
        self.paper.isEnabled = true
        self.rock.isHidden = false
        self.scissors.isHidden = false
        self.paper.isHidden = false
        resultLabel.text = "グー、チョキ、パー、どれかを選んでね！"
        computerImage.image = UIImage(named: "0")
        let uid = Auth.auth().currentUser?.uid
        let checkRef = Firestore.firestore().collection(Const.FollowPath).document(uid!)
        checkRef.getDocument{
            (query, error) in
            if error != nil {
                return
            }
            let followData = Following(document: query!)
            print("スコア\(followData.score!)")
            
        }
        
        
        
    }
    
    func result(){
      
           if computerImage.image == UIImage(named: "0") {
            if userImage.image == UIImage(named: "0"){
                resultLabel.text = "あいこだよ、もう一回！"
                
            }else if
                
                    userImage.image == UIImage(named: "1") {
                    resultLabel.text = "勝ち！おめでとう！"
                
                let uid = Auth.auth().currentUser?.uid
                let resultRef = Firestore.firestore().collection(Const.FollowPath).document(uid!)
                resultRef.getDocument{
                    (query, error)in
                    if error != nil {
                        return
                    }
                    
                    let followData = Following(document: query!)
                    print("score\(followData.score ?? 0)")
                    let updateScore = followData.score! + 1
                    if followData.score != 14 {
                    resultRef.updateData(["score": updateScore])
                        SVProgressHUD.showSuccess(withStatus: "1ポイント加算されたよ！")
                        self.rock.isEnabled = false
                        self.scissors.isEnabled = false
                        self.paper.isEnabled = false
                        self.rock.isHidden = true
                        self.scissors.isHidden = true
                        self.paper.isHidden = true
                    } else {
                        resultRef.updateData(["score": updateScore])
                        SVProgressHUD.showSuccess(withStatus: "おめでとう！！ 30ポイント達成です！！")
                        let presentViewController = self.storyboard?.instantiateViewController(withIdentifier: "Present") as! PresentViewController
                        self.present(presentViewController, animated: true, completion: nil)
                    }
                }
               
                    
                
            }else if
                        userImage.image == UIImage(named: "2"){
                        resultLabel.text = "残念！また投稿スポットへ行こう！"
                let uid = Auth.auth().currentUser?.uid
                let resultRef = Firestore.firestore().collection(Const.FollowPath).document(uid!)
                resultRef.getDocument{
                    (snap, error)in
                    if error != nil {
                        return
                    }
                    let followData = Following(document: snap!)
                    let updateScore = followData.score! - 1
                    if followData.score != 0 {
                    resultRef.updateData(["score": updateScore])
                        SVProgressHUD.showSuccess(withStatus: "1ポイント減少したよ。")
                        self.rock.isEnabled = false
                        self.scissors.isEnabled = false
                        self.paper.isEnabled = false
                        self.rock.isHidden = true
                        self.scissors.isHidden = true
                        self.paper.isHidden = true
                    }
                }
               
                SVProgressHUD.showSuccess(withStatus: "マイナスできるポイントがないよ。")
                self.rock.isEnabled = false
                self.scissors.isEnabled = false
                self.paper.isEnabled = false
                self.rock.isHidden = true
                self.scissors.isHidden = true
                self.paper.isHidden = true
                
            }
            
           }else if computerImage.image == UIImage(named: "1") {
            if userImage.image == UIImage(named: "0"){
                resultLabel.text = "残念！また投稿スポットへ行こう！"
                let uid = Auth.auth().currentUser?.uid
                let resultRef = Firestore.firestore().collection(Const.FollowPath).document(uid!)
                resultRef.getDocument{
                    (query, error)in
                    if error != nil {
                        return
                    }
                    let followData = Following(document: query!)
                    let updateScore = followData.score! - 1
                    if followData.score != 0{
                    resultRef.updateData(["score": updateScore])
                        SVProgressHUD.showSuccess(withStatus: "1ポイント減少したよ。")
                        self.rock.isEnabled = false
                        self.scissors.isEnabled = false
                        self.paper.isEnabled = false
                        self.rock.isHidden = true
                        self.scissors.isHidden = true
                        self.paper.isHidden = true
                    } else{
                        SVProgressHUD.showSuccess(withStatus: "マイナスできるポイントがないよ。")
                        self.rock.isEnabled = false
                        self.scissors.isEnabled = false
                        self.paper.isEnabled = false
                        self.rock.isHidden = true
                        self.scissors.isHidden = true
                        self.paper.isHidden = true
                    }
                }
            } else if userImage.image == UIImage(named: "1"){
                resultLabel.text = "あいこだよ、もう一回！"
            }else if userImage.image == UIImage(named: "2"){
                resultLabel.text = "勝ち！おめでとう！"
                let uid = Auth.auth().currentUser?.uid
                let resultRef = Firestore.firestore().collection(Const.FollowPath).document(uid!)
                resultRef.getDocument{
                    (query, error)in
                    if error != nil {
                        return
                    }
                    let followData = Following(document: query!)
                    let updateScore = followData.score! + 1
                    if followData.score != 14{
                    resultRef.updateData(["score": updateScore])
                        SVProgressHUD.showSuccess(withStatus: "1ポイント加算されたよ！")
                        self.rock.isEnabled = false
                        self.scissors.isEnabled = false
                        self.paper.isEnabled = false
                        self.rock.isHidden = true
                        self.scissors.isHidden = true
                        self.paper.isHidden = true
                    } else {
                        resultRef.updateData(["score": updateScore])
                        SVProgressHUD.showSuccess(withStatus: "おめでとう！！30ポイント達成です！")
                        let presentViewController = self.storyboard?.instantiateViewController(withIdentifier: "Present") as! PresentViewController
                        self.present(presentViewController, animated: true, completion: nil)
                    }
                }
               
               
            }
            
           }else if computerImage.image == UIImage(named: "2"){
            if userImage.image == UIImage(named: "0"){
                resultLabel.text = "勝ち！おめでとう！"
                let uid = Auth.auth().currentUser?.uid
                let resultRef = Firestore.firestore().collection(Const.FollowPath).document(uid!)
                resultRef.getDocument{
                    (query, error)in
                    if error != nil {
                        return
                    }
                    let followData = Following(document: query!)
                    let updateScore = followData.score! + 1
                    if followData.score != 14 {
                    resultRef.updateData(["score": updateScore])
                        SVProgressHUD.showSuccess(withStatus: "1ポイント加算されたよ！")
                        self.rock.isEnabled = false
                        self.scissors.isEnabled = false
                        self.paper.isEnabled = false
                        self.rock.isHidden = true
                        self.scissors.isHidden = true
                        self.paper.isHidden = true
                    }else {
                        resultRef.updateData(["score": updateScore])
                        SVProgressHUD.showSuccess(withStatus: "おめでとう！！30ポイント達成です！！")
                        let presentViewController = self.storyboard?.instantiateViewController(withIdentifier: "Present") as! PresentViewController
                        self.present(presentViewController, animated: true, completion: nil)
                        
                    }
                }
               
            }else if userImage.image == UIImage(named: "1"){
                resultLabel.text = "残念！また投稿スポットへ行こう！"
                let uid = Auth.auth().currentUser?.uid
                let resultRef = Firestore.firestore().collection(Const.FollowPath).document(uid!)
                resultRef.getDocument{
                    (query, error)in
                    if error != nil {
                        return
                    }
                    let followData = Following(document: query!)
                    let updateScore = followData.score! - 1
                    if followData.score != 0{
                    resultRef.updateData(["score": updateScore])
                        SVProgressHUD.showSuccess(withStatus: "1ポイント減少したよ。")
                        self.rock.isEnabled = false
                        self.scissors.isEnabled = false
                        self.paper.isEnabled = false
                        self.rock.isHidden = true
                        self.scissors.isHidden = true
                        self.paper.isHidden = true
                    }
                    else{
                        SVProgressHUD.showSuccess(withStatus: "マイナスできるポイントがないよ。")
                        self.rock.isEnabled = false
                        self.scissors.isEnabled = false
                        self.paper.isEnabled = false
                        self.rock.isHidden = true
                        self.scissors.isHidden = true
                        self.paper.isHidden = true
                    }
                }
               
            }else if userImage.image == UIImage(named: "2"){
                resultLabel.text = "あいこだよ、もう一回！"
            }
           }
        }
        
        
    
    
    

   

}
