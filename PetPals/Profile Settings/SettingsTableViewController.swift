//
//  SettingsViewController.swift
//  PetPals
//
//  Created by Gerardo Mares on 4/2/19.
//  Copyright © 2019 PetPals.inc. All rights reserved.
//

import UIKit
import SwiftOverlays

class SettingsTableViewController: UITableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    @IBAction func logoutButtonPressed(_ sender: Any) {
        UserProfile.logOutUser(completion: { (error) in
            if error != nil {
                let alertController = UIAlertController(title: "Error", message: "Logout Failed", preferredStyle: .alert)
                let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
                
                alertController.addAction(defaultAction)
                self.present(alertController, animated: true, completion: nil)
            }
        })
    }
    
    @IBAction func deleteAccountButtonPressed(_ sender: Any) {
        UserProfile.logOutUser(completion: { (error) in
            if error != nil {
                let alertController = UIAlertController(title: "Error", message: "Logout Failed", preferredStyle: .alert)
                let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
                
                alertController.addAction(defaultAction)
                self.present(alertController, animated: true, completion: nil)
            }
        })
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
