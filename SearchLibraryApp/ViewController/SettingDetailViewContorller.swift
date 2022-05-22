//
//  SettingDetailViewContorller.swift
//  SearchLibraryApp
//
//  Created by t032fj on 2022/05/22.
//

import Foundation
import UIKit
import SnapKit

class SettingDetailViewController: UIViewController {
    
    var selectCell: String = ""
    
    let settingDetailView = SettingDetailView()
    
    private let appDelegateWindow = UIApplication.shared.windows.first
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "\(selectCell)"
        
        setupLayout()

        view.addSubview(settingDetailView)
    }
    
    override func viewDidLayoutSubviews() {

        settingDetailView.snp.makeConstraints { make in
            
            make.top.equalTo(self.view.snp.top)
            make.bottom.equalTo(self.view.snp.bottom).offset(-100)
            make.left.equalTo(self.view.snp.left)
            make.right.equalTo(self.view.snp.right)
        }
    }
    
    private func setupLayout() {
        
        settingDetailView.confirmSelectCell(selectCell: self.selectCell)
        settingDetailView.modeSwitch.addTarget(self, action: #selector(modeChange), for: UIControl.Event.valueChanged)
    }
    
    @objc func modeChange(sender: UISwitch) {
        
        if #available(iOS 13.0, *) {
            
            let onCheck: Bool = sender.isOn
            if onCheck {
                appDelegateWindow?.overrideUserInterfaceStyle = .dark
                settingDetailView.modeSelect = true
            } else {
                appDelegateWindow?.overrideUserInterfaceStyle = .light
                settingDetailView.modeSelect = false
            }
        }
    }
    
    @IBAction func goBackView(_ sender: Any) {
        
        self.navigationController?.popViewController(animated: true)
    }
}
