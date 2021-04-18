//
//  AddPostViewController.swift
//  Tweets
//
//  Created by Sergio Carralero Nuño on 8/4/21.
//

import UIKit
import Simple_Networking
import SVProgressHUD
import NotificationBannerSwift

class AddPostViewController: UIViewController {
    // MARK: -IBOutlet
    @IBOutlet weak var postTextView: UITextView!
    @IBOutlet weak var postButton: UIButton!
    @IBOutlet weak var previewImageView: UIImageView!
    
    // MARK: -IBActions
    @IBAction func addPostAction() {
        savePost()
    }
    
    @IBAction func dismissAction() {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func openCameraAction() {
        openCamera()
    }
    
    // MARK: - Properties
    private var imagePicker: UIImagePickerController?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
    }
    
    // MARK: -Private Methods
    private func setupUI() {
        postButton.layer.cornerRadius = 25
        postTextView.layer.cornerRadius = 10
    }
    
    private func savePost() {
        // 1. Create request
        let request = PostRequest(text: postTextView.text, imageUrl: nil, videUrl: nil, location: nil)
        
        // 2. Loader
        SVProgressHUD.show()
        
        // 3. Call endpoint
        SN.post(endpoint: Endpoints.post, model: request) { (response: SNResultWithEntity<Post, ErrorResponse>) in
            
            // 4. Dismiss loader
            SVProgressHUD.dismiss()
                        
            switch response {
            case .success:
                self.dismiss(animated: true, completion: nil)
            case .error(let error):
                NotificationBanner(title: "Error", subtitle: error.localizedDescription, style: .danger).show()
            case .errorResult(let entity):
                NotificationBanner(title: "Error", subtitle: entity.error, style: .warning).show()
            }
        }
    }
    
    private func openCamera() {
        imagePicker = UIImagePickerController()
        imagePicker?.sourceType = .photoLibrary
        //imagePicker?.cameraFlashMode = .off 
        //imagePicker?.cameraCaptureMode = .photo
        imagePicker?.allowsEditing = true
        imagePicker?.delegate = self
        
        // Check if imagePicker exists in order to execute "present" descripted above, if not return
        guard let imagePicker = imagePicker else {
            return
        }
        
        present(imagePicker, animated: true, completion: nil)
    }
}

// MARK: -UIImagePickerControllerDelegate
extension AddPostViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        // Close camera
        imagePicker?.dismiss(animated: true, completion: nil)
        
        // Check if our posts contain an image
        if info.keys.contains(.originalImage) {
            previewImageView.isHidden = false
            
            // Getting the taken photo
            previewImageView.image = info[.originalImage] as? UIImage
        }
    }
}
