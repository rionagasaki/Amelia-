//
//  MyFavoriteViewController.swift
//  Instagram
//
//  Created by Rio Nagasaki on 2021/11/26.
//

import UIKit
import Firebase

class MyFavoriteViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    
    var MyFavoriteArray: [MyFavorite] = []
    var selectedMyFavoriteArray: [MyFavorite] = []
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return selectedMyFavoriteArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! MyFavoriteTableViewCell
        cell.setFavorite(selectedMyFavoriteArray[indexPath.row])
        cell.postButton.addTarget(self, action: #selector(pushButton(_:forEvent:)), for: .touchUpInside )
        
        
        return cell
    }
    
    @objc func pushButton(_ sender: UIButton, forEvent event: UIEvent){
        let touch = event.allTouches?.first
        let point = touch!.location(in: self.tableView)
        let indexPath = tableView.indexPathForRow(at: point)
        let myData = selectedMyFavoriteArray[indexPath!.row]
        
        let alert: UIAlertController = UIAlertController(title: "投稿しませんか？", message: "あなたの感想を友達に教えてあげましょう。", preferredStyle: UIAlertController.Style.alert)
        
        let cancelAction: UIAlertAction = UIAlertAction(title: "キャンセル", style: UIAlertAction.Style.default, handler: {_ in
            alert.dismiss(animated: true, completion: nil)
        })

        let defaultAction: UIAlertAction = UIAlertAction(title: "投稿する", style: UIAlertAction.Style.default, handler: {_ in
            let imageSelectViewController = self.storyboard?.instantiateViewController(withIdentifier: "ImageSelect") as! ImageSelectViewController
            
            self.present(imageSelectViewController, animated: true, completion: nil)
            })
        
        let deleteAction: UIAlertAction = UIAlertAction(title: "リストから削除", style: UIAlertAction.Style.default, handler: {_ in
            let alertRef = Firestore.firestore().collection(Const.FavoritePath).document(myData.id!)
            alertRef.delete(){ error in
                if error != nil{
                return
            }
            print("delete成功")
               
            }
            self.reload()
            })
        alert.addAction(defaultAction)
        alert.addAction(deleteAction)
        alert.addAction(cancelAction)
        present(alert, animated: true, completion: nil)

        
        
    }
    
    func reload(){
        let uid = Auth.auth().currentUser?.uid
        let favoriteRef = Firestore.firestore().collection(Const.FavoritePath).whereField("uid", isEqualTo: uid!)
        favoriteRef.getDocuments{ (querySnapshot, error) in
            if error != nil{
                return
            }
            self.selectedMyFavoriteArray.removeAll()
            self.selectedMyFavoriteArray = []
            self.MyFavoriteArray = querySnapshot!.documents.map{
                document in
                let favoriteData = MyFavorite(document: document)
                if favoriteData.uid == uid! {
                self.selectedMyFavoriteArray.append(favoriteData)
                self.tableView.reloadData()
                }
                return favoriteData
            }
           
            
            
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let uid = Auth.auth().currentUser?.uid
        let favoriteRef = Firestore.firestore().collection(Const.FavoritePath).whereField("uid", isEqualTo: uid!)
        favoriteRef.getDocuments{ (querySnapshot, error) in
            if error != nil{
                return
            }
            self.selectedMyFavoriteArray.removeAll()
            self.selectedMyFavoriteArray = []
            self.MyFavoriteArray = querySnapshot!.documents.map{
                document in
                let favoriteData = MyFavorite(document: document)
                if favoriteData.uid == uid! {
                self.selectedMyFavoriteArray.append(favoriteData)
                self.tableView.reloadData()
                }
                return favoriteData
            }
           
            
            
        }
        
        
    }
    

    @IBAction func backButton(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.delegate = self
        tableView.dataSource = self
        
        self.overrideUserInterfaceStyle = .light
        
        let nib = UINib(nibName: "MyFavoriteTableViewCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: "Cell")
        
        
    }
    

   

}
