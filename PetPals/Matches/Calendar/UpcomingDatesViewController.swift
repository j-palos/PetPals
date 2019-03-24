//
//  UpcomingDatesViewController.swift
//  PetPals
//
//  Created by Georgina Garza on 3/24/19.
//  Copyright © 2019 PetPals.inc. All rights reserved.
//

import UIKit

class UpcomingDatesViewController: UIViewController {
    
    @IBOutlet weak var firstUpcoming: UIView!
    @IBOutlet weak var secondUpcoming: UIView!
    @IBOutlet weak var thirdUpcoming: UIView!

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
         if segue.identifier == "firstUpcomingIdentifier" {
            if let firstVC = segue.destination as? SpecificUpcomingDateViewController{
                firstVC.name = "Emily"
                firstVC.date = "March 02"
                firstVC.time = "12 pm"
            }
        
        } else if segue.identifier == "secondUpcomingIdentifier" {
            if let secondVC = segue.destination as? SpecificUpcomingDateViewController {
                secondVC.name = "Jeffery"
                secondVC.date = "March 11"
                secondVC.time = "12 pm"
            }
         } else if segue.identifier == "thirdUpcomingIdentifier" {
            if let thirdVC = segue.destination as? SpecificUpcomingDateViewController {
                thirdVC.name = "Leo"
                thirdVC.date = "March 20"
                thirdVC.time = "12 pm"
            }
        }
    }

}
