//
//  Notification.swift
//  Instagram
//
//  Created by Rio Nagasaki on 2021/10/23.
//

import UIKit
import Firebase

class Notification: NSObject {
    
    var name: String?
    var profileImage: String?
    var notification: String?
    var id: String?
    var postID: String?
    var postImage: String?
    var uid: String?
    var uid2: String?
    var date: Date?
    
    
    init(document: QueryDocumentSnapshot){
        self.id = document.documentID
        let notificationDic = document.data()
        
        self.name = notificationDic["name"]as? String
        self.profileImage = notificationDic["profileImage"]as?
        String
        
        
        self.uid = notificationDic["notification"]as? String
        
        let timestamp = notificationDic["date"]as? Timestamp
        self.date = timestamp?.dateValue()
        
        self.uid2 = notificationDic["notification"]as? String
        
        self.notification = notificationDic["notification"]as? String
        
        self.postImage = notificationDic["postImage"] as? String
        
        self.postID = notificationDic["postID"]as? String
        
    }
    

}
