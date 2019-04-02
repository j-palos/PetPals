//
//  LoginViewController.swift
//  PetPals
//
//  Created by Gerardo Mares on 3/13/19.
//  Copyright © 2019 PetPals.inc. All rights reserved.
//

import UIKit
import Firebase
import GoogleSignIn

class LoginViewController: UIViewController, GIDSignInUIDelegate {
        
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var signInButton: GIDSignInButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        GIDSignIn.sharedInstance().uiDelegate = self
        
    }
    
    @IBAction func loginAction(_ sender: Any) {
        
        guard let email = emailTextField.text, email.count > 0 else {
            alertError(message: "Email Required")
            return
        }
        guard let password = passwordTextField.text, password.count > 0 else {
            alertError(message: "Password Required")
            return
        }
        
        UserProfile.loginUser(withEmail: email, password: password) { (error, nextVC) in
            
            if error == nil {
                self.present(nextVC!, animated: true, completion: nil)
            }
            else {
                self.alertError(message: "Failed to login...")
            }
        }
        
    }
    
    @IBAction func googleLogin(_ sender: Any) {
        GIDSignIn.sharedInstance().signIn()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    private func alertError(message: String) {
        let alertController = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
        
        alertController.addAction(defaultAction)
        self.present(alertController, animated: true, completion: nil)
    }
}
