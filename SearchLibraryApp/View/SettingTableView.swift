//
//  SettingView.swift
//  SearchLibraryApp
//
//  Created by t032fj on 2022/05/22.
//

import Foundation
import UIKit
import SnapKit

class SettingTableView: UIView {

    lazy var tableView: UITableView = {
        let table =  UITableView(frame: .zero, style: .grouped)
        table.autoresizingMask = [
            .flexibleWidth,
            .flexibleHeight
        ]
        table.backgroundColor = .lightGray
        table.separatorInset = .zero
        table.separatorColor = .black
        return table
    }()
    
    override init(frame: CGRect) {
        super.init(frame: .zero)
        
        self.addSubview(tableView)
      
        tableView.snp.makeConstraints { make in
            
            make.top.equalTo(self.snp.top)
            make.bottom.equalTo(self.snp.bottom)
            make.left.equalTo(self.snp.left)
            make.right.equalTo(self.snp.right)
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
