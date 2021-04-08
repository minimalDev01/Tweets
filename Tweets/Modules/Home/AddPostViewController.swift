//
//  AddPostViewController.swift
//  Tweets
//
//  Created by Sergio Carralero Nuño on 8/4/21.
//

import UIKit

class AddPostViewController: UIViewController {
    // MARK: -IBOutlet
    @IBOutlet weak var postTextView: UITextView!
    @IBOutlet weak var postButton: UIButton!
    
    // MARK: -IBActions
    @IBAction func addPostAction() {
        
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
}
