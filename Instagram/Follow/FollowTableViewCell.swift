//
//  FollowTableViewCell.swift
//  Instagram
//
//  Created by Rio Nagasaki on 2021/10/08.
//

import UIKit
import Firebase
import FirebaseStorageUI
import Nuke

class FollowTableViewCell: UITableViewCell {
    
    let followArray = [Following]()
    
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var userName: UILabel!
    @IBOutlet weak var handleFollow: UIButton!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        profileImage.layer.cornerRadius = profileImage.frame.size.width/2
        profileImage.layer.borderWidth = 1
        profileImage.layer.borderColor = #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1)
        profileImage.clipsToBounds = true
        handleFollow.layer.cornerRadius = 10.0
        handleFollow.layer.borderWidth = 1
        handleFollow.layer.borderColor = UIColor.black.cgColor
        
        
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func setFollowing(_ following: Following) {
        
        self.userName.text = "\(following.name!)"
        
        print("プリント\(following.profileImage)")
        if following.profileImage != nil {
            let url = following.profileImage
            Nuke.loadImage(with: url, into: profileImage)
        }else{
            profileImage.image = UIImage(named: "panda")
        }
        
        if following.isFollowed == false{
            handleFollow.setTitle("フォローする", for: .normal)
            handleFollow.setTitleColor(#colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0), for: .normal)
        }else{
            handleFollow.setTitle("リクエスト", for: .normal)
            handleFollow.setTitleColor(#colorLiteral(red: 0.7450980544, green: 0.1568627506, blue: 0.07450980693, alpha: 1), for: .normal)
        }
        
        
    }
    
}

