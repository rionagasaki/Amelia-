//
//  ReportTableViewCell.swift
//  Instagram
//
//  Created by Rio Nagasaki on 2021/11/24.
//

import UIKit

class ReportTableViewCell: UITableViewCell {

    @IBOutlet weak var uiSwitch: UISwitch!
    @IBOutlet weak var uiLabel: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        uiSwitch.isOn = false
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    
    
}
