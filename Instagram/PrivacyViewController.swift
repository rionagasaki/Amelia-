//
//  PrivacyViewController.swift
//  Instagram
//
//  Created by Rio Nagasaki on 2021/11/24.
//

import UIKit

class PrivacyViewController: UIViewController {
    
    
    @IBOutlet weak var textView: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.overrideUserInterfaceStyle = .light
        self.textView.isEditable = false
        self.textView.isSelectable = false
      
    }
    @IBAction func backButton(_ sender: Any) {
        dismiss(animated: true, completion: nil)
        
    }
    
    

  

}
