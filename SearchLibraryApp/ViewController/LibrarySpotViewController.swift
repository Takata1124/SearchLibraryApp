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
    
    let appDelegate: AppDelegate = UIApplication.shared.delegate as! AppDelegate
    
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
        self.navigationItem.hidesBackButton = true

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
        
        if let locValue: CLLocationCoordinate2D = manager.location?.coordinate {
        
            let location: CLLocationCoordinate2D = CLLocationCoordinate2DMake(locValue.latitude, locValue.longitude)
            
            mapView.setCenter(location,animated:true)
            
            var region: MKCoordinateRegion = mapView.region
            region.center = location
            region.span.latitudeDelta = 0.03
            region.span.longitudeDelta = 0.03
            
            mapView.setRegion(region,animated:true)
            
            let pin = MKPointAnnotation()
            pin.coordinate = CLLocationCoordinate2DMake(locValue.latitude, locValue.longitude)
            pin.title = "現在地"
            
            self.currentPlace = MKPlacemark(coordinate: CLLocationCoordinate2D(latitude: locValue.latitude, longitude: locValue.longitude))
            
            mapView.addAnnotation(pin)
            
            appDelegate.totalArray.forEach { spot in

                let pin = MKPointAnnotation()
                pin.coordinate = CLLocationCoordinate2DMake(Double(spot.latitude)!, Double(spot.longitude)!)
                pin.title = spot.name
                self.mapView.addAnnotation(pin)
            }
            
            mapView.delegate = self
        }
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
}
