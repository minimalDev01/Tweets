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
import AVFoundation
import AVKit
import MobileCoreServices

class AddPostViewController: UIViewController {
    // MARK: -IBOutlet
    @IBOutlet weak var postTextView: UITextView!
    @IBOutlet weak var postButton: UIButton!
    @IBOutlet weak var previewImageView: UIImageView!
    @IBOutlet weak var videoButton: UIButton!
    
    // MARK: -IBActions
    @IBAction func addPostAction() {
        uploadVideoToFirebase()
    }
    
    @IBAction func dismissAction() {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func openCameraAction() {
        let alert = UIAlertController(title: "Camera", message: "Select an option", preferredStyle: .actionSheet)
        
        alert.addAction(UIAlertAction(title: "Photo", style: .default, handler: { _ in
            self.openCamera()
        }))
        
        alert.addAction(UIAlertAction(title: "Video", style: .default, handler: { _ in
            self.openVideoCamera()
        }))
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .destructive, handler: nil))
        
        present(alert, animated: true, completion: nil)
    }
    
    @IBAction func openPreviewAction() {
        guard let currentVideoURL = currentVideoURL else {
            return
        }
        
        let avPlayer = AVPlayer(url: currentVideoURL)
        let avPlayerController = AVPlayerViewController()
        avPlayerController.player = avPlayer
        
        present(avPlayerController, animated: true) {
            // Auto play
            avPlayerController.player?.play()
        }
    }
    
    // MARK: - Properties
    private var imagePicker: UIImagePickerController?
    private var currentVideoURL: URL?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
    }
        
    // MARK: -Private Methods
    private func setupUI() {
        videoButton.isHidden = true
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
                        self.savePost(imageUrl: downloadUrl, videoUrl: nil)
                    }
                }
            }
        }
        
    }
    
    // TASK: Turn this two funcs into one using parameters!
    
    private func uploadVideoToFirebase() {
        // 1. Check if video exists and convert into Data
        guard let currentVideoSavedURL = currentVideoURL,
              let videoData: Data = try? Data(contentsOf: currentVideoSavedURL) else {
            return
        }
        
        // 2. Show loader
        SVProgressHUD.show()
        
        // 3. Config to save video in firebase
        let metaDataConfig = StorageMetadata()
        metaDataConfig.contentType = "video/MP4"
        
        // 4. Create ref to firebase storage
        let storage = Storage.storage()
        
        // 5. Create video name to upload
        let videoName = Int.random(in: 100...1000)
        
        // 6. Create ref to the folder where the photo will be saved
        let folderReference = storage.reference(withPath: "tweets-videos/\(videoName).mp4")
        
        // 7. Upload video to firebase (on secondary thread because of heavyness
        DispatchQueue.global(qos: .background).async {
            folderReference.putData(videoData, metadata: metaDataConfig) { (metaData: StorageMetadata?, error: Error?) in
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
                        self.savePost(imageUrl: nil, videoUrl: downloadUrl)
                    }
                }
            }
        }
        
    }
    
    private func savePost(imageUrl: String?, videoUrl: String?) {
        // 1. Create request
        let request = PostRequest(text: postTextView.text, imageUrl: imageUrl, videUrl: videoUrl, location: nil)
        
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
    
    private func openVideoCamera() {
        imagePicker = UIImagePickerController()
        imagePicker?.sourceType = .photoLibrary
        imagePicker?.mediaTypes = [kUTTypeMovie as String]
        //imagePicker?.cameraFlashMode = .off
        //imagePicker?.cameraCaptureMode = .video
        imagePicker?.videoQuality = .typeMedium
        imagePicker?.videoMaximumDuration = TimeInterval(5)
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
        
        // Check if our posts contain a video, if yes we catch the video URL into the AVPlayer
        if info.keys.contains(.mediaURL), let recordedVideoUrl = (info[.mediaURL] as? URL)?.absoluteURL {
            videoButton.isHidden = false
            currentVideoURL = recordedVideoUrl
        }
    }
}
