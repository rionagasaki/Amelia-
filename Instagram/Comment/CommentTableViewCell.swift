//
//  CommentTableViewCell.swift
//  Instagram
//
//  Created by Rio Nagasaki on 2021/10/22.
//

import UIKit
import Nuke
import Firebase

class CommentTableViewCell: UITableViewCell {
    
    @IBOutlet weak var commentImage: UIImageView!
    @IBOutlet weak var commentName: UILabel!
    @IBOutlet weak var commentText: UILabel!
    @IBOutlet weak var commentDelete: UIButton!
    @IBOutlet weak var commentTime: UILabel!
    @IBOutlet weak var rename: UIButton!
    
    
    var commentArray:[Comment] = []

    override func awakeFromNib() {
        super.awakeFromNib()
        commentImage.layer.cornerRadius = commentImage.frame.size.width/2
        commentImage.layer.borderWidth = 1
        commentImage.layer.borderColor = #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1)
        commentImage.clipsToBounds = true
    }
    
    func setDeleteButton(state:Bool) {
      if state{
        commentDelete.isEnabled = false
        commentDelete.isHidden = true
      } else {
        commentDelete.isEnabled = true
        commentDelete.isHidden = false
      }
    }
    
    

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    func setCommentData(_ commentData: Comment){
            commentName.text = commentData.name!
            commentText.text = commentData.comment
            
            if commentData.profileImage != nil {
                let url = commentData.profileImage
                
                Nuke.loadImage(with: url, into: commentImage)
            }else{
                commentImage.image = UIImage(named: "panda")
            }
        
        self.commentTime.text = ""
        if let date = commentData.date{
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd HH:mm"
            let dateString = formatter.string(from: date)
            self.commentTime.text = dateString
        }
        
    }
        
    
}

