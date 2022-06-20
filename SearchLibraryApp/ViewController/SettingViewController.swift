//
//  SettingViewController.swift
//  SearchLibraryApp
//
//  Created by t032fj on 2022/04/30.
//

import UIKit
import SnapKit
import CoreLocation
import CoreData

class SettingViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    let settingTableView = SettingTableView()
    
    let settings: [String] = ["ユーザー情報",
                              "アプリバージョン",
                              "取扱説明",
                              "プライバシーポリシー",
                              "お問い合わせ",
                              "ダークモード",
                              "位置情報設定",
                              "データの表示順",
                              "データの削除"]
    
    var selectCell: String = ""
    var locationManager: CLLocationManager!
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "設定"
        self.navigationItem.hidesBackButton = true
        
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
            
            alert.view.tintColor = UIColor.modeTextColor
            
            alert.addAction(addActionAlert)
            present(alert, animated: true)
            
        case "データの削除":
            
            let alert = UIAlertController(title: "データの削除", message: "データの削除を実施しますか？", preferredStyle: .alert)
            let addOkAlert: UIAlertAction = UIAlertAction(title: "OK", style: .default, handler: { _ in
                
                self.deleteCoredataItems { isDelete in
                    alert.dismiss(animated: false, completion: nil)
                    
                    if !isDelete {
                        print("CoreDataが削除できませんでした")
                    }
                }
            })
            
            let addNgAlert: UIAlertAction = UIAlertAction(title: "NO", style: .default, handler: { _ in
                
                alert.dismiss(animated: false, completion: nil)
            })
            
            alert.view.tintColor = UIColor.modeTextColor
            
            alert.addAction(addOkAlert)
            alert.addAction(addNgAlert)
            present(alert, animated: true)
            
        case "位置情報設定":
            
            locationManager = CLLocationManager()
            locationManager.delegate = self

        default:
            
            self.selectCell = selectCell
            
            performSegue(withIdentifier: "goSettingDetail", sender: nil)
        }
    }
    
    func deleteCoredataItems(completion: @escaping(Bool) -> ()) {
        
        let fetchRequest = NSFetchRequest<CartItem>(entityName: "CartItem")
        let cartItem = try? context.fetch(fetchRequest)
        
        cartItem?.forEach({ item in
            context.delete(item)
            
            do {
                try context.save()
                completion(true)
            } catch {
                print("CoreDataに保存できませんでした")
                completion(false)
            }
        })
    }
}

extension SettingViewController: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        
        if status.rawValue != 4 {
            
            let alert = UIAlertController(title: "位置情報が許可されていません", message: "位置情報を設定しますか？", preferredStyle: .alert)
            let addOkAlert: UIAlertAction = UIAlertAction(title: "はい", style: .default, handler: { _ in
                
                alert.dismiss(animated: false, completion: nil)

                if let url = URL(string: UIApplication.openSettingsURLString), UIApplication.shared.canOpenURL(url) {
                   UIApplication.shared.open(url, options: [:], completionHandler: nil)
                }
            })
            
            let addNgAlert: UIAlertAction = UIAlertAction(title: "いいえ", style: .default, handler: { _ in
                
                alert.dismiss(animated: false, completion: nil)
            })
            
            alert.view.tintColor = UIColor.modeTextColor

            alert.addAction(addOkAlert)
            alert.addAction(addNgAlert)
            
            present(alert, animated: true)
            
        } else {
           
            let alert = UIAlertController(title: "位置情報", message: "位置情報の取得が許可されています", preferredStyle: .alert)
            let addOkAlert: UIAlertAction = UIAlertAction(title: "確認", style: .default, handler: { _ in
                
                alert.dismiss(animated: false, completion: nil)
            })
            
            alert.view.tintColor = UIColor.modeTextColor
            
            alert.addAction(addOkAlert)
            
            present(alert, animated: true)
        }
    }
}

