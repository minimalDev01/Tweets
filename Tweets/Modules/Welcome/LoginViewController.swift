//
//  LoginViewController.swift
//  Tweets
//
//  Created by Sergio Carralero Nuño on 7/4/21.
//

import UIKit
import NotificationBannerSwift
import Simple_Networking
import SVProgressHUD

// Create our own color to work with dark mode
extension UIColor {
    static let customGreen: UIColor = {
        if #available(iOS 13.0, *) {
            return UIColor { (trait: UITraitCollection) -> UIColor in
                if trait.userInterfaceStyle == .dark {
                    // Dark mode
                    return .white
                } else {
                    // Light mode
                    return .green
                }
            }
        } else {
            // Less than iOS 13
            return .green
        }
    }()
}

class LoginViewController: UIViewController {
    // MARK: - Outlets
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    // MARK: - IBActions
    @IBAction func loginButtonAction() {
        view.endEditing(true)
        performLogin()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
    }
    
    // MARK: - Private Methods
    private func setupUI() {
        loginButton.layer.cornerRadius = 25
        loginButton.backgroundColor = UIColor.customGreen
        
        // Force light mode in app, not recommendable to do
        if #available(iOS 13.0, *) {
            //overrideUserInterfaceStyle = .light
        }
    }
    
    private func performLogin() {
        guard let email = emailTextField.text, !email.isEmpty else {
            NotificationBanner(title: "Error", subtitle: "You must specify a valid email", style: BannerStyle.warning).show()
            return
        }
        
        guard let password = passwordTextField.text, !password.isEmpty else {
            NotificationBanner(title: "Error", subtitle: "You must specify a valid password", style: BannerStyle.warning).show()
            return
        }
        
        // Create request
        let request = LoginRequest(email: email, password: password)
        
        // Initializating loader
        SVProgressHUD.show()
        
        // Call net library to get the response. SNResultWithEntity return first the response (LoginResponse), and second the possible error (ErrorResponse)
        SN.post(endpoint: Endpoints.login, model: request) { (response: SNResultWithEntity<LoginResponse, ErrorResponse>) in
            // Dismissing loader
            SVProgressHUD.dismiss()
            
            switch response {
            case .success(let user):
                self.performSegue(withIdentifier: "showHome", sender: nil)
                
                // Saving email into UserDefaults in order to use it when trying to delete our own posts
                UserDefaults.standard.set(user.user.email, forKey: "email-saved")
                
                // Saving credentials
                SimpleNetworking.setAuthenticationHeader(prefix: "", token: user.token)
            case .error(let error):
                NotificationBanner(title: "Error", subtitle: error.localizedDescription, style: .danger).show()
            case .errorResult(let entity):
                NotificationBanner(title: "Error", subtitle: entity.error, style: .warning).show()
            }
        }
    }
}
