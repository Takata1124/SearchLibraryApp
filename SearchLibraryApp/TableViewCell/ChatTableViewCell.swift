//
//  ChatTableViewCell.swift
//  SearchLibraryApp
//
//  Created by t032fj on 2022/06/22.
//

import UIKit

class ChatTableViewCell: UITableViewCell {
    
    @IBOutlet weak var selfImageView: UIImageView!
    @IBOutlet weak var chatLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        self.backgroundColor = .clear
        selfImageView.layer.borderColor = UIColor.black.cgColor
        selfImageView.layer.borderWidth = 0.5
        selfImageView.layer.cornerRadius = 12.5

        chatLabel.textAlignment = .left
        chatLabel.layer.cornerRadius = 5
        chatLabel.layer.borderColor = UIColor.black.cgColor
        chatLabel.layer.borderWidth = 0.5
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    func updateCell(text: String) {
        self.chatLabel.text = text
    }
    
}
