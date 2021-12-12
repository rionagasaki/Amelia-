//
//  PostMapViewController.swift
//  Instagram
//
//  Created by Rio Nagasaki on 2021/10/23.
//

import UIKit
import MapKit
import CoreLocation

class PostMapViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate {
    
    @IBOutlet weak var mapView: MKMapView!
    var latitude = ""
    var longitude = ""
    var placeMark = ""
    
    @IBAction func backButton(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    

    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self
        
        let Latitude:Double = Double(latitude)!
        let Longitude:Double = Double(longitude)!
        
        let center: CLLocationCoordinate2D = CLLocationCoordinate2DMake(Latitude, Longitude)
        let span: MKCoordinateSpan = MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
        let region:MKCoordinateRegion = MKCoordinateRegion(center: center, span: span)
        mapView.setRegion(region, animated: true)
        
        let annotation = MKPointAnnotation()
        annotation.coordinate = CLLocationCoordinate2DMake(CLLocationDegrees(latitude)!,CLLocationDegrees(longitude)!)
        annotation.title = placeMark
        self.mapView.addAnnotation(annotation)

        
    }
    
    
    

   

}
