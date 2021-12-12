//
//  Comment.swift
//  Instagram
//
//  Created by Rio Nagasaki on 2021/10/22.
//

import UIKit
import Firebase

class Comment: NSObject {
    var name: String?
    var profileImage: String?
    var comment: String?
    var id: String
    var postID: String?
    var uid: String?
    var date: Date?
    
    init(document: QueryDocumentSnapshot){
        
        self.id = document.documentID
        
        
        let commentDic = document.data()
        self.postID = commentDic["postID"]as? String
        self.uid = commentDic["uid"]as? String
        let timestamp = commentDic["date"]as? Timestamp
        self.date = timestamp?.dateValue()
        
        self.name = commentDic["name"]as? String
        self.profileImage = commentDic["profileImage"]as? String
        self.comment = commentDic["comment"]as? String
        

}
}
