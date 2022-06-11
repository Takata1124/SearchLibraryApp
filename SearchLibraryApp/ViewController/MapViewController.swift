//
//  MapViewController.swift
//  SearchLibraryApp
//
//  Created by t032fj on 2022/05/02.
//

import UIKit
import MapKit

class MapViewController: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate {
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var spendingTimeLabel: UILabel!
    
    var spendTime: Double = 0 {
        didSet {
            let time = spendTime.description.prefix(4)
//            spendingTimeLabel.text = "歩いて\(time)分かかります"
        }
    }
    
    var locationManager: CLLocationManager!
    var currentPlace: MKPlacemark?
    var route: MKRoute?
    
    var latitude: String = ""
    var longitude: String = ""
    
    let appDelegate: AppDelegate = UIApplication.shared.delegate as! AppDelegate
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
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
        
//        let location: CLLocationCoordinate2D = CLLocationCoordinate2DMake(locValue.latitude, locValue.longitude)
        
        let pin = MKPointAnnotation()
        pin.coordinate = CLLocationCoordinate2DMake(locValue.latitude, locValue.longitude)
        pin.title = "現在地"
        
        self.currentPlace = MKPlacemark(coordinate: CLLocationCoordinate2D(latitude: locValue.latitude, longitude: locValue.longitude))
        
        mapView.addAnnotation(pin)
        
        let goal = MKPointAnnotation()
        goal.coordinate = CLLocationCoordinate2DMake(Double(self.latitude)!, Double(self.longitude)!)
        goal.title = "目的地"
        self.mapView.addAnnotation(goal)

        mapView.delegate = self

        let selectPlace = MKPlacemark(coordinate: CLLocationCoordinate2D(latitude: Double(self.latitude) ?? 0, longitude: Double(self.longitude) ?? 0))

        let request = MKDirections.Request()
        request.source = MKMapItem(placemark: currentPlace!)
        request.destination = MKMapItem(placemark: selectPlace)
        request.transportType = .walking

        let directions = MKDirections(request: request)
        directions.calculate { response, error in
            
            guard let route = response?.routes.first else { return }
            self.route = route
            self.mapView.addOverlay(route.polyline)
            let time = route.expectedTravelTime / 60

            self.spendTime = time

            self.mapView.setVisibleMapRect(
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
    
    @IBAction func goBackView(_ sender: Any) {
        
        self.navigationController?.popViewController(animated: true)
    }
}
