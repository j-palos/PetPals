//
//  PetTypesTableViewController.swift
//  PetPals
//
//  Created by Georgina Garza on 4/9/19.
//  Copyright © 2019 PetPals.inc. All rights reserved.
//

import UIKit

class PetTypesTableViewController: UITableViewController {
    
    // All switches for pet types
    @IBOutlet weak var catSwitch: UISwitch!
    @IBOutlet weak var dogSwitch: UISwitch!
    @IBOutlet weak var reptileSwitch: UISwitch!
    @IBOutlet weak var birdSwitch: UISwitch!
    @IBOutlet weak var fishSwitch: UISwitch!
    @IBOutlet weak var rodentSwitch: UISwitch!
    @IBOutlet weak var otherSwitch: UISwitch!
    
    // Connect to User Defaults
    let usrDefaults:UserDefaults = UserDefaults.standard
    
    // Pet Types this user wants
    var results = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set original values of switches based on user information
        let chosenPetTypes = UserDefaults.standard.value(forKey: "petTypes") as! [String]
        print("PET TYPES:",chosenPetTypes)
        if chosenPetTypes.contains("Cat") {
            results.append("Cat")
            catSwitch.setOn(true, animated: false)
        }
        if chosenPetTypes.contains("Dog") {
            results.append("Dog")
            dogSwitch.setOn(true, animated: false)
        }
        if chosenPetTypes.contains("Reptile") {
            results.append("Reptile")
            reptileSwitch.setOn(true, animated: false)
        }
        if chosenPetTypes.contains("Bird") {
            results.append("Bird")
            birdSwitch.setOn(true, animated: false)
        }
        if chosenPetTypes.contains("Fish") {
            results.append("Fish")
            fishSwitch.setOn(true, animated: false)
        }
        if chosenPetTypes.contains("Rodent") {
            results.append("Rodent")
            rodentSwitch.setOn(true, animated: false)
        }
        if chosenPetTypes.contains("Other") {
            results.append("Other")
            otherSwitch.setOn(true, animated: false)
        }
    }
    
    // When user leaves the screen, update the pet types they have chosen
    override func viewDidDisappear(_ animated: Bool) {
        usrDefaults.set(results, forKey: "petTypes")
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // If select a row, automatically deselect it
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    
    // If cat chosen, add to result list
    @IBAction func catSwitched(_ sender: Any) {
        if catSwitch.isOn {
            results.append("Cat")
        } else if results.contains("Cat") {
            // previously on, but now turned off
            results.removeAll { $0 == "Cat" }
        }
    }
    
    // If dog chosen, add to result list
    @IBAction func dogSwitched(_ sender: Any) {
        if dogSwitch.isOn {
            results.append("Dog")
        } else if results.contains("Dog") {
            // previously on, but now turned off
            results.removeAll { $0 == "Dog" }
        }
    }
    
    // If reptile chosen, add to result list
    @IBAction func reptileSwitched(_ sender: Any) {
        if reptileSwitch.isOn {
            results.append("Reptile")
        } else if results.contains("Reptile") {
            // previously on, but now turned off
            results.removeAll { $0 == "Reptile" }
        }
    }
    
    // If bird chosen, add to result list
    @IBAction func birdSwitched(_ sender: Any) {
        if birdSwitch.isOn {
            results.append("Bird")
        } else if results.contains("Bird") {
            // previously on, but now turned off
            results.removeAll { $0 == "Bird" }
        }
    }
    
    // If fish chosen, add to result list
    @IBAction func fishSwitched(_ sender: Any) {
        if fishSwitch.isOn {
            results.append("Fish")
        } else if results.contains("Fish") {
            // previously on, but now turned off
            results.removeAll { $0 == "Fish" }
        }
    }
    
    // If rodent chosen, add to result list
    @IBAction func rodentSwitched(_ sender: Any) {
        if rodentSwitch.isOn {
            results.append("Rodent")
        } else if results.contains("Rodent") {
            // previously on, but now turned off
            results.removeAll { $0 == "Rodent" }
        }
    }
    
    // If other chosen, add to result list
    @IBAction func otherSwitched(_ sender: Any) {
        if otherSwitch.isOn {
            results.append("Other")
        } else if results.contains("Other") {
            // previously on, but now turned off
            results.removeAll { $0 == "Other" }
        }
    }
}
