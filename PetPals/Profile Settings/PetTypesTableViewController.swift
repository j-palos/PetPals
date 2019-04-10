//
//  PetTypesTableViewController.swift
//  PetPals
//
//  Created by Georgina Garza on 4/9/19.
//  Copyright © 2019 PetPals.inc. All rights reserved.
//

import UIKit

class PetTypesTableViewController: UITableViewController {
    
    @IBOutlet weak var catSwitch: UISwitch!
    @IBOutlet weak var dogSwitch: UISwitch!
    @IBOutlet weak var reptileSwitch: UISwitch!
    @IBOutlet weak var birdSwitch: UISwitch!
    @IBOutlet weak var fishSwitch: UISwitch!
    @IBOutlet weak var rodentSwitch: UISwitch!
    @IBOutlet weak var otherSwitch: UISwitch!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //update all switches based on userdefaults
    }
    
    @IBAction func catSwitched(_ sender: Any) {
        //Update database
    }
    
    @IBAction func dogSwitched(_ sender: Any) {
        //Update database
    }
    
    @IBAction func reptileSwitched(_ sender: Any) {
        //Update database
    }
    
    @IBAction func birdSwitched(_ sender: Any) {
        //Update database
    }
    
    @IBAction func fishSwitched(_ sender: Any) {
        //Update database
    }
    
    @IBAction func rodentSwitched(_ sender: Any) {
        //Update database
    }
    
    @IBAction func otherSwitched(_ sender: Any) {
        //Update database
    }
}
