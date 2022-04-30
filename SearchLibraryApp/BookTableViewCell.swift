//
//  BookTableViewCell.swift
//  SearchLibraryApp
//
//  Created by t032fj on 2022/05/01.
//

import UIKit

class BookTableViewCell: UITableViewCell {
    
    @IBOutlet weak var libraryName: UILabel!
    @IBOutlet weak var borrowLabel: UILabel!
    
    var borrowSituation: String = "" {
        didSet {
            borrowLabel.text = borrowSituation
            
            if borrowSituation == "貸出可" {
                self.borrowLabel.textColor = .red
            }
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.layer.borderWidth = 0.5
        self.layer.borderColor = UIColor.black.cgColor
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}

