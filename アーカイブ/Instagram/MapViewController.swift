//
//  MapViewController.swift
//  Instagram
//
//  Created by Rio Nagasaki on 2021/10/02.
//

import UIKit
import MapKit
import CoreLocation
import Firebase
import SVProgressHUD

public extension NSNotification.Name {
    static let refreshmap = NSNotification.Name("refreshmap")
}

class MapViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate {
    
    var annotation = MKPointAnnotation()
    
    
    @IBOutlet weak var challenging: UIButton!
    
    @IBOutlet weak var MapView: MKMapView!
    var latitudeNow = ""
    var longitudeNow = ""
    var pinLocationLatitude = ""
    var pinLocationLongitude = ""
   
    var postArray: [PostData] = []
    var listener: ListenerRegistration?
    var which: Bool = false
    
    var locationManager : CLLocationManager!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        which = false
        MapView.delegate = self
        challenging.layer.cornerRadius = 15.0
        setUpLocation()
        
       
        
     
        }
    
   
       
    
    @objc func refreshmap(_ notification: Notification){
         print("fresh map")
         self.MapView.reloadInputViews()
     }
    
    func setUpLocation(){
        locationManager = CLLocationManager()
        
        guard let locationManager = locationManager else { return }
        locationManager.requestAlwaysAuthorization()
        locationManager.requestWhenInUseAuthorization()
        let manager = CLLocationManager()
        let status = manager.authorizationStatus
        
        if status != .denied, status != .restricted {
            locationManager.delegate = self
            locationManager.startUpdatingLocation()
            print("OK?")
        }else
        {
            return
        }
            
    }
    
    @IBAction func challengeButton(_ sender: Any) {
        
        challenge()
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let annotations = MapView.annotations.filter({ !($0 is MKUserLocation) })
        MapView.removeAnnotations(annotations)
        print("ああああremoveAnnotations")
        
        NotificationCenter.default.addObserver(self, selector: #selector(refreshmap(_:)), name: .refreshmap, object: nil)
        
        
        let uid2 = UserDefaults.standard.string(forKey: "uid")
        if uid2 != Auth.auth().currentUser?.uid {
            
            self.MapView.removeAnnotation(annotation)
            self.MapView.reloadInputViews()
        }
        
        
        let uid = Auth.auth().currentUser?.uid
        let followRef = Firestore.firestore().collection(Const.FollowPath).document(uid!)
        followRef.getDocument{ (document, error) in
            if error != nil{
                return
            }
            guard (document?.data()) != nil else { return }
            let followData = Following(document: document!)
            if followData.follow.count > 0 {
                print("viewWillAppearです")
                let Ref = Firestore.firestore().collection(Const.PostPath).whereField("uid", in: followData.follow).whereField("uid", isNotEqualTo: uid!)
                print("ref\(Ref)")
                self.listener = Ref.addSnapshotListener(){ [self] (querySnapshot, error) in
                    if let error = error{
                        print(error)
                        return
                    }
                    
                    self.postArray = querySnapshot!.documents.map { document in
                        let annotation = MKPointAnnotation()
                        MapView.removeAnnotation(annotation)
                        print("remove")
                        let postData = PostData(document: document)
                        print("POST ARRAY 0\(self.postArray)")
                        let latitude = postData.Latitude
                        let longitude = postData.Longitude
                        let placeMark = postData.placeMark
                            
                       
                        annotation.coordinate = CLLocationCoordinate2DMake(CLLocationDegrees(latitude)!,CLLocationDegrees(longitude)!)
                        if (postData.challenge_uid.firstIndex(of: followData.id) != nil){
                            annotation.title = "\(placeMark ?? "")⇦🟤済"
                            
                        }else {
                            annotation.title = "\(placeMark ?? "")⇦🟠未"
                        }
                        self.postArray.append(postData)
                        print("postData\(postData)")
                        
                       
                        self.MapView.addAnnotation(annotation)
                        let manager = CLLocationManager()
                        let status = manager.authorizationStatus
                        if status != .denied, status != .restricted, latitudeNow != ""{
                        self.challenge()
                        }
                        return postData
                        
                        
                    }
                    
                    self.MapView.reloadInputViews()
                    
                }
                
            }
        }
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        let annotation = MapView.dequeueReusableAnnotationView(withIdentifier: "annotation")
        return annotation
    }
    
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillAppear(animated)
        print (" DEBUG_PRINT: viewWillDisappear")
        listener?.remove()
        self.MapView.removeAnnotation(annotation)
        self.MapView.reloadInputViews()
    }
    
  
    
    
    @IBAction func howToButton(_ sender: Any) {
        let howToMapViewController = self.storyboard?.instantiateViewController(withIdentifier: "HowToMap") as! HowToMapViewController
        self.present(howToMapViewController, animated: true, completion: nil)
    }
   
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        
        self.pinLocationLatitude = String(view.annotation!.coordinate.latitude)
        self.pinLocationLongitude = String(view.annotation!.coordinate.longitude)
        let toDistance = CLLocation(latitude: view.annotation!.coordinate.latitude, longitude: view.annotation!.coordinate.longitude)
        let fromDistance = CLLocation(latitude: Double(self.latitudeNow)!, longitude: Double(self.latitudeNow)!)
        let distance = toDistance.distance(from: fromDistance)
        let alert = UIAlertController(title: "友達が投稿しています。", message: "ぜひ向かってみよう！(投稿地点まで\(distance)m!)", preferredStyle: .actionSheet)
        let post = UIAlertAction(title: "投稿一覧", style: .default) { (action) in
            let selectedHomeViewController = self.storyboard?.instantiateViewController(withIdentifier: "Selected") as! SelectedHomeViewController
            
            selectedHomeViewController.latitude2 = "\(view.annotation!.coordinate.latitude)"
            
            selectedHomeViewController.longitude2 = "\(view.annotation!.coordinate.longitude)"
            
            selectedHomeViewController.placeMark = (String(view.annotation!.title!!.prefix(view.annotation!.title!!.count - 3)))
            
            self.present(selectedHomeViewController, animated: true, completion: nil)
        }
        let route = UIAlertAction(title: "経路", style: .default) { (action) in
            self.MapView.removeOverlays(self.MapView.overlays)
            let destLocation: CLLocationCoordinate2D = CLLocationCoordinate2DMake(CLLocationDegrees(self.pinLocationLatitude)! ,CLLocationDegrees(self.pinLocationLongitude)!)
            let userLocation:CLLocationCoordinate2D = CLLocationCoordinate2DMake(CLLocationDegrees(self.latitudeNow)! ,CLLocationDegrees(self.longitudeNow)!)
            var myRoute: MKRoute!
            let fromPlacemark = MKPlacemark(coordinate: userLocation, addressDictionary: nil)
            let toPlaceMark = MKPlacemark(coordinate: destLocation, addressDictionary: nil)
            
            let fromItem = MKMapItem(placemark: fromPlacemark)
            let toItem = MKMapItem(placemark: toPlaceMark)
            let request = MKDirections.Request()
            request.source = fromItem
            request.destination = toItem
            let direction = MKDirections(request: request)
            direction.calculate(completionHandler: {(response, error) in
                if error == nil {
                    myRoute = response?.routes[0]
                    self.MapView.addOverlay(myRoute.polyline, level: .aboveRoads)
                }
            })
            
            request.transportType = .walking
            
            
        }
        
        let cancel = UIAlertAction(title: "キャンセル", style: .cancel) { (acrion) in
            self.dismiss(animated: true, completion: nil)
        }
        alert.addAction(cancel)
        alert.addAction(post)
        alert.addAction(route)
        present(alert, animated: true, completion: nil)
    }
    
  
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let route: MKPolyline = overlay as! MKPolyline
                let routeRenderer: MKPolylineRenderer = MKPolylineRenderer(polyline: route)

                routeRenderer.lineWidth = 3.0

                routeRenderer.strokeColor = UIColor.red
                return routeRenderer
    }
    
    
    
    
    func challenge(){
       
        let manager = CLLocationManager()
        let status = manager.authorizationStatus
        
        if status != .denied, status != .restricted {
        let location2: CLLocationCoordinate2D = CLLocationCoordinate2DMake(CLLocationDegrees(self.latitudeNow)! ,CLLocationDegrees(self.longitudeNow)!)
        
        var region: MKCoordinateRegion = MapView.region
        
        region.center = location2
        region.span.latitudeDelta = 0.01
        region.span.longitudeDelta = 0.01
        print(location2)
        
        MapView.setRegion(region, animated: true)
        
        print("POST ARRAY\(self.postArray)")
        
        for postData in self.postArray {
            print("確認1")
            let latitude = Double(postData.Latitude)!
            let longitude = Double(postData.Longitude)!
            let latitudeNow = Double(latitudeNow)!
            let longitudeNow = Double(longitudeNow)!
            let myid = (Auth.auth().currentUser?.uid)!
            let location = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
            let center = CLLocationCoordinate2D(latitude: latitudeNow, longitude: longitudeNow)
            let radius: CLLocationDistance = 50
            let circularRegion = CLCircularRegion(center: center, radius: radius, identifier: "identifier")
            if circularRegion.contains(location) && (postData.challenge_uid.firstIndex(of: myid) == nil) {
                let Latitude:String = String(location.latitude)
                let Longitude:String = String(location.longitude)
                
                print("確認2\(circularRegion.contains(location))")
                let alert: UIAlertController = UIAlertController(title: "チャレンジ！", message: "投稿スポットの近くに来たので、じゃんけんに挑戦ができるよ！ぜひ挑戦してみよう！", preferredStyle: UIAlertController.Style.alert)
                
                let cancelAction: UIAlertAction = UIAlertAction(title: "キャンセル", style: UIAlertAction.Style.default, handler: {_ in
                    self.dismiss(animated: true, completion: nil)
                })
                
                
                let defaultAction: UIAlertAction = UIAlertAction(title: "チャレンジ", style: UIAlertAction.Style.default, handler: {_ in
            
                    for postData in self.postArray{
                        let uid = Auth.auth().currentUser?.uid
                        let challengeRef = Firestore.firestore().collection(Const.PostPath).document(postData.id)
                        challengeRef.getDocument{
                            (document, error) in
                            if error != nil {
                                return
                            }
                            if postData.Latitude == Latitude && postData.Longitude == Longitude{
                                
                                var updateValue: FieldValue
                                updateValue = FieldValue.arrayUnion([uid!])
                                challengeRef.updateData(["challenge_uid": updateValue])
                                
                                
                            }
                        }
                    }
                    let challengeViewController = self.storyboard?.instantiateViewController(identifier: "Challenge") as! ChallengeViewController
                    self.present(challengeViewController, animated: true, completion: nil)
                    
                    
                    })
                
              
                
                alert.addAction(defaultAction)
                alert.addAction(cancelAction)
                present(alert, animated: true, completion: nil)
                return

                
            }else {
              
            }
            
            
        }
    }
        else {
            showAlert()
        }
    }
    
    func showAlert(){
        let alertTitle = "位置情報取得が許可されていません。"
            let alertMessage = "設定アプリの「プライバシー > 位置情報サービス」から変更してください。"
            let alert: UIAlertController = UIAlertController(
                title: alertTitle,
                message: alertMessage,
                preferredStyle:  UIAlertController.Style.alert
            )
            // OKボタン
            let defaultAction: UIAlertAction = UIAlertAction(
                title: "OK",
                style: UIAlertAction.Style.default,
                handler: nil
            )
            // UIAlertController に Action を追加
            alert.addAction(defaultAction)
            // Alertを表示
            present(alert, animated: true, completion: nil)
    }
    
   func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        if which == false{
            print("確認０")
            let location = locations.first
            let latitude = location?.coordinate.latitude
            let longitude = location?.coordinate.longitude
            self.latitudeNow = String(latitude!)
            self.longitudeNow = String(longitude!)
            print("Now\(self.latitudeNow)")
            
            
          
    }
}
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("失敗error")
    }

}
