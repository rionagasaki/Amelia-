//
//  GoodTableViewCell.swift
//  Instagram
//
//  Created by Rio Nagasaki on 2021/12/15.
//

import UIKit
import Firebase
import FirebaseStorageUI
import Nuke

class GoodTableViewCell: UITableViewCell {
    
   
   
    @IBOutlet weak var nameLabel: UILabel!
    
    @IBOutlet weak var ImageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        ImageView.layer.cornerRadius = ImageView.frame.size.width/2
        ImageView.clipsToBounds = true
        ImageView.layer.borderWidth = 1
        ImageView.layer.borderColor = #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1)
        // Initialization code
    }
    
    func setGood(_ following: Following) {
        
        if following.name == nil {
            return
        }
        
        
        self.nameLabel.text = "\(following.name ?? "")"
        
        if following.profileImage != nil {
            let url = following.profileImage
            Nuke.loadImage(with: url, into: ImageView)
        }else{
            ImageView.image = UIImage(named: "panda")
        }
    }
    
        
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
