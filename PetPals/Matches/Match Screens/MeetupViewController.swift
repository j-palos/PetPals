//
//  MeetupViewController.swift
//  PetPals
//
//  Created by Georgina Garza on 3/25/19.
//  Copyright © 2019 PetPals.inc. All rights reserved.
//

import UIKit

class MeetupViewController: UIViewController {
    // Connect necessary fields
    @IBOutlet weak var chosenUserImage: UIImageView!
    @IBOutlet weak var chosenUserName: UILabel!
    
    // Variables so this information can be passed in
    var userName = String()
    var userImage = String()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set label and image to variables passed over from MatchesVC
        chosenUserName.text = userName
        chosenUserImage.image = UIImage(named: userImage)
    }
    
    // If the switch is clicked, use the Overall Matches Screen to switch views
    @IBAction func switchClicked(_ sender: Any) {
        // Destination will be Meetup Screen
        let destination = self.storyboard!.instantiateViewController(withIdentifier: "OverallMatchesViewController") as! OverallMatchesViewController
        
        // Send over information about the user selected
        destination.startView = "Calendar"
        
        // Present the screen
        self.present(destination, animated: false)
    }
    
    // When the submit button is clicked, use the Overall Matches Screen to switch views
    @IBAction func sendClicked(_ sender: Any) {
        // Destination will be Meetup Screen
        let destination = self.storyboard!.instantiateViewController(withIdentifier: "OverallMatchesViewController") as! OverallMatchesViewController
        
        // Send over information about the user selected
        destination.startView = "Matches"
        
        // Present the screen
        self.present(destination, animated: false)
    }
    
    
}
