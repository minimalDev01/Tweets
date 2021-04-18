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
import FirebaseStorage

class AddPostViewController: UIViewController {
    // MARK: -IBOutlet
    @IBOutlet weak var postTextView: UITextView!
    @IBOutlet weak var postButton: UIButton!
    @IBOutlet weak var previewImageView: UIImageView!
    
    // MARK: -IBActions
    @IBAction func addPostAction() {
        uploadPhotoToFirebase()
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
    
    private func uploadPhotoToFirebase() {
        // 1. Check if photo exists, compress image and convert into Data
        guard let imageSaved = previewImageView.image,
              let imageSavedData: Data = imageSaved.jpegData(compressionQuality: 0.1) else {
            return
        }
        
        // 2. Show loader
        SVProgressHUD.show()
        
        // 3. Config to save photo in firebase
        let metaDataConfig = StorageMetadata()
        metaDataConfig.contentType = "image/jpg"
        
        // 4. Create ref to firebase storage
        let storage = Storage.storage()
        
        // 5. Create image name to upload
        let imageName = Int.random(in: 100...1000)
        
        // 6. Create ref to the folder where the photo will be saved
        let folderReference = storage.reference(withPath: "tweets-photos/\(imageName).jpg")
        
        // 7. Upload photo to firebase (on secondary thread because of heavyness
        DispatchQueue.global(qos: .background).async {
            folderReference.putData(imageSavedData, metadata: metaDataConfig) { (metaData: StorageMetadata?, error: Error?) in
                // Return to principal thread
                DispatchQueue.main.async {
                    // Dismiss loader
                    SVProgressHUD.dismiss()
                    
                    // Check errors
                    if let error = error {
                        NotificationBanner(title: "Error", subtitle: error.localizedDescription, style: .warning).show()
                        return
                    }
                    
                    // If no error, get download URL
                    folderReference.downloadURL { (url: URL?, error: Error?) in
                        let downloadUrl = url?.absoluteString ?? ""
                        self.savePost(imageUrl: downloadUrl)
                    }
                }
            }
        }
        
    }
    
    private func savePost(imageUrl: String?) {
        // 1. Create request
        let request = PostRequest(text: postTextView.text, imageUrl: imageUrl, videUrl: nil, location: nil)
        
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
