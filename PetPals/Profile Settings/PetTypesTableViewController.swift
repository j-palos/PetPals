//
//  PetTypesTableViewController.swift
//  PetPals
//
//  Created by Georgina Garza on 4/9/19.
//  Copyright © 2019 PetPals.inc. All rights reserved.
//

import UIKit

class PetTypesTableViewController: UITableViewController {
    
    // List of switches
    @IBOutlet var switches: [UISwitch]!
    
    // Connect to User Defaults
    let usrDefaults:UserDefaults = UserDefaults.standard
    
    // Order of switches in list
    let switchOrder = ["Cat", "Dog", "Reptile", "Bird", "Fish", "Rodent", "Other"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set original values of switches based on user information
        if usrDefaults.object(forKey: "petTypes") as? [String] != nil {
            let chosenPetTypes = UserDefaults.standard.value(forKey: "petTypes") as! [String]
            
            // Loop through switches
            // If user has it as pet type, turn on
            for i in 0...(switches.count-1) {
                let currSwitch = switches[i]
                if chosenPetTypes.contains(switchOrder[i]) {
                    currSwitch.setOn(true, animated: false)
                }
            }
        }
    }
    
    // When user leaves the screen, update the pet types they have chosen
    override func viewDidDisappear(_ animated: Bool) {
        var results = [String]()
        
        // Loop through switches
        // If user has it as pet type, add it to results
        for i in 0...(switches.count-1){
            let currSwtich = switches[i]
            if currSwtich.isOn {
                results.append(switchOrder[i])
            }
        }
        
        // Update User Defaults
        usrDefaults.set(results, forKey: "petTypes")
        usrDefaults.synchronize()
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // If select a row, automatically deselect it
        tableView.deselectRow(at: indexPath, animated: true)
    }
}
