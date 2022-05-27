//
//  Following.swift
//  Instagram
//
//  Created by Rio Nagasaki on 2021/10/07.
//

import UIKit
import Firebase



class Following: NSObject {
    
    var name: String?
    var email: String?
    //var address: String?
    var id: String = ""
    var profileImage: String?
    var count: Int?
    var requested:[String] = []
    var requesting:[String] = []
    var follow:[String] = []
    var isFollowed: Bool!
    var score: Int?
    var introduce: String?
    
    
    
    init(document: QueryDocumentSnapshot){
        self.id = document.documentID
        let postDic = document.data()
        
        
        self.name = postDic["name"]as? String
        self.email = postDic["email"]as? String
        
        if let request = postDic["requested"]as? [String]{
            self.requested = request
        }
        
        self.introduce = postDic["introduce"]as? String
        //self.address = postDic["address"]as? String
        
        if let request2 = postDic["requesting"]as? [String]{
            self.requesting = request2
        }
        
        if let follow = postDic["follow"]as? [String]{
            self.follow = follow
        }
        self.score = postDic["score"]as? Int
        
        
        self.profileImage = postDic["profileImage"]as? String
        self.count = postDic["count"]as? Int
        
        
        if let myid = Auth.auth().currentUser?.uid{
            if self.requested.firstIndex(of: myid) != nil{
                self.isFollowed = true
                print("true")
                return
                
            }else{
                self.isFollowed = false
                return
            }
        }
        
    }
    
    
    init(document: DocumentSnapshot){
        self.id = document.documentID
        
        if document.data() == nil{
            try! Auth.auth().signOut()
            return
        }
            
        
        let postDic = document.data()!
        
        self.name = (postDic["name"]as! String)
        
        self.email = (postDic["email"]as! String)
        self.introduce = postDic["introduce"]as? String
        
       // self.address = (postDic["address"]as! String)
        
        if let request = postDic["requested"]as? [String]{
            self.requested = request
        }
        
        if let request2 = postDic["requesting"]as? [String]{
            self.requesting = request2
        }
        
        self.count = postDic["count"]as? Int
        
        self.score = postDic["score"]as? Int
        
        
        if let follow = postDic["follow"]as? [String]{
            self.follow = follow
        }
        
        
        self.profileImage = postDic["profileImage"]as? String
        
    }
    
    
    
    
    
}
