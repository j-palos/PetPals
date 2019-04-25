//
//  UpcomingDatesViewController.swift
//  PetPals
//
//  Created by Georgina Garza on 3/24/19.
//  Copyright © 2019 PetPals.inc. All rights reserved.
//

import UIKit
import FirebaseAuth

class UpcomingDatesViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    // Connect necessary fields
    @IBOutlet weak var tableView: UITableView!
    
    // List to contain all connected meetups for this user
    var connectedMeetups = [Meetup]()
    
    // This user's ID to know which user the date is with
    var thisUser: UserProfile?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.tableFooterView = UIView()
        
        getMeetups()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return connectedMeetups.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell:UpcomingDateTableViewCell = tableView.dequeueReusableCell(withIdentifier: "upcomingDateTableViewCellIdentifier", for: indexPath as IndexPath) as! UpcomingDateTableViewCell
        let currDate = connectedMeetups[indexPath.row]
        
        let otherUser: UserProfile!
        if currDate.fromUser != thisUser {
            otherUser = currDate.fromUser
        } else {
            otherUser = currDate.toUser
        }
        
        cell.nameLabel.text = otherUser.firstName
        cell.dateLabel.text = currDate.date
        cell.timeLabel.text = currDate.time
        
        return cell
    }
    
    // Call database and update list of connected meetups
    func getMeetups() {
        if let id = Auth.auth().currentUser?.uid {
            UserProfile.getProfile(forUserID: id, completion: { (user) in
                self.thisUser = user
                user.getMeetups(withType: .connected, completion: { (meetup) in
                    DispatchQueue.main.async {
                        self.connectedMeetups.append(meetup)
                        self.tableView.reloadData()
                    }
                })
            })
        }
    }

}
