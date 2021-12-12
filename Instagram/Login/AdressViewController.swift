//
//  AdressViewController.swift
//  Instagram
//
//  Created by Rio Nagasaki on 2021/11/29.
//

import UIKit
import Firebase
import SVProgressHUD
import CoreLocation


class AdressViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return dataSource.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return dataSource[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        self.selectedData = dataSource[row]
    }
    
    
    @IBOutlet weak var addressText: UITextField!
    @IBOutlet weak var skipButton: UIButton!
    
    @IBOutlet weak var genderLabel: UILabel!
    @IBOutlet weak var send: UIButton!
    @IBOutlet weak var userPicker: UIPickerView!
    
    
    @IBAction func skip(_ sender: Any) {
        UIApplication.shared.windows.first{ $0.isKeyWindow }?.rootViewController?.dismiss(animated: true, completion: nil)
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)
        generator.prepare()
        SVProgressHUD.showSuccess(withStatus: "Amelia!へようこそ。")
        
        
    }
    
    
    var dataSource = ["中学生以下","高校生","大学生","社会人"]
    var selectedData = ""

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let tapGR: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
               tapGR.cancelsTouchesInView = false
               self.view.addGestureRecognizer(tapGR)
        
        send.layer.cornerRadius = 15.0
        userPicker.delegate = self
        userPicker.dataSource = self
        skipButton.layer.cornerRadius = 15.0
        

        
    }
    @IBAction func sendButton(_ sender: Any) {
        if addressText.text == "" {
            SVProgressHUD.showError(withStatus: "郵便番号を入力してください。")
            return
        }
        
        if genderLabel.text == "" {
            SVProgressHUD.showError(withStatus: "性別を選択してください。")
            return
            
        }
        let uid = Auth.auth().currentUser?.uid
        let addRef = Firestore.firestore().collection(Const.FollowPath).document(uid!)
        
        addRef.updateData(["address": addressText.text!, "gender": genderLabel.text!, "status": self.selectedData])
        UIApplication.shared.windows.first{ $0.isKeyWindow }?.rootViewController?.dismiss(animated: true, completion: nil)
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)
        generator.prepare()
        SVProgressHUD.showSuccess(withStatus: "ユーザー情報を入力しました。")
        
        
    }
    
    @objc func dismissKeyboard() {
           self.view.endEditing(true)
       }
    
    @IBAction func femaleButton(_ sender: Any) {
        let select = UINotificationFeedbackGenerator()
        select.notificationOccurred(.success)
        select.prepare()
        genderLabel.text = "女性"
        genderLabel.textColor = .red
    }
    
    @IBAction func maleButton(_ sender: Any) {
        let select = UINotificationFeedbackGenerator()
        select.notificationOccurred(.success)
        select.prepare()
        genderLabel.text = "男性"
        genderLabel.textColor = .blue
    }
}
