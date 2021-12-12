//
//  FriendMapViewController.swift
//  Instagram
//
//  Created by Rio Nagasaki on 2021/10/20.
//

import UIKit
import MapKit
import CoreLocation
import Firebase

class FriendMapViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate {
    
    var latitudeNow = ""
    var longitudeNow = ""
    var locationManager: CLLocationManager!
    var which: Bool = false
    var id: String = ""
    var postArray: [PostData] = []
    @IBOutlet weak var friendMap: MKMapView!
    
    @IBAction func backButton(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        which = false
        friendMap.delegate = self
        locationManager = CLLocationManager()
        locationManager.requestAlwaysAuthorization()
        locationManager.requestWhenInUseAuthorization()
        if CLLocationManager.locationServicesEnabled(){
            locationManager.delegate = self
            locationManager.startUpdatingLocation()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        if which == false{
            let location = locations.first
            let latitude = location?.coordinate.latitude
            let longitude = location?.coordinate.longitude
            self.latitudeNow = String(latitude!)
            self.longitudeNow = String(longitude!)
            
            let location2: CLLocationCoordinate2D = CLLocationCoordinate2DMake(CLLocationDegrees(self.latitudeNow)! ,CLLocationDegrees(self.longitudeNow)!)
            
            var region: MKCoordinateRegion = friendMap.region
            
            region.center = location2
            
            region.span.latitudeDelta = 0.01
            region.span.longitudeDelta = 0.01
            print(location2)
            
            friendMap.setRegion(region, animated: true)
            which = true
        }
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let followRef = Firestore.firestore().collection(Const.PostPath)
        
        followRef.getDocuments{
            (snap, error) in
            if error != nil {
                print("errorです")
                return
            }
            self.postArray = snap!.documents.map{
                document in
                let postData = PostData(document: document)
                if postData.uid == self.id{
                    let latitude = postData.Latitude
                    let longitude = postData.Longitude
                    let annotation = MKPointAnnotation()
                    annotation.coordinate = CLLocationCoordinate2DMake(CLLocationDegrees(latitude)!,CLLocationDegrees(longitude)!)
                    annotation.title = postData.placeMark
                    self.friendMap.addAnnotation(annotation)
                }
                
                return postData
            }
        }
        
        
        
        
        
    }
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        let friendHomeViewController = self.storyboard?.instantiateViewController(withIdentifier: "FriendMap") as! FriendHomeViewController
        
        friendHomeViewController.latitude2 = "\(view.annotation!.coordinate.latitude)"
        friendHomeViewController.id = self.id
        friendHomeViewController.longitude2 = "\(view.annotation!.coordinate.longitude)"
        
        self.present(friendHomeViewController, animated: true, completion: nil)
    }
    
    
    
}

