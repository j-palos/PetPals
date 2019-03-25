//
//  SpecificUpcomingDateViewController.swift
//  PetPals
//
//  Created by Georgina Garza on 3/24/19.
//  Copyright © 2019 PetPals.inc. All rights reserved.
//

import UIKit

class SpecificUpcomingDateViewController: UIViewController {
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!

    var name:String = ""
    var date:String = ""
    var time:String = ""

    override func viewDidLoad() {
        super.viewDidLoad()

        nameLabel.text = name
        dateLabel.text = date
        timeLabel.text = time
    }

}
