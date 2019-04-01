//
//  SpecificUpcomingDateViewController.swift
//  PetPals
//
//  Created by Georgina Garza on 3/24/19.
//  Copyright © 2019 PetPals.inc. All rights reserved.
//

import UIKit

class SpecificUpcomingDateViewController: UIViewController {
    // Connect Necessary Fields
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!

    // Variables to be sent in
    var name:String = ""
    var date:String = ""
    var time:String = ""

    override func viewDidLoad() {
        super.viewDidLoad()

        // Update view with variables that were sent in
        nameLabel.text = name
        dateLabel.text = date
        timeLabel.text = time
    }

}
