//
//  SettingTableViewCell.swift
//  SearchLibraryApp
//
//  Created by t032fj on 2022/05/04.
//

import UIKit

class SettingTableViewCell: UITableViewCell {
    
    @IBOutlet weak var baseLabel: UILabel!
    @IBOutlet weak var settingImg: UIImageView!
  
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
