//
//  OverallMatchesViewController.swift
//  PetPals
//
//  Created by Georgina Garza on 3/25/19.
//  Copyright © 2019 PetPals.inc. All rights reserved.
//

import UIKit

class OverallMatchesViewController: UIViewController {
    // Connect all the views
    @IBOutlet weak var matchesView: UIView!
    @IBOutlet weak var calendarView: UIView!
    
    var meetupUser:String = ""
    var meetupImage:String = ""
    
    var startView:String = "Matches"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if startView == "Calendar" {
            switchToCalendarVC()
        }
    }

    // Show the Matches View, hide all other views
    func switchToMatchesVC() {
        UIView.animate(withDuration: 0.5, animations: {
            self.matchesView.alpha = 1
            self.calendarView.alpha = 0
        })
        
        matchesView.isHidden = false
    }
    
    // Show the Calendar View, hide all other views
    func switchToCalendarVC() {
        UIView.animate(withDuration: 0.5, animations: {
            self.calendarView.alpha = 1
            self.matchesView.alpha = 0
        })
        
        calendarView.isHidden = false
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Send this as the parent VC to all children
        if segue.identifier == "calendarEmbedSegue",
            let destination = segue.destination as? CalendarViewController {
            destination.parentVC = self
        } else if segue.identifier == "matchesEmbedSegue",
            let destination = segue.destination as? MatchesViewController {
            destination.parentVC = self
        }
    }
}
