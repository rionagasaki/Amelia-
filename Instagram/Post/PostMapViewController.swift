//
//  PostMapViewController.swift
//  Instagram
//
//  Created by Rio Nagasaki on 2021/10/23.
//

import UIKit
import MapKit
import CoreLocation
import SVProgressHUD
import Firebase

class PostMapViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate {
    
    
    
    @IBOutlet weak var mapView: MKMapView!
    var latitude = ""
    var longitude = ""
    var placeMark = ""
    var postImage = ""
    
    @IBAction func backButton(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func favoriteButton(_ sender: Any) {
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.warning)
        generator.prepare()
        
        let uid = Auth.auth().currentUser?.uid
        
        
        let followRef = Firestore.firestore().collection(Const.FollowPath).document(uid!)
        followRef.getDocument{ (snap, error) in
            if error != nil {
                return
            }
            let followData = Following(document: snap!)
            let updateCount = followData.count
            let stringCount:String = updateCount!.description
            let ref = Storage.storage().reference().child("profile_image").child(uid! + stringCount)
            ref.downloadURL{ (url, error) in
                if error != nil {
                    return
                }
                
                
                guard let urlString = url?.absoluteString else {return}
        
        let favotiteRef = Firestore.firestore().collection(Const.FavoritePath).document()
        let favoriteDic = [
            "profileImage": self.postImage ,
            "uid": uid!,
            "date": FieldValue.serverTimestamp(),
            "placeMark": self.placeMark
        ] as [String : Any]
        favotiteRef.setData(favoriteDic)
        SVProgressHUD.showSuccess(withStatus: "{私の行きたいリスト}に追加しました。")
        
        }
        
    }
    }
    
    @IBOutlet weak var favotite: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self
        favotite.layer.cornerRadius = 15.0
        self.overrideUserInterfaceStyle = .light
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
