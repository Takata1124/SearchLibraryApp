//
//  TableViewCell.swift
//  SearchLibraryApp
//
//  Created by t032fj on 2022/04/29.
//

import UIKit

class TableViewCell: UITableViewCell {
    
    @IBOutlet weak var img: UIImageView!
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var authorLabel: UILabel!
    @IBOutlet weak var isbnLabel: UILabel!
    @IBOutlet weak var createdLabel: UILabel!
    @IBOutlet weak var doneReadLabel: UILabel!
    @IBOutlet weak var starImage: UIImageView!

    var isRead: Bool = false{
        didSet {
            if isRead {
                self.doneReadLabel.text = "読書済"
                self.doneReadLabel.textColor = .red
            } else {
                self.doneReadLabel.text = "読書中"
                self.doneReadLabel.textColor = .black
            }
        }
    }
    
    var isStar: Bool = false {
        didSet {
            if isStar {
                self.starImage.image = UIImage(systemName: "star.fill")
            } else {
                self.starImage.image = UIImage(systemName: "star")
            }
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
