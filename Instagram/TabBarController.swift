//
//  TabBarController.swift
//  Instagram
//
//  Created by Rio Nagasaki on 2021/09/21.
//

import UIKit
import Firebase

class TabBarController: UITabBarController, UITabBarControllerDelegate{

    override func viewDidLoad() {
        super.viewDidLoad()
        self.tabBar.tintColor = #colorLiteral(red: 0.3374766707, green: 0.9088003039, blue: 0.9015392661, alpha: 1)
        self.tabBar.barTintColor = .purple
        if #available(iOS 15.0, *){
            let appearance = UITabBarAppearance()
            appearance.backgroundColor = .purple
            UITabBar.appearance().scrollEdgeAppearance = appearance
            UITabBar.appearance().standardAppearance = appearance
            
        }
        
        self.delegate = self
        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if Auth.auth().currentUser == nil{
            let loginViewController = self.storyboard?.instantiateViewController(identifier: "Login")
            self.present(loginViewController!, animated: true, completion: nil)
        }
    }
    
    
    
    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
        if viewController is ImageSelectViewController{
            let imageSelectViewController = storyboard?.instantiateViewController(identifier: "ImageSelect")
            self.present(imageSelectViewController!, animated: true)
            return true
        }else{
            return true
        }
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
