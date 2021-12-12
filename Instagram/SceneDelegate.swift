//
//  SceneDelegate.swift
//  Instagram
//
//  Created by Rio Nagasaki on 2021/09/21.
//

import UIKit
import Firebase
import SVProgressHUD
import LineSDK

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?


    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
//        userSetting(scene: scene)
       guard let _ = (scene as? UIWindowScene) else { return }
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.window = self.window
        
       
        
    }
    
//    func userSetting(scene: UIScene){
//        //ログインしているか確認
//        guard let myid = Auth.auth().currentUser?.uid else {
//            print("ログアウト状態")
//            loginFirstSegue(identifier: "Login", scene: scene)
//            return
//        }
//
//
//    }
//
//
//    func loginFirstSegue(identifier:String, scene:UIScene){
//        guard let uid = Auth.auth().currentUser?.uid  else{ return }
//        Firestore.firestore().collection(Const.FollowPath).document(uid).getDocument{ (document, error) in
//                         if error != nil {
//                             return
//                         }
//                         let followData = Following(document: document!)
//                         if followData.address == "" || followData.address == nil {
//                             SVProgressHUD.showSuccess(withStatus: "あなたについて教えてください。")
//                             let generator = UINotificationFeedbackGenerator()
//                             generator.notificationOccurred(.success)
//                             generator.prepare()
//                             let storyboard = UIStoryboard(name: "Adress", bundle: nil)
//
//                             let adressViewController = storyboard.instantiateViewController(withIdentifier: "Adress") as! AdressViewController
//                             let nav = UINavigationController(rootViewController: adressViewController)
//                             self.window?.rootViewController = nav
//                         } else {
//                             SVProgressHUD.showSuccess(withStatus: "ログインに成功しました。")
//                             let generator = UINotificationFeedbackGenerator()
//                             generator.notificationOccurred(.success)
//                             generator.prepare()
//                             print("DEBUG_PRINT: ログインに成功しました。")
//                             UIApplication.shared.windows.first{ $0.isKeyWindow }?.rootViewController?.dismiss(animated: true, completion: nil)
//
//                         }
//                     }
//    
//    }

    func sceneDidDisconnect(_ scene: UIScene) {
        // Called as the scene is being released by the system.
        // This occurs shortly after the scene enters the background, or when its session is discarded.
        // Release any resources associated with this scene that can be re-created the next time the scene connects.
        // The scene may re-connect later, as its session was not necessarily discarded (see `application:didDiscardSceneSessions` instead).
        try! Auth.auth().signOut()
        
       
        
    }
    
    func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>){
        _ = LoginManager.shared.application(.shared, open: URLContexts.first?.url)
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        // Called when the scene has moved from an inactive state to an active state.
        // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
    }

    func sceneWillResignActive(_ scene: UIScene) {
        // Called when the scene will move from an active state to an inactive state.
        // This may occur due to temporary interruptions (ex. an incoming phone call).
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
        // Called as the scene transitions from the background to the foreground.
        // Use this method to undo the changes made on entering the background.
        if let tabBarController = self.window?.rootViewController as? UITabBarController{
            
            let uid = Auth.auth().currentUser?.uid
            if uid != nil {
            let followRef = Firestore.firestore().collection(Const.FollowPath).document(uid!)
            followRef.getDocument{ (snap, error) in
                if error != nil {
                    return
                }
                let followData = Following(document: snap!)
                if followData.requested.count != 0 {
                    tabBarController.tabBar.items![2].badgeValue = "\(followData.requested.count)"
                }
                
            }
            }
            
            
            
            
        }
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        // Called as the scene transitions from the foreground to the background.
        // Use this method to save data, release shared resources, and store enough scene-specific state information
        // to restore the scene back to its current state.
    }
}




