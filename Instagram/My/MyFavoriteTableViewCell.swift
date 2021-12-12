//
//  MyFavoriteTableViewCell.swift
//  Instagram
//
//  Created by Rio Nagasaki on 2021/11/26.
//

import UIKit
import Nuke

class MyFavoriteTableViewCell: UITableViewCell {
    
    
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var placemark: UILabel!
    @IBOutlet weak var postButton: UIButton!
    
    
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        profileImage.layer.cornerRadius = 15.0
        profileImage.clipsToBounds = true
        postButton.layer.cornerRadius = 15.0
        
    }
    
    func setFavorite(_ myFavorite: MyFavorite){
        self.placemark.text = myFavorite.placeMark
       
        
        
        if myFavorite.profileImage != nil {
            let url = myFavorite.profileImage
            
            Nuke.loadImage(with: url, into: profileImage)
        }else{
            profileImage.image = UIImage(named: "panda")
        }
        
    }
    

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
