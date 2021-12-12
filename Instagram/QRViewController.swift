//
//  QRViewController.swift
//  Instagram
//
//  Created by Rio Nagasaki on 2021/12/06.
//

import UIKit
import Firebase
import AVFoundation

class QRViewController: UIViewController {
    
    
    @IBAction func backButton(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    private let session = AVCaptureSession()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let uid = Auth.auth().currentUser?.uid
        let data = uid?.data(using: String.Encoding.utf8)
        
        let qr = CIFilter(name: "CIQRCodeGenerator", parameters: ["inputMessage": data!])
        let sizeTransform = CGAffineTransform(scaleX: 10, y: 10)
        let qrlImage = qr?.outputImage!.transformed(by: sizeTransform)
        let context = CIContext()
        let cgImage = context.createCGImage(qrlImage!, from: qrlImage!.extent)
        let uiImage = UIImage(cgImage: cgImage!)
        let qrlImageView = UIImageView()
        qrlImageView.contentMode = .scaleAspectFit
        qrlImageView.frame = self.view.frame
        qrlImageView.image = uiImage
        self.view.addSubview(qrlImageView)
       
    }
    


}
