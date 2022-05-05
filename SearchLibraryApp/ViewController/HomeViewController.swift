//
//  HomeViewController.swift
//  SearchLibraryApp
//
//  Created by t032fj on 2022/04/26.
//

import UIKit
import CoreLocation
import Alamofire
import Charts
import CoreData

class HomeViewController: UIViewController, CLLocationManagerDelegate {
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    var homeModel: HomeModel? {
        didSet {
            registerModel()
        }
    }
    
    private var createdDays: [Date] = [] {
        didSet {
            DispatchQueue.main.async {
                print(self.createdDays)
                self.totalReadLabel.text = String(self.createdDays.count)
                
                let week = Date().toStringWithCurrentLocale().prefix(7)
                var count: Int = 0
                self.createdDays.forEach { singleDay in
                    
                    let day = singleDay.toStringWithCurrentLocale()
                    
                    if day.contains(week) {
                        count += 1
                        self.monthReadLabel.text = String(count)
                    }
                }
            }
        }
    }
    
    var locationManager: CLLocationManager!
    
    @IBOutlet weak var totalReadLabel: UILabel!
    @IBOutlet weak var monthReadLabel: UILabel!
    @IBOutlet weak var barChart: BarChartView!
    
    var chartDataSet: LineChartDataSet!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.homeModel = HomeModel()
        
        self.navigationItem.title = "ホーム"
 
        setupLocationManager()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        self.homeModel?.fetchAllItem()
        
        self.homeModel?.distributeItem { countArray, chartLabels in
            self.getChart(labels: chartLabels, rawData: countArray)
        }
    }
    
    private func registerModel() {
        
        guard let model = homeModel else { return }
        
        model.notificationCenter.addObserver(forName: .init(rawValue: HomeModel.notificationName), object: nil, queue: nil) { notification in
            
            if let createdDays = notification.userInfo?["createdDays"] as? [Date] {
                self.createdDays = createdDays
                print(createdDays)
            } else {
                print("goBack")
            }
        }
    }
    
    private func getChart(labels: [String], rawData: [Int]){
        
        let entries = rawData.enumerated().map { BarChartDataEntry(x: Double($0.offset), y: Double($0.element)) }
        let dataSet = BarChartDataSet(entries: entries)
        let data = BarChartData(dataSet: dataSet)
        barChart.data = data
        
        //ラベルに表示するデータを指定　上で作成した「labels」を指定
        barChart.xAxis.valueFormatter = IndexAxisValueFormatter(values:labels)
        barChart.xAxis.granularity = 1
        // ラベルの数を設定
        barChart.xAxis.labelCount = rawData.count
        // X軸のラベルの位置を下に設定
        barChart.xAxis.labelPosition = .bottom
        // X軸のラベルの色,文字サイズを設定
        barChart.xAxis.labelTextColor = .black
        barChart.xAxis.labelFont = UIFont(name: "HelveticaNeue-Light", size: 8.0)!
        // X軸の線、グリッドを非表示にする
        barChart.xAxis.drawGridLinesEnabled = false
        barChart.xAxis.drawAxisLineEnabled = false
        // 右側のY座標軸は非表示にする
        barChart.rightAxis.enabled = false
        // Y座標の値が0始まりになるように設定
        barChart.leftAxis.axisMinimum = 0 //y左軸最小値
        barChart.leftAxis.axisMaximum = Double(rawData.max() ?? 100) + 10//y左軸最大値
        barChart.leftAxis.drawZeroLineEnabled = true
        barChart.leftAxis.zeroLineColor = .gray
        // ラベルの数を設定
        barChart.leftAxis.labelCount = 10
        // ラベルの色を設定
        barChart.leftAxis.labelTextColor = .black
        // グリッドの色を設定
        barChart.leftAxis.gridColor = .gray
        // 軸線は非表示にする
        barChart.leftAxis.drawAxisLineEnabled = false
        //凡例削除
        barChart.legend.enabled = false
        //色の指定　数値の表示非表示
        dataSet.drawValuesEnabled = false
        //dataSet.colors = [.gray]
        dataSet.colors = [UIColor.systemGreen, .systemPink, UIColor.systemGreen, UIColor.systemGreen, UIColor.systemGreen, UIColor.systemGreen, UIColor.systemGreen ]
        
        //その他設定
        barChart.dragDecelerationEnabled = true //指を離してもスクロール続くか
        barChart.dragDecelerationFrictionCoef = 0.6 //ドラッグ時の減速スピード(0-1)
        barChart.chartDescription.text = nil //Description(今回はなし)
        barChart.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1) //Background Color
        barChart.doubleTapToZoomEnabled = false  //ダブルタップでの拡大禁止
//        barChart.animate(xAxisDuration: 2.5, yAxisDuration: 2.5, easingOption: .linear) //グラフのアニメーション(秒数で設定)
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
        
        self.homeModel?.searchLocationLibrary(latitude: locValue.latitude, longitude: locValue.longitude)
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
    
    @IBAction func goCartView(_ sender: Any) {
        
        performSegue(withIdentifier: "goCart", sender: nil)
    }
}
