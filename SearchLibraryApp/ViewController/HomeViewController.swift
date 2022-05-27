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

class HomeViewController: UIViewController {
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    var locationManager: CLLocationManager!
    
    @IBOutlet weak var totalReadLabel: UILabel!
    @IBOutlet weak var monthReadLabel: UILabel!
    @IBOutlet weak var barChart: BarChartView!
    
    var chartDataSet: LineChartDataSet!
    
    private var presenter: HomePresenterInput!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.title = "ホーム"

        self.presenter = HomePresenter(output: self, model: HomeModel())
    
        setupLocationManager()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        presenter.didFetchAllItem()
        presenter.didDistributeItem()
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
        barChart.xAxis.labelTextColor = .modeTextColor
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
        barChart.leftAxis.labelTextColor = .modeTextColor
        // グリッドの色を設定
        barChart.leftAxis.gridColor = .modeTextColor
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
        barChart.backgroundColor = .modeColor //Background Color
        barChart.doubleTapToZoomEnabled = false  //ダブルタップでの拡大禁止
        //        barChart.animate(xAxisDuration: 2.5, yAxisDuration: 2.5, easingOption: .linear) //グラフのアニメーション(秒数で設定)
    }
    
    private func setupLocationManager() {
        
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
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
        
        DispatchQueue.main.async {
            self.performSegue(withIdentifier: "goCart", sender: nil)
        }
    }
}

extension HomeViewController: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        
        print("didChangeAuthorization status=\(status.rawValue)")
        
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
        
        if let locValue: CLLocationCoordinate2D = manager.location?.coordinate {
            
            presenter.didSearchLocationLibrary(latitude: locValue.latitude, logitude: locValue.longitude)
        }
    }
}

extension HomeViewController: HomePresenterOutput {
    
    func updateTotalLabels(days: [Date]) {
        DispatchQueue.main.async {
            
            self.totalReadLabel.text = String(days.count)
            
            let week = Date().toStringWithCurrentLocale().prefix(7)
            var count: Int = 0
            
            days.forEach { day in
                
                let dayString = day.toStringWithCurrentLocale()
                
                if dayString.contains(week) {
                    count += 1
                    self.monthReadLabel.text = String(count)
                }
            }
        }
    }
    
    func makingChart(counts: [Int], labels: [String]) {
        self.getChart(labels: labels, rawData: counts)
    }
}
