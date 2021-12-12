//
//  ReportViewController.swift
//  Instagram
//
//  Created by Rio Nagasaki on 2021/11/24.
//

import UIKit
import Firebase
import SVProgressHUD


class ReportViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextViewDelegate{
    
    @IBOutlet weak var reportDesign: UIButton!
    
    let report = ["不適切な画像や、位置情報", "スパム等の不適切な内容", "嫌がらせ、迷惑行為", "自傷行為のほのめかし", "その他"]
    var reportID = ""
    var reportUID = ""
    var reportName = ""
    var reportPlaceMark = ""
    var problemNumbers:[Int] = []
    
    @IBOutlet weak var textView: UITextView!
    
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return report.count
    }
    
  
    
    
   
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell =
            tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! ReportTableViewCell
        cell.uiLabel.text = report[indexPath.row]
        cell.uiSwitch.tag = indexPath.row
        cell.uiSwitch.addTarget(self, action: #selector(changeSwitch(_:)), for: UIControl.Event.valueChanged)
        
        
        return cell
    }
    
    @objc func changeSwitch(_ sender: UISwitch){
        print("セル番号\(sender.tag)は\(sender.isOn)")
          problemNumbers = []
        
        if sender.isOn == true {
            self.problemNumbers.append(sender.tag)
            print()
        }
        
    }
   
    
    @IBAction func backButton(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.overrideUserInterfaceStyle = .light
        reportDesign.layer.cornerRadius = 15.0
        tableView.delegate = self
        tableView.dataSource = self
        
        
        
        textView.delegate = self
        let tapGR: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
               tapGR.cancelsTouchesInView = false
               self.view.addGestureRecognizer(tapGR)
        
        
        let nib = UINib(nibName: "ReportTableViewCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: "Cell")
       
    }
    
    @objc func dismissKeyboard() {
           self.view.endEditing(true)
       }
    
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if (self.textView.isFirstResponder) {
            self.textView.resignFirstResponder()
        }
    }
    
    
    
    
    @IBAction func sendButton(_ sender: Any) {
        let reportRef = Firestore.firestore().collection(Const.ReportPath).document()
    
        let reportDic = [
            "id": reportID,
            "name": "\(reportName)の投稿への通報",
            "uid": reportUID,
            "place": reportPlaceMark,
            "problem": self.problemNumbers,
            "text": self.textView.text ?? ""
            
        ] as [String : Any]
        
        reportRef.setData(reportDic)
        SVProgressHUD.showSuccess(withStatus: "この投稿は通報されました。ありがとうございました。")
        self.dismiss(animated: true)
        
    }
    
 

}
