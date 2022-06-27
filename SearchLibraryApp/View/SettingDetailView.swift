//
//  SettingDetailView.swift
//  SearchLibraryApp
//
//  Created by t032fj on 2022/05/22.
//

import Foundation
import UIKit
import CoreLocation
import WebKit
import SnapKit
import Alamofire
import AlamofireImage

class SettingDetailView: UIView {
    
    private let appDelegateWindow = UIApplication.shared.windows.first
    
    var locationManager: CLLocationManager!
    
    var modeSwitch = BaseSwitch()
    var modeLabel = BaseLabel(frame: CGRect(x: UIScreen.main.bounds.width / 2 - 50, y: 300, width: 100, height: 50))
    var mailButton: UIButton = {
        let button = UIButton()
        button.frame = CGRect(x: UIScreen.main.bounds.width / 2 - 75, y: UIScreen.main.bounds.height / 2, width: 150, height: 50)
        button.setTitleColor(.black, for: .normal)
        button.backgroundColor = UIColor.systemTeal
//        button.layer.borderColor = UIColor.black.cgColor
//        button.layer.borderWidth = 1.0
        button.layer.cornerRadius = 10
        button.setTitle("お問い合わせ", for:UIControl.State.normal)
        return button
    }()
    
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
    
    var orderSelect: Bool = false {
        didSet {
            if orderSelect {
                modeLabel.text = "新しい順"
                orderSwitch.isOn = true
            } else {
                modeLabel.text = "古い順"
                orderSwitch.isOn = false
            }
        }
    }
    
    var orderSwitch = BaseSwitch()
    
    var selectCell: String = ""  {
        didSet {
            selectCategorySetting(selectCell: selectCell)
        }
    }
    
    let webView = WKWebView()
    
    var imageUrl: String = "" {
        didSet {
            setupSelfData(imageUrl: imageUrl)
        }
    }
    
    let selfImageView :UIImageView = {
        let image = UIImageView()
        image.layer.borderWidth = 0.5
        image.layer.borderColor = UIColor.black.cgColor
        image.layer.cornerRadius = 100
        image.clipsToBounds = true
        return image
    }()
    
    override init(frame: CGRect){
        super.init(frame: frame)
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func confirmSelectCell(selectCell: String) {
        self.selectCell = selectCell
    }
    
    func setUpSelfImageUrl(imageUrl: String) {
        self.imageUrl = imageUrl
    }
    
    func setupOrderSwitch(isNewOrder: Bool) {
        
        self.orderSelect = isNewOrder
    }
    
    private func selectCategorySetting(selectCell: String) {
        
        switch selectCell {
            
        case "ダークモード":
            darkModeSetupLayout()
            
        case "取扱説明":
            setupWebView(url: "https://mo-gu-mo-gu.com/ios-wkwebview-tutorial/")
            
        case "プライバシーポリシー":
            setupWebView(url: "https://takata1124.github.io/SearchLibraryApp/PrivacyPolicy/privacy.html")
            
        case "データの表示順":
            orderSetupLayout()
            
        case "お問い合わせ":
            setupMailLayout()
            
        default:
            print("default")
        }
    }
    
    private func setupSelfData(imageUrl: String) {
        
        AF.request(imageUrl).responseImage { responseImage in
            
            if case .success(let uiImage) = responseImage.result {
                self.selfImageView.image = uiImage
                
                self.addSubview(self.selfImageView)
                self.selfImageView.snp.makeConstraints { make in
                    make.size.equalTo(200)
                    make.center.equalToSuperview()
                }
            }
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
    
    private func orderSetupLayout() {
        
        self.addSubview(modeLabel)
        self.addSubview(orderSwitch)
    }
    
    private func setupMailLayout() {
        
        self.addSubview(mailButton)
    }
    
    private func setupLocationManager() {
        
        locationManager = CLLocationManager()
        locationManager.delegate = self
    }
    
    private func setupWebView(url: String) {
        
        self.backgroundColor = .red
        self.addSubview(webView)
        
        let request = URLRequest(url: URL(string: url)!)
        webView.load(request)
        
        webView.snp.makeConstraints { make in
            make.top.equalTo(self.snp.top)
            make.bottom.equalTo(self.snp.bottom)
            make.left.equalTo(self.snp.left)
            make.right.equalTo(self.snp.right)
        }
    }
}

extension SettingDetailView: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        
        print(status.rawValue)
    }
}
