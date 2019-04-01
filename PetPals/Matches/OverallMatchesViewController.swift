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
    @IBOutlet weak var meetupView: UIView!
    
    // Variables to send to meetup view
    var meetupUser:String = ""
    var meetupImage:String = ""
    
    // When this view controller is loaded, initial view
    var startView:String = "Matches"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // If we are loading the Meetup screen, we had to reload view to send data
        if startView == "Meetup" {
            switchToMeetupVC()
        }
    }
    
    // Show the Matches View, hide all other views
    func switchToMatchesVC() {
        UIView.animate(withDuration: 0.5, animations: {
            self.matchesView.alpha = 1
            self.calendarView.alpha = 0
            self.meetupView.alpha = 0
        })
        
        matchesView.isHidden = false
    }
    
    // Show the Calendar View, hide all other views
    func switchToCalendarVC() {
        UIView.animate(withDuration: 0.5, animations: {
            self.calendarView.alpha = 1
            self.matchesView.alpha = 0
            self.meetupView.alpha = 0
        })
        
        calendarView.isHidden = false
    }
    
    // Show the Meetup View, hide all other views
    func switchToMeetupVC() {
        UIView.animate(withDuration: 0.5, animations: {
            self.meetupView.alpha = 1
            self.matchesView.alpha = 0
            self.calendarView.alpha = 0
        })
        
        meetupView.isHidden = false
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Send this as the parent VC to all children
        if segue.identifier == "calendarEmbedSegue",
            let destination = segue.destination as? CalendarViewController {
            destination.parentVC = self
        } else if segue.identifier == "matchesEmbedSegue",
            let destination = segue.destination as? MatchesViewController {
            destination.parentVC = self
        } else if segue.identifier == "meetupEmbedSegue",
            let destination = segue.destination as? MeetupViewController {
            destination.parentVC = self
            if startView == "Meetup" {
                // If we are loading meetup view, send given data
                destination.userName = meetupUser
                destination.userImage = meetupImage
            }
        }
    }
}
