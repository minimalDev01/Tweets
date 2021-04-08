//
//  RegisterViewController.swift
//  Tweets
//
//  Created by Sergio Carralero Nuño on 7/4/21.
//

import UIKit
import NotificationBannerSwift

class RegisterViewController: UIViewController {
    // MARK: - Outlets
    @IBOutlet weak var registerButton: UIButton!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var nameTextField: UITextField!
    
    // MARK: - IBActions
    @IBAction func registerButtonAction() {
        view.endEditing(true)
        performRegister()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
    }

    // MARK: - Private Methods
    private func setupUI() {
        registerButton.layer.cornerRadius = 25
    }
    
    private func performRegister() {
        guard let email = emailTextField.text, !email.isEmpty else {
            NotificationBanner(title: "Error", subtitle: "You must specify a valid email", style: BannerStyle.warning).show()
            return
        }
        
        guard let password = passwordTextField.text, !password.isEmpty else {
            NotificationBanner(title: "Error", subtitle: "You must specify a valid password", style: BannerStyle.warning).show()
            return
        }
        
        guard let name = nameTextField.text, !name.isEmpty else {
            NotificationBanner(title: "Error", subtitle: "You must specify your full name", style: BannerStyle.warning).show()
            return
        }
        
        performSegue(withIdentifier: "showHome", sender: nil)
        
        // Register here
    }
}
