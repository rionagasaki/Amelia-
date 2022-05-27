//
//  ImageSelectViewController.swift
//  Instagram
//
//  Created by Rio Nagasaki on 2021/09/21.
//

import UIKit
import CLImageEditor
import Lottie

class ImageSelectViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, CLImageEditorDelegate {
    
    @IBOutlet weak var libraryButton: UIButton!
    
    @IBOutlet weak var cameraButton: UIButton!
    @IBOutlet weak var cancelButton: UIButton!
    
    
    
    
    @IBAction func handleCamera(_ sender: Any) {
        
        
        if UIImagePickerController.isSourceTypeAvailable(.camera){
            let pickerController = UIImagePickerController()
            pickerController.delegate = self
            pickerController.sourceType = .camera
            self.present(pickerController, animated: true, completion: nil)
        }}
    
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info:[UIImagePickerController.InfoKey : Any]){
        if info[.originalImage] != nil{
            let image = info[.originalImage]as! UIImage
            print ("DEBUG_PRINT: image = \(image)")
            let editor = CLImageEditor(image: image)!
            editor.delegate = self
            editor.modalPresentationStyle = .fullScreen
            picker.present(editor, animated: true, completion: nil)}}
    
    
    func imageEditor(_ editor: CLImageEditor!, didFinishEditingWith image: UIImage!){
        let postViewController = self.storyboard?.instantiateViewController(identifier: "Post")as! PostViewController
        postViewController.image = image!
        editor.present(postViewController, animated: true, completion: nil)    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController){
        self.presentingViewController?.dismiss(animated: true, completion: nil)
    }
    func imageEditorDidCancel(_ editor: CLImageEditor!) {
        self.presentingViewController?.dismiss(animated: true, completion: nil)
    }
    
    
    @IBAction func handleLibraryButton(_ sender: Any) {
        
        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary){
            let pickerController  = UIImagePickerController()
            pickerController.delegate = self
            pickerController.sourceType = .photoLibrary
            self.present(pickerController, animated: true, completion: nil)
        }
    }
    
    
    
    
    
    
    
    
    
    @IBAction func backButton(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    
    
  
    
    
   
    
    override func viewDidLoad() {
        super.viewDidLoad()
       
        libraryButton.layer.cornerRadius = 15.0
        cameraButton.layer.cornerRadius = 15.0


        libraryButton.layer.shadowOffset = CGSize(width: 0.0, height: 3.0)
        libraryButton.layer.shadowColor = UIColor.black.cgColor
        libraryButton.layer.shadowOpacity = 0.5
        libraryButton.layer.shadowRadius = 4
        libraryButton.alpha = 0.9


        cameraButton.layer.shadowOffset = CGSize(width: 0.0, height: 3.0)
        cameraButton.layer.shadowColor = UIColor.black.cgColor
        cameraButton.layer.shadowOpacity = 0.5
        cameraButton.layer.shadowRadius = 4
        cameraButton.alpha = 0.9
        

       
       
        self.overrideUserInterfaceStyle = .light
        
        let animationView = AnimationView(name: "68898-cameras-and-photography (2)")
        animationView.frame = CGRect(x: 0, y: 200, width: 250, height: 250)
        animationView.center = view.center
        animationView.contentMode = .scaleAspectFit
        animationView.loopMode = .repeat(2)
        animationView.backgroundBehavior = .pauseAndRestore
        animationView.play()
        
        view.addSubview(animationView)
        
        
        
      
    }
    
    
   
}
