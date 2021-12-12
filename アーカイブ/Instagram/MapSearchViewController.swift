//
//  MapSearchViewController.swift
//  Instagram
//
//  Created by Rio Nagasaki on 2021/10/04.
//

import UIKit
import MapKit
import CoreLocation
import Firebase
import SVProgressHUD

class MapSearchViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate, UISearchBarDelegate{
    
    
    @IBOutlet weak var searchLocation: UISearchBar!
    
    @IBOutlet weak var mapView: MKMapView!
    
    
    var searchedMapItems:[MKMapItem]! = []
    var locationManager = CLLocationManager()
    var latitudeNow: String = ""
    var longitudeNow: String = ""
    var which: Bool = false
    var titleNow: String = ""
    
    
    override func viewDidLoad() {
        which = false
        super.viewDidLoad()
        searchLocation.delegate = self
        mapView.delegate = self
        locationManager = CLLocationManager()
        locationManager.requestAlwaysAuthorization()
        locationManager.requestWhenInUseAuthorization()
        
        
        if CLLocationManager.locationServicesEnabled(){
            locationManager.delegate = self
            locationManager.startUpdatingLocation()
            searchLocation.delegate = self
            
            
            
        }
    }
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        print("OK")
        
        if view.annotation!.title != "My Location"{
        let postViewController = self.presentingViewController as! PostViewController
        postViewController.latitude = "\(view.annotation!.coordinate.latitude)"
        postViewController.longitude = "\(view.annotation!.coordinate.longitude)"
        postViewController.placeMark = view.annotation!.title!!
        print("オプショナル\(String(describing: view.annotation!.title!))")
        SVProgressHUD.showSuccess(withStatus: "位置情報の取得に成功しました")
        
        dismiss(animated: true, completion: nil)
        }else{
            SVProgressHUD.showError(withStatus: "お店のピンをタップしてね。")
        }
        
    }
    
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        if which == false{
            let location = locations.first
            let latitude = location?.coordinate.latitude
            let longitude = location?.coordinate.longitude
            self.latitudeNow = String(latitude!)
            self.longitudeNow = String(longitude!)
            let center = CLLocationCoordinate2DMake(CLLocationDegrees(self.latitudeNow)!, CLLocationDegrees(self.longitudeNow)!)
            print(center)
            let span = MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
            let region = MKCoordinateRegion(center: center, span: span)
            mapView.setRegion(region, animated: true)
            searchLocation.delegate = self
            which = true
            
        }
        
        
        
        
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        
        
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = searchLocation.text
        print(searchLocation.text!)
        request.region = mapView.region
        let localSearch:MKLocalSearch = MKLocalSearch(request: request)
        localSearch.start(completionHandler: ({(result, error)in
            for placemark in (result!.mapItems){
                if(error == nil){
                    let annotation = MKPointAnnotation()
                    annotation.coordinate = CLLocationCoordinate2DMake(placemark.placemark.coordinate.latitude, placemark.placemark.coordinate.longitude)
                    
                    annotation.title = placemark.placemark.name ?? ""
                    
                    annotation.subtitle = placemark.placemark.title
                    
                    self.mapView.addAnnotation(annotation)
                } else{
                    print(error!)
                }
            }
            
        }))
    }
    
    
    
    
}





