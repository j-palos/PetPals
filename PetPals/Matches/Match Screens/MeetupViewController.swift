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
    @IBOutlet weak var chosenUserImage: MatchesImage!
    @IBOutlet weak var chosenUserName: UILabel!
    
    // Variables so this information can be passed in
    var userName = String()
    var userImage = NSURL(fileURLWithPath: "")
    
    // Variable to connect to Overall Matches VC
    var parentVC: OverallMatchesViewController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set label and image to variables passed over from MatchesVC
        chosenUserName.text = userName
        chosenUserImage.load(fromURL: userImage as URL)
    }
    
    // code to dismiss keyboard when user clicks on background
    
    func textFieldShouldReturn(textField:UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
}
