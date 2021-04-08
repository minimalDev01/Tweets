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
    
    // MARK: -IBActions
    @IBAction func addPostAction() {
        savePost()
    }
    
    @IBAction func dismissAction() {
        dismiss(animated: true, completion: nil)
    }
    
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
}
