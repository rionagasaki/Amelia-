//
//  PostTableViewCell.swift
//  Instagram
//
//  Created by Rio Nagasaki on 2021/09/22.
//

import UIKit
import FirebaseStorageUI
import Firebase
import Cosmos
import Nuke
class PostTableViewCell: UITableViewCell {
    
    @IBOutlet weak var postImageView: UIImageView!
    @IBOutlet weak var likeButton: UIButton!
    @IBOutlet weak var likeLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var captionLabel: UILabel!
    @IBOutlet weak var commentButton: UIButton!
    @IBOutlet weak var Rating: CosmosView!
    @IBOutlet weak var postDeleteButton: UIButton!
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var postMap: UIButton!
    
    
    
    let followArray = [Following]()
    var postArray: [PostData] = []
    
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        commentButton.layer.cornerRadius = 10.0
        profileImage.layer.cornerRadius = profileImage.frame.size.width/2
        profileImage.layer.borderWidth = 1
        profileImage.layer.borderColor = #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1)
        profileImage.clipsToBounds = true
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
    }
    
    func setDeleteButton(state:Bool) {
      if state{
        postDeleteButton.isEnabled = false
        postDeleteButton.isHidden = true
      } else {
        postDeleteButton.isEnabled = true
        postDeleteButton.isHidden = false
      }
    }
    
    
    func setPostData(_ postData: PostData){
        postImageView.sd_imageIndicator = SDWebImageActivityIndicator.gray
        let imageRef = Storage.storage().reference().child(Const.ImagePath).child(postData.id + ".jpg")
        postImageView.sd_setImage(with: imageRef)
        self.captionLabel.text = "\(postData.name!) ▶️ \(postData.caption ?? "")"
        
        self.Rating.rating = postData.star
        
        if postData.profileImage != nil {
            let url = postData.profileImage
            
            Nuke.loadImage(with: url, into: profileImage)
        }else{
            profileImage.image = UIImage(named: "panda")
        }
        let placemark:String! = postData.placeMark!
        self.dateLabel.text! = placemark!
        let likeNumber = postData.likes.count
        likeLabel.text = "\(likeNumber)"
        
        if postData.isLiked{
            let buttonImage = UIImage(named: "like_exist")
            self.likeButton.setImage(buttonImage, for: .normal)}else{
                let buttonImage = UIImage(named: "like_none")
                self.likeButton.setImage(buttonImage, for: .normal)
                
                
                
            }
        
        
        
    }
    
    
}

