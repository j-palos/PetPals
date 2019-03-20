//
//  MatchesViewController.swift
//  PetPals
//
//  Created by Georgina Garza on 3/19/19.
//  Copyright © 2019 PetPals.inc. All rights reserved.
//

import UIKit

class MatchesViewController: UIViewController {

    @IBOutlet weak var connectedContainerView: UIView!
    @IBOutlet weak var invitesContainerView: UIView!
    @IBOutlet weak var pendingContainerView: UIView!
    
    @IBOutlet weak var connectedButton: UIButton!
    @IBOutlet weak var invitesButton: UIButton!
    @IBOutlet weak var pendingButton: UIButton!
    
    let blueColor:UIColor = UIColor(red: 0.44, green:0.78, blue:0.78, alpha: 1)
    let grayColor:UIColor = UIColor(red: 0.78, green: 0.78, blue: 0.8, alpha: 1)
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    @IBAction func connectedButtonPressed(_ sender: Any) {
        UIView.animate(withDuration: 0.5, animations: {
            self.connectedContainerView.alpha = 1
            self.invitesContainerView.alpha = 0
            self.pendingContainerView.alpha = 0
        })
        
        connectedButton.setTitleColor(blueColor, for: .normal)
        invitesButton.setTitleColor(grayColor, for: .normal)
        pendingButton.setTitleColor(grayColor, for: .normal)
    }
    
    @IBAction func invitesButtonPressed(_ sender: Any) {
        UIView.animate(withDuration: 0.5, animations: {
            self.connectedContainerView.alpha = 0
            self.invitesContainerView.alpha = 1
            self.pendingContainerView.alpha = 0
        })
        
        invitesButton.setTitleColor(blueColor, for: .normal)
        connectedButton.setTitleColor(grayColor, for: .normal)
        pendingButton.setTitleColor(grayColor, for: .normal)
    }
    
    @IBAction func pendingButtonPressed(_ sender: Any) {
        UIView.animate(withDuration: 0.5, animations: {
            self.connectedContainerView.alpha = 0
            self.invitesContainerView.alpha = 0
            self.pendingContainerView.alpha = 1
        })
        
        pendingButton.setTitleColor(blueColor, for: .normal)
        connectedButton.setTitleColor(grayColor, for: .normal)
        invitesButton.setTitleColor(grayColor, for: .normal)
    }
    
}
