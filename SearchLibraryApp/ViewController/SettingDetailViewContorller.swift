//
//  SettingDetailViewContorller.swift
//  SearchLibraryApp
//
//  Created by t032fj on 2022/05/22.
//

import Foundation
import UIKit
import SnapKit
import CoreLocation
import SQLite
import MessageUI
import Alamofire
import AlamofireImage
import Firebase

class SettingDetailViewController: UIViewController, MFMailComposeViewControllerDelegate {
    
    var selectCell: String = ""
    let settingDetailView = SettingDetailView()
    private let appDelegateWindow = UIApplication.shared.windows.first
    var database = SQLDatabase()
    
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
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    private func setupLayout() {
        
        self.navigationItem.hidesBackButton = true
        
        settingDetailView.confirmSelectCell(selectCell: self.selectCell)
        settingDetailView.modeSwitch.addTarget(self, action: #selector(modeChange), for: UIControl.Event.valueChanged)
        settingDetailView.orderSwitch.addTarget(self, action: #selector(orderChange), for: UIControl.Event.valueChanged)
        settingDetailView.mailButton.addTarget(self, action: #selector(mailPresent(sender:)), for: .touchUpInside)
        
        if self.selectCell == "データの表示順" {
            let result = database.findById(id: 1)
            let currentOrder = result[0].isNewOrder
            settingDetailView.setupOrderSwitch(isNewOrder: currentOrder)
        }
        
        if self.selectCell == "ユーザー情報" {
            
            if let uid = Auth.auth().currentUser?.uid {
                Firestore.firestore().collection("users").document(uid).getDocument { snapshots, error in
                    
                    if error != nil {
                        return
                    }
                    
                    if let dic = snapshots?.data() {
                        print(dic)
                        print(dic["profileImageUrl"]!)
                        
                        let imageUrl: String = dic["profileImageUrl"]! as! String
                        self.settingDetailView.setUpSelfImageUrl(imageUrl: imageUrl)
                    }
                }
            }
        }
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
    
    @objc func orderChange(sender: UISwitch) {
        
        let onCheck: Bool = sender.isOn
        if onCheck {
            settingDetailView.orderSelect = true
            database.update(rowId: 1, isNewOrder: true)
        } else {
            settingDetailView.orderSelect = false
            database.update(rowId: 1, isNewOrder: false)
        }
    }
    
    @IBAction func goBackView(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @objc func mailPresent(sender: UIButton) {
        
        if MFMailComposeViewController.canSendMail() {
            let mail = MFMailComposeViewController()
            mail.mailComposeDelegate = self
            mail.setToRecipients(["tnkxy834@yahoo.co.jp"]) // 宛先アドレス
            mail.setSubject("図書管理アプリに関するお問い合わせ") // 件名
            mail.setMessageBody("ここに本文が入ります。", isHTML: false) // 本文
            present(mail, animated: true, completion: nil)
        } else {
            print("送信できません")
        }
    }
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        
        switch result {
            
        case .cancelled:
            print("キャンセル")
        case .saved:
            print("下書き保存")
        case .sent:
            print("送信成功")
        default:
            print("送信失敗")
        }
        
        dismiss(animated: true, completion: nil)
    }
    
    private func getUrlImage(imageUrl: String, completion: @escaping(UIImage) -> Void) {
        
        AF.request(imageUrl).responseImage { responseImage in
            if case .success(let uiImage) = responseImage.result {
                completion(uiImage)
            }
        }
    }
}
