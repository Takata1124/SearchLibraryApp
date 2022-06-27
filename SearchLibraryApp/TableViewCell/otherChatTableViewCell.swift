//
//  otherChatTableViewCell.swift
//  SearchLibraryApp
//
//  Created by t032fj on 2022/06/23.
//

import UIKit

class otherChatTableViewCell: UITableViewCell {
    
    @IBOutlet weak var selfImageView: UIImageView!
    @IBOutlet weak var chatLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.backgroundColor = .clear
        selfImageView.layer.borderColor = UIColor.black.cgColor
        selfImageView.layer.borderWidth = 0.5
        selfImageView.layer.cornerRadius = 25
        chatLabel.layer.borderColor = UIColor.black.cgColor
        chatLabel.layer.borderWidth = 0.5
        chatLabel.layer.cornerRadius = 25
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func updateCell(text: String) {
        self.chatLabel.text = text
    }
    
}
