//
//  SettingsViewController.swift
//  PetPals
//
//  Created by Gerardo Mares on 4/2/19.
//  Copyright © 2019 PetPals.inc. All rights reserved.
//

import UIKit
import SwiftOverlays
import FirebaseAuth

class SettingsTableViewController: UITableViewController {
    
    // Distance related elements on screen
    @IBOutlet weak var distanceValueLabel: UILabel!
    @IBOutlet weak var distanceSlider: UISlider!
    
    // Switches on this screen
    @IBOutlet weak var discoverableSwitch: UISwitch!
    @IBOutlet weak var newMatchSwitch: UISwitch!
    @IBOutlet weak var meetupSuggestSwitch: UISwitch!
    @IBOutlet weak var meetupAcceptSwitch: UISwitch!
    @IBOutlet weak var meetupRemindSwitch: UISwitch!
    
    // Connect to User Defaults
    let usrDefaults:UserDefaults = UserDefaults.standard
    

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        
        // Update all settings from the User Defaults
        if usrDefaults.object(forKey: "distance") as? Int != nil {
            let distance = UserDefaults.standard.value(forKey: "distance") as! Int
            distanceValueLabel.text = "\(distance)mi."
            distanceSlider.setValue(Float(distance), animated: false)
        }
        
        // Update discoverable switch based on database
            let discoverable = profile?.active
        discoverableSwitch.setOn(discoverable!, animated: false)
        
        
        if usrDefaults.object(forKey: "notifyNewMatch") as? Bool != nil {
            let notifyNewMatch = UserDefaults.standard.value(forKey: "notifyNewMatch") as! Bool
            newMatchSwitch.setOn(notifyNewMatch, animated: false)
        }
        
        if usrDefaults.object(forKey: "meetupSuggest") as? Bool != nil {
            let meetupSuggested = UserDefaults.standard.value(forKey: "meetupSuggest") as! Bool
            meetupSuggestSwitch.setOn(meetupSuggested, animated: false)
        }
        
        if usrDefaults.object(forKey: "meetupAccept") as? Bool != nil {
            let meetupAccept = UserDefaults.standard.value(forKey: "meetupAccept") as! Bool
            meetupAcceptSwitch.setOn(meetupAccept, animated: false)
        }
        
        if usrDefaults.object(forKey: "meetupRemind") as? Bool != nil {
            let meetupRemind = UserDefaults.standard.value(forKey: "meetupRemind") as! Bool
            meetupRemindSwitch.setOn(meetupRemind, animated: false)
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        // Update user defaults when leave screen
        usrDefaults.synchronize()
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // If select a row, automatically deselect it
        tableView.deselectRow(at: indexPath, animated: true)
    }
    // Display error message
    private func alertError(message: String) {
        let alertController = UIAlertController(title: "An Error Occured", message: message, preferredStyle: .alert)
        let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
        
        alertController.addAction(defaultAction)
        self.present(alertController, animated: true, completion: nil)
    }
    
    // Update discoverable depending on value of switch
    @IBAction func discovarableSwitched(_ sender: Any) {
        //save value to the database
        profile?.active = discoverableSwitch.isOn
        profile?.update(completion: { success in
            if !success {
                //error occured
                self.alertError(message: "We were unable to update your active status")
            }
        })
    }
    
    // Update User Default of notification for new match depending on value of switch
    @IBAction func notifyNewMatchSwitch(_ sender: Any) {
        let result = newMatchSwitch.isOn
        usrDefaults.set(result, forKey: "notifyNewMatch")
    }
    
    // Update User Default of notification for a meetup suggestion depending on value of switch
    @IBAction func meetupSuggestSwitched(_ sender: Any) {
        let result = meetupSuggestSwitch.isOn
        usrDefaults.set(result, forKey: "meetupSuggest")
    }
    
    // Update User Default of notificaiton for a meetup acceptance depending on value of switch
    @IBAction func meetupAcceptSwitched(_ sender: Any) {
        let result = meetupAcceptSwitch.isOn
        usrDefaults.set(result, forKey: "meetupAccept")
    }
    
    // Update User Default of notification for a meetup reminder depending on value of switch
    @IBAction func meetupRemindSwitched(_ sender: Any) {
        let result = meetupRemindSwitch.isOn
        usrDefaults.set(result, forKey: "meetupRemind")
    }
    
    // If the distance slider updates, update label at same time
    @IBAction func distanceSliderUpdate(_ sender: Any) {
        if distanceSlider.value < 1{
            distanceSlider.setValue(1, animated: false)
        }

        let newDistance = Int(distanceSlider.value)
        distanceValueLabel.text = "\(newDistance)mi."
        usrDefaults.set(newDistance, forKey: "distance")
    }
    
    // Logout user
    @IBAction func logoutButtonPressed(_ sender: Any) {
        let alertController = UIAlertController(title: "Sign out",
                                                message: "Are you sure that you want to sign out?",
                                                preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        let okAction = UIAlertAction(title: "OK", style: .destructive, handler: { (action: UIAlertAction) in
            UserProfile.logOutUser(completion: { (error) in
                if error != nil {
                    let alertController = UIAlertController(title: "Error", message: "Logout Failed", preferredStyle: .alert)
                    let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
                    
                    alertController.addAction(defaultAction)
                    self.present(alertController, animated: true, completion: nil)
                }
            })
        })
        //present alert to continue with delete
        alertController.addAction(cancelAction)
        alertController.addAction(okAction)
        self.present(alertController, animated: true, completion: nil)
    }
    
    // Delete this user's account
    @IBAction func deleteAccountButtonPressed(_ sender: Any) {
        let alertController = UIAlertController(title: "Delete Account",
                                                message: "Are you sure you want to continue? Your account will be deleted and you won't be able to access it.",
                                                preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        let okAction = UIAlertAction(title: "OK", style: .destructive, handler: { (action: UIAlertAction) in
            profile?.deleteAccount(completion: { (error: Error?) in
                if error == nil {
                    let storyBoard: UIStoryboard = UIStoryboard(name: "Initial", bundle: nil)
                    let appdelegate = UIApplication.shared.delegate as! AppDelegate
                    appdelegate.window!.rootViewController = storyBoard.instantiateInitialViewController()
                    
                } else {
                    //Error occurred deleting, possibly due to being signed in too long must reauthenticate
                    //prompt whether to continue
                    let alertController = UIAlertController(title: "Authentication Required",
                                                            message: "If you want to continue you need to login again...",
                                                            preferredStyle: .alert)
                    let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
                    let okAction = UIAlertAction(title: "OK", style: .default, handler: { (action: UIAlertAction) in
                        //user said to continue so log them out and send them to login view on success
                        UserProfile.logOutUser(completion: { (error: NSError?) in
                            if error == nil {
                                profile = nil
                                let storyBoard: UIStoryboard = UIStoryboard(name: "Initial", bundle: nil)
                                let appdelegate = UIApplication.shared.delegate as! AppDelegate
                                appdelegate.window!.rootViewController = storyBoard.instantiateInitialViewController()
                            }
                        })
                    })
                    //present alert to reauthenticate
                    alertController.addAction(cancelAction)
                    alertController.addAction(okAction)
                    self.present(alertController, animated: true, completion: nil)
                }
            })
        })
        //present alert to continue with delete
        alertController.addAction(cancelAction)
        alertController.addAction(okAction)
        self.present(alertController, animated: true, completion: nil)
        
    }

}
