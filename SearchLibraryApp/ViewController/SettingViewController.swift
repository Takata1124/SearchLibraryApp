//
//  SettingViewController.swift
//  SearchLibraryApp
//
//  Created by t032fj on 2022/04/30.
//

import UIKit
import SnapKit

class SettingViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    let settingTableView = SettingTableView()
    
    let settings: [String] = ["アプリバージョン",
                              "取扱説明",
                              "ライセンス",
                              "プライバシーポリシー",
                              "ダークモード",
                              "位置情報設定",
                              "データの削除"]
    
    var selectCell: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let baseStackView = UIStackView(arrangedSubviews: [settingTableView])
        baseStackView.axis = .vertical
        baseStackView.translatesAutoresizingMaskIntoConstraints = false
        
        self.view.addSubview(baseStackView)
        
        baseStackView.snp.makeConstraints { make in
            make.top.equalTo(view.snp.top)
            make.bottom.equalTo(view.snp.bottom).offset(-100)
            make.right.equalTo(view.snp.right)
            make.left.equalTo(view.snp.left)
        }
        
        settingTableView.tableView.delegate = self
        settingTableView.tableView.dataSource = self
        settingTableView.tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
    }
    
    @objc func dismissSetup(_ sender: UIButton){
        
        self.dismiss(animated: true, completion: nil)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return settings.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        return 50
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell: UITableViewCell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = settings[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: true)
        
        let selectCell = settings[indexPath.row]
        
        goSelectView(selectCell: selectCell)
    }
    
    @IBAction func goBackView(_ sender: Any) {
        
        self.navigationController?.popViewController(animated: true)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "goSettingDetail" {
            let settingDetailViewController = segue.destination as! SettingDetailViewController
            settingDetailViewController.selectCell = self.selectCell
        }
    }
    
    func goSelectView(selectCell: String) {
        
        switch selectCell {
            
        case "アプリバージョン":
            
            let version: String = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as! String
            
            let alert = UIAlertController(title: "アプリのバージョン", message: "現在のアプリのバージョンは\(version)", preferredStyle: .alert)
            
            let addActionAlert: UIAlertAction = UIAlertAction(title: "確認", style: .default, handler: { _ in
                
                alert.dismiss(animated: false, completion: nil)
            })
            
            alert.addAction(addActionAlert)
            
            present(alert, animated: true)
            
        default:
            
            self.selectCell = selectCell
            
            performSegue(withIdentifier: "goSettingDetail", sender: nil)
        }
        
    }
}

