//
//  HomeViewController.swift
//  SearchLibraryApp
//
//  Created by t032fj on 2022/04/26.
//

import UIKit

class HomeViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.title = "ホーム"

        // Do any additional setup after loading the view.
    }
    
    @IBAction func goSearchView(_ sender: Any) {
        performSegue(withIdentifier: "goSearch", sender: nil)
    }
    
    @IBAction func goLibraryView(_ sender: Any) {
        performSegue(withIdentifier: "goLibrary", sender: nil)
    }
    
    @IBAction func goSettingVIew(_ sender: Any) {
        performSegue(withIdentifier: "goSetting", sender: nil)
    }
    
    
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
