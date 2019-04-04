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
    
    // Variable to connect to Overall Matches VC
    var parentVC: OverallMatchesViewController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set label and image to variables passed over from MatchesVC
        chosenUserName.text = userName
        chosenUserImage.image = UIImage(named: userImage)
        
        // Make the profile pictures circles
        chosenUserImage.layer.cornerRadius = chosenUserImage.frame.size.width / 2
        chosenUserImage.clipsToBounds = true
    }
}
