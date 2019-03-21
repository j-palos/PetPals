//
//  RegisterViewController.swift
//  PetPals
//
//  Created by Gerardo Mares on 3/13/19.
//  Copyright © 2019 PetPals.inc. All rights reserved.
//

import UIKit
import Firebase
import GoogleSignIn

class RegisterViewController: UIViewController {
    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var passwordConfirmTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }
    
    @IBAction func signUpAction(_ sender: Any) {
        
        guard let email = emailTextField.text, email.count > 0 else {
            alertError(message: "Email Required")
            return
        }
        guard let password = passwordTextField.text, password.count > 0 else {
            alertError(message: "Password Required")
            return
        }
        guard let confirm = passwordConfirmTextField.text, confirm.count > 0 else {
            alertError(message: "Confirm Password")
            return
        }
        
        guard password == confirm else {
            alertError(message: "Passwords Don't Match")
            return
        }
        
        Auth.auth().createUser(withEmail: email, password: password){ (user, error) in
            if error == nil {
                let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
                let newViewController = storyBoard.instantiateViewController(withIdentifier: mainVCAfterAuthIdentifier)
                self.present(newViewController, animated: true, completion: nil)
            }
            else{
                self.alertError(message: error?.localizedDescription ?? "Error Creating Account")
            }
        }
        
    }
    
    @IBAction func googleSignUp(_ sender: Any) {
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
