//
//  NotificationTableViewCell.swift
//  Instagram
//
//  Created by Rio Nagasaki on 2021/10/23.
//

import UIKit
import Nuke
import Firebase

class NotificationTableViewCell: UITableViewCell {
    
    @IBOutlet weak var notificationButton: UIButton!
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var postImage: UIImageView!
    @IBOutlet weak var notificationLabel: UILabel!
    @IBOutlet weak var notificationTimeLabel: UILabel!
    @IBOutlet weak var deleteNotification: UIButton!
    
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        profileImage.layer.cornerRadius = profileImage.frame.size.width/2
        profileImage.layer.borderWidth = 1
        profileImage.layer.borderColor = #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1)
        profileImage.clipsToBounds = true
        
        postImage.layer.borderWidth = 1
        postImage.layer.borderColor = #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1)
        deleteNotification.layer.cornerRadius = 15.0
        deleteNotification.layer.borderWidth = 1
        deleteNotification.layer.borderColor = UIColor.black.cgColor
       
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func setNotify(_ notification: Notification){
        
        self.notificationTimeLabel.text = ""
        if let date = notification.date{
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd HH:mm"
            let dateString = formatter.string(from: date)
            self.notificationTimeLabel.text = dateString
        }
        
        self.notificationLabel.text = "\(notification.notification ?? "")"
        
        let url2 = notification.postImage
        Nuke.loadImage(with: url2, into: postImage)
        
        
        
        

        if notification.profileImage != nil {
            let url = notification.profileImage
            
            
            Nuke.loadImage(with: url, into: profileImage)
        }else{
            profileImage.image = UIImage(named: "panda")
        }
    
        
        
        
        
    }
    
    
}
