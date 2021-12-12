//
//  FriendTableViewCell.swift
//  Instagram
//
//  Created by Rio Nagasaki on 2021/10/17.
//

import UIKit
import Nuke
import Firebase

class FriendTableViewCell: UITableViewCell {
    
    @IBOutlet weak var friendImage: UIImageView!
    
    @IBOutlet weak var friendName: UILabel!
    @IBOutlet weak var friendMap: UIButton!
    @IBOutlet weak var friendDelete: UIButton!
    @IBOutlet weak var pointLabel: UILabel!
    
    
    
    
    @IBAction func friendMapButton(_ sender: Any) {
    }
    
    let followArray = [Following]()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        friendImage.layer.cornerRadius = friendImage.frame.size.width/2
        friendImage.layer.borderWidth = 1
        friendImage.layer.borderColor = #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1)
        friendImage.clipsToBounds = true
        friendDelete.layer.cornerRadius = 10.0
        friendMap.layer.cornerRadius = 10.0
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
    }
    func setFollowing(_ following: Following) {
        print("名前\(following.name)")
        
        self.friendName.text = "\(following.name!)"
        
        self.pointLabel.text = "\(following.score ?? 0)p"
        
        if following.profileImage != nil {
            let url = following.profileImage
            Nuke.loadImage(with: url, into: friendImage)
        }else{
            friendImage.image = UIImage(named: "panda")
        }
    }
    
}
