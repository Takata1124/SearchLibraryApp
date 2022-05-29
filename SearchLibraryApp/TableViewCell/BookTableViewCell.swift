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
    @IBOutlet weak var mapButton: UIButton!
    @IBOutlet weak var webButton: UIButton!
 
    var borrowSituation: String = "" {
        didSet {
            borrowLabel.text = borrowSituation
            
            if borrowSituation == "貸出可" {
                self.borrowLabel.textColor = .red
            } else {
                self.borrowLabel.textColor = .modeTextColor
            }
        }
    }
    
    var articleUrl: String = ""
    var longitude: String = ""
    var latitude: String = ""
    var webTitle: String = ""

    override func awakeFromNib() {
        super.awakeFromNib()
        
        webButton.addTarget(self, action: #selector(self.doOpenWeb(_:)), for: UIControl.Event.touchUpInside)
        mapButton.addTarget(self, action: #selector(self.doOpenMap(_:)), for: UIControl.Event.touchUpInside)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }
    
    @objc func doOpenWeb(_ sender: UIButton) {
        
        NotificationCenter.default.post(name: .notifyWeb, object: nil, userInfo: ["url": self.articleUrl, "webTitle": self.webTitle])
    }
    
    @objc func doOpenMap(_ sender: UIButton) {

        NotificationCenter.default.post(name: .notifyMap, object: nil, userInfo: ["latitude": self.latitude, "longitude": self.longitude])
    }
}
