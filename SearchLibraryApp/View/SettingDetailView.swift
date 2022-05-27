//
//  SettingDetailView.swift
//  SearchLibraryApp
//
//  Created by t032fj on 2022/05/22.
//

import Foundation
import UIKit
import CoreLocation

class SettingDetailView: UIView {
    
    private let appDelegateWindow = UIApplication.shared.windows.first
    
    var locationManager: CLLocationManager!
    
    var modeSwitch = BaseSwitch()
    var modeLabel = BaseLabel(frame: CGRect(x: UIScreen.main.bounds.width / 2 - 50, y: 300, width: 100, height: 50))
    var backButton = UIButton(frame: CGRect(x: UIScreen.main.bounds.width / 2 - 50, y: UIScreen.main.bounds.height - 150, width: 100, height: 100))
    
    var modeSelect: Bool = false {
        didSet {
            if modeSelect {
                modeLabel.text = "ダーク"
                modeSwitch.isOn = true
            } else {
                modeLabel.text = "ライト"
                modeSwitch.isOn = false
            }
        }
    }
    
    var selectCell: String = ""  {
        didSet {
            selectCategorySetting(selectCell: selectCell)
        }
    }
    
    override init(frame: CGRect){
        super.init(frame: frame)

    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func confirmSelectCell(selectCell: String) {
        
        self.selectCell = selectCell
    }
    
    private func selectCategorySetting(selectCell: String) {
        
        switch selectCell {
            
        case "ダークモード":
            darkModeSetupLayout()
            
        case "位置情報設定":
            setupLocationManager()
            
        default:
            print("default")
        }
    }
    
    private func darkModeSetupLayout() {
        
        self.addSubview(modeLabel)
        self.addSubview(modeSwitch)
    
        if appDelegateWindow?.overrideUserInterfaceStyle == .dark {
            modeSelect = true
        } else {
            modeSelect = false
        }
    }
    
    private func setupLocationManager() {
        
        locationManager = CLLocationManager()
        locationManager.delegate = self
    }
}

extension SettingDetailView: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        
        print(status.rawValue)
    }
}
