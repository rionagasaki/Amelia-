//
//  PostData.swift
//  Instagram
//
//  Created by Rio Nagasaki on 2021/09/22.
//

import UIKit
import Firebase

class PostData: NSObject {
    
    var id: String
    var name: String?
    var caption: String?
    var date: Date?
    var likes: [String] = []
    var isLiked: Bool = false
    var comment: String?
    var Latitude: String
    var Longitude: String
    var uid: String!
    var profileImage: String?
    var star: Double!
    var placeMark: String!
    var count: String?
    var postImage: String?
    var challenge_uid: [String] = []
    
    init(document: QueryDocumentSnapshot){
        self.id = document.documentID
        
        
        
        let postDic = document.data()
        
        self.name = postDic["name"]as? String
        self.caption = postDic["caption"]as? String
        self.comment = postDic["comment"]as? String
        self.Latitude = postDic["latitude"]as! String
        self.Longitude = postDic["longitude"]as! String
        self.profileImage = postDic["profileImage"] as? String
        self.postImage = postDic["postImage"] as? String
        self.placeMark = (postDic["placeMark"]as! String)
        self.count = postDic["count"]as? String
        
        let timestamp = postDic["date"]as? Timestamp
        self.date = timestamp?.dateValue()
        
        if let likes = postDic["likes"]as? [String]{
            self.likes = likes
        }
        
        if let challenge_uid = postDic["challenge_uid"]as? [String]{
            self.challenge_uid = challenge_uid
        }
        
        self.uid = postDic["uid"]as? String
        
        self.star = postDic["star"]as? Double
        
        
        
        if let myid = Auth.auth().currentUser?.uid{
            if self.likes.firstIndex(of: myid) != nil{
                self.isLiked = true
            }
        }
        
        
    }
    
    
    
    init(document: DocumentSnapshot){
        self.id = document.documentID
        
        
        
        let postDic = document.data()!
        
        self.name = postDic["name"]as? String
        self.caption = postDic["caption"]as? String
        self.comment = postDic["comment"]as? String
        self.Latitude = postDic["latitude"]as! String
        self.Longitude = postDic["longitude"]as! String
        self.profileImage = postDic["profileImage"] as? String
        self.postImage = postDic["postImage"] as? String
        self.placeMark = (postDic["placeMark"]as! String)
        self.count = postDic["count"]as? String
        
        let timestamp = postDic["date"]as? Timestamp
        self.date = timestamp?.dateValue()
        
        if let likes = postDic["likes"]as? [String]{
            self.likes = likes
        }
        
        if let challenge_uid = postDic["challenge_uid"]as? [String]{
            self.challenge_uid = challenge_uid
        }
        
        self.uid = postDic["uid"]as? String
        
        self.star = postDic["star"]as? Double
        
        
        
        if let myid = Auth.auth().currentUser?.uid{
            if self.likes.firstIndex(of: myid) != nil{
                self.isLiked = true
            }
        }
        
        
    }
    
    
    
}






