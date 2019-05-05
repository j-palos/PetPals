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
    
    // Label to show when no upcoming dates
    @IBOutlet weak var noDatesLabel: UILabel!
    
    // List to contain all connected meetups for this user
    var connectedMeetups = [Meetup]()
    
    // This user's ID to know which user the date is with
    var thisUser: UserProfile?
    
    let queue = DispatchQueue(label: "sleepQueue", qos: .userInitiated, attributes: .concurrent)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.tableFooterView = UIView()
        
        getMeetups()
    }
    
    // All this is doing is waiting to display none
    override func viewWillAppear(_ animated: Bool) {
        // wait for a second, if we don't have potentials show out of cards
        queue.async {
            sleep(1)
            if self.connectedMeetups.isEmpty {
                DispatchQueue.main.async {
                    self.checkIfNoMeetups()
                }
            }
        }
    }

    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        checkIfUpdate()
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
    
    // If there are no upcoming meetups, do not show table view but instead label
    // If there are now meetups, show table view and hide label
    func checkIfNoMeetups() {
        if connectedMeetups.count == 0 {
            noDatesLabel.alpha = 1
        } else {
            noDatesLabel.alpha = 0
        }
    }
    
    func checkIfUpdate() {
        if noDatesLabel.alpha == 1 {
            if connectedMeetups.count > 0 {
                noDatesLabel.alpha = 0
            }
        }
    }

}
