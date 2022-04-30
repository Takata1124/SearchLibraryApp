//
//  HomeViewController.swift
//  SearchLibraryApp
//
//  Created by t032fj on 2022/04/26.
//

import UIKit
import CoreLocation
import Alamofire

class HomeViewController: UIViewController, CLLocationManagerDelegate {
    
    let appDelegate: AppDelegate = UIApplication.shared.delegate as! AppDelegate
    
    var locationManager: CLLocationManager!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.title = "ホーム"

        setupLocationManager()
    }
    
    private func setupLocationManager() {
        
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        
        switch status {
            // 許可されてない場合
        case .notDetermined:
            // 許可を求める
            manager.requestWhenInUseAuthorization()
            // 拒否されてる場合
        case .restricted, .denied:
            // 何もしない
            break
            // 許可されている場合
        case .authorizedAlways, .authorizedWhenInUse:
            // 現在地の取得を開始
            manager.startUpdatingLocation()
            break
        default:
            break
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        guard let locValue: CLLocationCoordinate2D = manager.location?.coordinate else { return }
        
        searchLocationLibrary(latitude: locValue.latitude, longitude: locValue.longitude) { totalArray in
            
            self.appDelegate.totalArray = totalArray
        }
    }
    
    func searchLocationLibrary(latitude: Double, longitude: Double, completion: @escaping ([Spot]) -> Void) {
        
        let count: Int = 7
        let libraryApikey: String = Apikey().libraryApikey
        let url: String = "https://api.calil.jp/library?appkey=\(libraryApikey)&callback=&geocode=\(longitude),\(latitude)&limit=\(String(count))&format=json"
        var totalArray: [Spot] = []
        var i = 0
        
        AF.request(url).responseDecodable(of: [LocationData].self, decoder: JSONDecoder()) { response in
            
            if case .success(let data) = response.result {
                
                data.forEach { singleData in
                    i += 1
                    
                    let name = singleData.short
                    let distance = singleData.distance
                    let systemid = singleData.systemid
                    let longitude = singleData.geocode.components(separatedBy: ",")[0]
                    let latitude = singleData.geocode.components(separatedBy: ",")[1]
                    
                    let spot = Spot(name: name, systemId: systemid, latitude: latitude, longitude: longitude, distance: distance)
                    
                    totalArray.append(spot)
                    
                    if i == data.count {
                        completion(totalArray)
                    }
                }
            }
        }
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
