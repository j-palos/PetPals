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
    
    @IBOutlet weak var distanceValueLabel: UILabel!
    @IBOutlet weak var distanceSlider: UISlider!
    @IBOutlet weak var discoverableSwitch: UISwitch!
    @IBOutlet weak var newMatchSwitch: UISwitch!
    @IBOutlet weak var meetupSuggestSwitch: UISwitch!
    @IBOutlet weak var meetupAcceptSwitch: UISwitch!
    @IBOutlet weak var meetupRemindSwitch: UISwitch!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Update all switches based on userDefaults
    }
    
    @IBAction func discovarableSwitched(_ sender: Any) {
        //Update database
    }
    
    @IBAction func notifyNewMatchSwitch(_ sender: Any) {
        //Update database
    }
    
    @IBAction func meetupSuggestSwitch(_ sender: Any) {
        //Update database
    }
    
    @IBAction func meetupAcceptSwitch(_ sender: Any) {
        //Update database
    }
    
    @IBAction func meetupRemindSwitch(_ sender: Any) {
        //Update database
    }
    
    @IBAction func distanceSliderUpdate(_ sender: Any) {
        let newDistance = Int(distanceSlider.value)
        distanceValueLabel.text = "\(newDistance)mi."
        //update in database
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

}
