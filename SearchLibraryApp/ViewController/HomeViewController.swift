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
    
    let appDelegate: AppDelegate = UIApplication.shared.delegate as! AppDelegate
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    private var cartItemModel: [CartItem] = [] {
        didSet {
            totalReadLabel.text = String(cartItemModel.count)
            
            let week = Date().toStringWithCurrentLocale().prefix(7)
            var count: Int = 0
            cartItemModel.forEach { cartitem in
                guard let day = cartitem.createdAt?.toStringWithCurrentLocale() else { return }
                if day.contains(week) {
                    count += 1
                    self.monthReadLabel.text = String(count)
                }
            }
        }
    }
    
    var locationManager: CLLocationManager!
    
    @IBOutlet weak var chartsView: PieChartView!
    @IBOutlet weak var lineChartView: LineChartView!
    @IBOutlet weak var totalReadLabel: UILabel!
    @IBOutlet weak var monthReadLabel: UILabel!
    @IBOutlet weak var barChart: BarChartView!
    
    var chartDataSet: LineChartDataSet!
    // 今回使用するサンプルデータ
    let sampleData = [10.0]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.title = "ホーム"
        
//        setupCircleView()
//        displayChart(data: sampleData)
 
        setupLocationManager()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        fetchAllItem()
        distributeItem { countArray, chartLabels in
            self.getChart(labels: chartLabels, rawData: countArray)
        }
    }
    
    private func fetchAllItem() {
        do {
            cartItemModel = try context.fetch(CartItem.fetchRequest())
//            cartItemModel.forEach { cartItem in
////                print(cartItem.createdAt)
//            }
        } catch {
            print("coreDataをダウンロードできませんでした")
        }
    }
    
    private func distributeItem(completion: @escaping([Int], [String]) -> Void) {
        
        var months: [String] = []
        cartItemModel.forEach { cartitem in
            let month = cartitem.createdAt?.toStringWithCurrentLocale().prefix(7)
            guard let month = month else { return }
            months.append(String(month))
        }
    
        let uniqueMonths = Array(Set(months))
        var countArray: [Int] = []
        uniqueMonths.enumerated().map { index, month in
            var c = 0
            var i = 0
            cartItemModel.forEach { cartItem in
                c += 1
                guard let day = cartItem.createdAt?.toStringWithCurrentLocale() else { return }
                if day.contains(month) {
                    i += 1
                }
                
                if c == cartItemModel.count {
                    countArray.insert(i, at: index)
                    completion(countArray, uniqueMonths)
                }
            }
        }
    }
    
    private func getChart(labels: [String], rawData: [Int]){
        //適当に数字を入れた配列を作成しておく
//        var labels:[String] = ["1","2","3","4","5","6","7"]
        
        //X軸のラベルに使うデータを作成する 少し面倒だけど日付にしてみる
        //日本時間を表示する準備・・・
//        let formatterJP = DateFormatter()
//        formatterJP.dateFormat = DateFormatter.dateFormat(fromTemplate: "dMEE", options: 0, locale: Locale(identifier: "ja_JP"))
//        formatterJP.timeZone = TimeZone(identifier:  "Asia/Tokyo")
//
//        let day1 = Date(timeIntervalSinceNow: -(60*60*24)) //1日前
//        //  let day2 = Date() //当日 今回これはチャートに表示させない
//        let day3 = Date(timeIntervalSinceNow: 60*60*24) //1日後
//        let day4 = Date(timeIntervalSinceNow: 60*60*48) //2日後
//        let day5 = Date(timeIntervalSinceNow: 60*60*72) //3日後
//        let day6 = Date(timeIntervalSinceNow: 60*60*96) //4日後
//        let day7 = Date(timeIntervalSinceNow: 60*60*120) //5日後
//
//        let time1 = "\(formatterJP.string(from: day1))"
//        //   let time2 = "\(formatterJP.string(from: day2))"　//当日 今回これはチャートに表示させない
//        let time3 = "\(formatterJP.string(from: day3))"
//        let time4 = "\(formatterJP.string(from: day4))"
//        let time5 = "\(formatterJP.string(from: day5))"
//        let time6 = "\(formatterJP.string(from: day6))"
//        let time7 = "\(formatterJP.string(from: day7))"
//
//        //labels配列に１つずつ代入していく
//        labels[0] = time1
//        labels[1] = "今日"  //ここだけ手書きにしてみる
//        labels[2] = time3
//        labels[3] = time4
//        labels[4] = time5
//        labels[5] = time6
//        labels[6] = time7

        //適当に、棒グラフに使う数字をInt型配列で作成
//        let rawData: [Int] = [3, 20, 40, 80, 100, 80, 40]
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
//
//
    }
    
    private func displayChart(data: [Double]) {
        // グラフの範囲を指定する
        //        chartView = LineChartView(frame: CGRect(x: 0, y: 200, width: view.frame.width, height: 400))
        // プロットデータ(y軸)を保持する配列
        var dataEntries = [ChartDataEntry]()
        
        for (xValue, yValue) in data.enumerated() {
            let dataEntry = ChartDataEntry(x: Double(xValue), y: yValue)
            dataEntries.append(dataEntry)
        }
        // グラフにデータを適用
        chartDataSet = LineChartDataSet(entries: dataEntries, label: "SampleDataChart")
        
        chartDataSet.lineWidth = 5.0 // グラフの線の太さを変更
        chartDataSet.mode = .cubicBezier // 滑らかなグラフの曲線にする
        
        lineChartView.data = LineChartData(dataSet: chartDataSet)
        
        // X軸(xAxis)
        lineChartView.xAxis.labelPosition = .bottom // x軸ラベルをグラフの下に表示する
        
        // Y軸(leftAxis/rightAxis)
        lineChartView.leftAxis.axisMaximum = 100 //y左軸最大値
        lineChartView.leftAxis.axisMinimum = 0 //y左軸最小値
        lineChartView.leftAxis.labelCount = 6 // y軸ラベルの数
        lineChartView.rightAxis.enabled = false // 右側の縦軸ラベルを非表示
        
        // その他の変更
        lineChartView.highlightPerTapEnabled = false // プロットをタップして選択不可
        lineChartView.legend.enabled = false // グラフ名（凡例）を非表示
        lineChartView.pinchZoomEnabled = false // ピンチズーム不可
        lineChartView.doubleTapToZoomEnabled = false // ダブルタップズーム不可
        lineChartView.extraTopOffset = 20 // 上から20pxオフセットすることで上の方にある値(99.0)を表示する
        
        lineChartView.animate(xAxisDuration: 2) // 2秒かけて左から右にグラフをアニメーションで表示する
        
        view.addSubview(lineChartView)
    }
    
    private func setupCircleView() {
        
        self.chartsView.centerText = "テストデータ"
        
        // グラフに表示するデータのタイトルと値
        let dataEntries = [
            PieChartDataEntry(value: 40, label: "A"),
            PieChartDataEntry(value: 35, label: "B"),
            PieChartDataEntry(value: 25, label: "C")
        ]
        
        let dataSet = PieChartDataSet(entries: dataEntries, label: "テストデータ")
        
        // グラフの色
        dataSet.colors = ChartColorTemplates.vordiplom()
        // グラフのデータの値の色
        dataSet.valueTextColor = UIColor.black
        // グラフのデータのタイトルの色
        dataSet.entryLabelColor = UIColor.black
        
        self.chartsView.data = PieChartData(dataSet: dataSet)
        
        // データを％表示にする
        let formatter = NumberFormatter()
        formatter.numberStyle = .percent
        formatter.maximumFractionDigits = 2
        formatter.multiplier = 1.0
        self.chartsView.data?.setValueFormatter(DefaultValueFormatter(formatter: formatter))
        //        self.chartsView.usePercentValuesEnabled = true
        
        self.chartsView.animate(xAxisDuration: 2)
        
        view.addSubview(self.chartsView)
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
        
        appDelegate.selfLocation = locValue
        
        searchLocationLibrary(latitude: locValue.latitude, longitude: locValue.longitude) { totalArray in
            
            self.appDelegate.totalArray = totalArray
        }
    }
    
    func searchLocationLibrary(latitude: Double, longitude: Double, completion: @escaping ([Spot]) -> Void) {
        
        let count: Int = 6
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
                    let url_pc = singleData.url_pc
                    
                    let spot = Spot(name: name, systemId: systemid, latitude: latitude, longitude: longitude, distance: distance, url_pc: url_pc)
                    
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
    
    @IBAction func goCartView(_ sender: Any) {
        
        performSegue(withIdentifier: "goCart", sender: nil)
    }
}
