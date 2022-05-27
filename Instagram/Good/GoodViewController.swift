//
//  GoodViewController.swift
//  Instagram
//
//  Created by Rio Nagasaki on 2021/12/08.
//

import UIKit
import Firebase
import Nuke

class GoodViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    var likes: [String] = []
    var postImage = ""
    let followData:[Following] = []
    var selectedFollowArray:[Following] = []
    
    @IBOutlet weak var imageView: UIImageView!
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return selectedFollowArray.count
    }
   
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! GoodTableViewCell
        cell.setGood(selectedFollowArray[indexPath.row])
        return cell
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        for i in self.likes{
        let db = Firestore.firestore()
        let followRef = db.collection(Const.FollowPath).document(i)
            followRef.getDocument{ (snap, error) in
                if error != nil {
                    return
                }
                
                
                
                
                let goodData = Following(document: snap!)
                self.selectedFollowArray.append(goodData)
                self.tableView.reloadData()
                
                
            }
            
        }
        
    }
   
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.selectedFollowArray.removeAll()
    }

    
    
    
    @IBAction func backButton(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBOutlet weak var tableView: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.overrideUserInterfaceStyle = .light
        tableView.delegate = self
        tableView.dataSource = self
        let nib = UINib(nibName: "GoodTableViewCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: "Cell")
        Nuke.loadImage(with: postImage, into: imageView)
        imageView.contentMode = .scaleAspectFill
        imageView.layer.borderWidth = 1
        imageView.layer.borderColor = UIColor.orange.cgColor
        
        

    }
    
}
    

 


