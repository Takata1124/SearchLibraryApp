//
//  LibrarySpotViewController.swift
//  SearchLibraryApp
//
//  Created by t032fj on 2022/04/27.
//

import UIKit
import MapKit
import CoreLocation
import Alamofire

class LibrarySpotViewController: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate {
    
    @IBOutlet weak var mapView: MKMapView!
    
    var locationManager: CLLocationManager!
    var currentPlace: MKPlacemark?
    var route: MKRoute?
    
    @IBOutlet weak var spendTimeText: UILabel!

    var spendTime: Double = 0 {
        didSet {
            let time = spendTime.description.prefix(4)
            spendTimeText.text = "歩いて\(time)分かかります"
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.title = "図書館"

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
        
        let location: CLLocationCoordinate2D = CLLocationCoordinate2DMake(locValue.latitude, locValue.longitude)
        
        mapView.setCenter(location,animated:true)
        
        var region: MKCoordinateRegion = mapView.region
        region.center = location
        region.span.latitudeDelta = 0.05
        region.span.longitudeDelta = 0.05
        
        mapView.setRegion(region,animated:true)
        
        let pin = MKPointAnnotation()
        pin.coordinate = CLLocationCoordinate2DMake(locValue.latitude, locValue.longitude)
        pin.title = "現在地"
        
        self.currentPlace = MKPlacemark(coordinate: CLLocationCoordinate2D(latitude: locValue.latitude, longitude: locValue.longitude))
        
        mapView.addAnnotation(pin)
        
        searchLocationLibrary(latitude: locValue.latitude, longitude: locValue.longitude) { totalArray in
            
            totalArray.forEach { spot in
                let pin = MKPointAnnotation()
                pin.coordinate = CLLocationCoordinate2DMake(Double(spot.latitude)!, Double(spot.longitude)!)
                pin.title = spot.name
                self.mapView.addAnnotation(pin)
            }
        }
        
        mapView.delegate = self
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        
        if self.route != nil{
            self.mapView.removeOverlay(self.route!.polyline)
        }
        
        guard let annotation = view.annotation else { return }
        
        let selectPlace = MKPlacemark(coordinate: CLLocationCoordinate2D(latitude: annotation.coordinate.latitude, longitude: annotation.coordinate.longitude))
        
        let request = MKDirections.Request()
        request.source = MKMapItem(placemark: currentPlace!)
        request.destination = MKMapItem(placemark: selectPlace)
        request.transportType = .walking
        
        let directions = MKDirections(request: request)
        directions.calculate { response, error in
            guard let route = response?.routes.first else { return }
            self.route = route
            mapView.addOverlay(route.polyline)
            let time = route.expectedTravelTime / 60
            
            self.spendTime = time
            
            mapView.setVisibleMapRect(
                route.polyline.boundingMapRect,
                edgePadding: UIEdgeInsets(top: 40, left: 40, bottom: 40, right: 40),
                animated: true)
        }
    }
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        
        let renderer = MKPolylineRenderer(overlay: overlay)
        renderer.strokeColor = UIColor.blue
        renderer.lineWidth = 2.0
        return renderer
    }
    
    @IBAction func goBack(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    func searchLocationLibrary(latitude: Double, longitude: Double, completion: @escaping ([Spot]) -> Void) {
        
        let count: Int = 10
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
}
