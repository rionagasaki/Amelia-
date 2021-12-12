//
//  MyFavorite.swift
//  Instagram
//
//  Created by Rio Nagasaki on 2021/11/26.
//

import UIKit
import Firebase

class MyFavorite: NSObject {
    
    var placeMark: String!
    var profileImage: String?
    var uid: String?
    var id: String?
    
    
    init(document: QueryDocumentSnapshot){
        
        let favoriteDic = document.data()
        self.placeMark = favoriteDic["placeMark"]as? String
        self.id = document.documentID
        self.uid = favoriteDic["uid"]as? String
        self.profileImage = favoriteDic["profileImage"]as? String
     
        

}

}
