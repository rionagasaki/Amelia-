//
//  ScrollViewController.swift
//  Instagram
//
//  Created by Rio Nagasaki on 2021/11/05.
//

import UIKit
import Lottie

class ScrollViewController: UIViewController {

    
    @IBAction func backButton(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
       
        let animationView = AnimationView(name: "79913-walk-man")
        animationView.frame = CGRect(x: 0, y: 0, width:300, height: 300)
        animationView.layer.position = CGPoint(x: self.view.frame.width/2, y:600 )
        animationView.contentMode = .scaleAspectFit
        animationView.loopMode = .loop
        animationView.play()
        
        view.addSubview(animationView)
        
        
    }
       
    

   
}
