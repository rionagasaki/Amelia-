//
//  AppDelegate.swift
//  Instagram
//
//  Created by Rio Nagasaki on 2021/09/21.
//

import UIKit
import Firebase
import LineSDK
import FirebaseMessaging
import UserNotifications

@main
class AppDelegate: UIResponder, UIApplicationDelegate, MessagingDelegate, UNUserNotificationCenterDelegate {
   
    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        LoginManager.shared.setup(channelID: "1656710951", universalLinkURL: nil)
        
        FirebaseApp.configure()
        
        
//        let settings = FirestoreSettings()
//        settings.isPersistenceEnabled = false
//        Firestore.firestore().collection(Const.FollowPath).firestore.settings = settings
//        Messaging.messaging().delegate = self
//        
//        Messaging.messaging().token { token, error in
//          if let error = error {
//            print("Error fetching FCM registration token: \(error)")
//          } else if let token = token {
//            print("FCM registration token: \(token)")
//              
//          }
//        }
        
        if #available(iOS 10.0, *) {
//                   // For iOS 10 display notification (sent via APNS)
//                   UNUserNotificationCenter.current().delegate = self
//
//                   let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
//                   UNUserNotificationCenter.current().requestAuthorization(
//                       options: authOptions,
//                       completionHandler: {_, _ in })
//               } else {
//                   let settings: UIUserNotificationSettings =
//                       UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil)
//                   application.registerUserNotificationSettings(settings)
//               }
//
//               application.registerForRemoteNotifications()
//        // Override point for customization after application launch.
        return true
    }
    }
    
    
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
//            //MARK:FCMToken
              print("Firebase registration token: \(fcmToken ?? "NoData")")
    }

    

       


    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }
//
    
    

    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        return LoginManager.shared.application(app, open: url)
        
    }
    
    

   

}

//@available(iOS 10, *)
//extension AppDelegate : UNUserNotificationCenterDelegate {
//   func userNotificationCenter(_ center: UNUserNotificationCenter,
//                               willPresent notification: UNNotification,
//                               withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
//       let userInfo = notification.request.content.userInfo
//
//       if let messageID = userInfo["gcm.message_id"] {
//           print("Message ID: \(messageID)")
//       }
//
//       print(userInfo)
//
//       completionHandler([])
//   }
//
//   func userNotificationCenter(_ center: UNUserNotificationCenter,
//                               didReceive response: UNNotificationResponse,
//                               withCompletionHandler completionHandler: @escaping () -> Void) {
//       let userInfo = response.notification.request.content.userInfo
//       if let messageID = userInfo["gcm.message_id"]{
//           print("Message ID: \(messageID)")
//       }
//
//       print(userInfo)
//
//       completionHandler()
//   }
//}
//
//

