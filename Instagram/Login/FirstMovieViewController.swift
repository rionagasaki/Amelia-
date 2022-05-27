
//
//  FirstMovieViewController.swift
//  Instagram
//
//  Created by Rio Nagasaki on 2021/12/14.
//

import UIKit
import  AVFoundation

class FirstMovieViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        

//        let path = Bundle.main.path(forResource: "pexels-rodnae-productions-5848367", ofType: "mp4")!
//        let player = AVPlayer(url: URL(fileURLWithPath: path))
//        player.play()
//
//
//
//        let playerLayer = AVPlayerLayer(player: player)
//        playerLayer.frame = view.bounds
//        playerLayer.videoGravity = .resizeAspectFill
//        playerLayer.zPosition = -1
//        view.layer.insertSublayer(playerLayer, at: 0)
//
//        let playerObserver = NotificationCenter.default.addObserver(
//                   forName: .AVPlayerItemDidPlayToEndTime,
//                   object: player.currentItem,
//                   queue: .main) { [weak playerLayer] _ in
//                       playerLayer?.player?.seek(to: CMTime.zero)
//                       playerLayer?.player?.play()
//               }

        self.overrideUserInterfaceStyle = .light

//        let label = UILabel(frame: CGRect(x: 0, y: 100, width: 400, height: 40))
//        label.text = "Welcome to Amelia!"
//        label.textColor = .white
//        label.font = UIFont.boldSystemFont(ofSize: 25)
//        label.textAlignment = .center
//        label.center.x = view.center.x
//        label.autoresizingMask = [.flexibleWidth, .flexibleBottomMargin]
//        view.addSubview(label)
//

        let loginButton = UIButton(frame: .init(x: 30, y: view.frame.height - 150, width: view.frame.width - 60, height: 50))
        loginButton.setTitle("ログイン", for: .normal)
        loginButton.setTitleColor(.white, for: .normal)
        loginButton.layer.borderWidth = 1
        loginButton.layer.borderColor = UIColor.purple.cgColor
        loginButton.backgroundColor = UIColor.purple
        loginButton.layer.cornerRadius = 23.0
        loginButton.autoresizingMask = [.flexibleWidth, .flexibleTopMargin]
        view.addSubview(loginButton)
        loginButton.addTarget(self, action: #selector(loginButton(_:forEvent:)), for: .touchUpInside)

        let signupButton = UIButton(frame: loginButton.frame)
        signupButton.frame.origin.y = loginButton.frame.minY - 60
        signupButton.setTitle("アカウント作成", for: .normal)
        signupButton.setTitleColor(.white, for: .normal)
        signupButton.backgroundColor = UIColor.purple
        signupButton.layer.cornerRadius = 23.0
        signupButton.autoresizingMask = [.flexibleWidth, .flexibleTopMargin]
        view.addSubview(signupButton)
        signupButton.addTarget(self, action: #selector(signupButton(_:forEvent:)), for: .touchUpInside)
        
       
    }
    
    @objc func loginButton(_ sender: UIButton, forEvent event: UIEvent){
        let loginViewController = self.storyboard?.instantiateViewController(withIdentifier: "Login") as! LoginViewController
        
        self.present(loginViewController, animated: true, completion: nil)
    }
    
    @objc func signupButton(_ sender: UIButton, forEvent event: UIEvent){
        let makeViewController = self.storyboard?.instantiateViewController(withIdentifier: "Make") as! MakeViewController
        
        self.present(makeViewController, animated: true, completion: nil)
    }
    
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
