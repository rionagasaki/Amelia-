//
//  FriendCollectionViewCell.swift
//  Instagram
//
//  Created by Rio Nagasaki on 2021/12/03.
//

import UIKit
import Cosmos
import FirebaseStorageUI
import Firebase


class FriendCollectionViewCell: UICollectionViewCell {
    
    var postArray: [PostData] = []

    @IBOutlet weak var postImage: UIImageView!
    
    @IBOutlet weak var userRank: CosmosView!
    
    @IBOutlet weak var postButton: UIButton!
    
    @IBAction func postGoButton(_ sender: Any) {
    }
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    func setPostData(_ postData: PostData){
        self.userRank.rating = postData.star
        
        
        postImage.sd_imageIndicator = SDWebImageActivityIndicator.gray
        let imageRef = Storage.storage().reference().child(Const.ImagePath).child(postData.id + ".jpg")
        postImage.sd_setImage(with: imageRef)
        
    }
    

}
