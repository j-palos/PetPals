//
//  PendingViewController.swift
//  PetPals
//
//  Created by Georgina Garza on 3/19/19.
//  Copyright © 2019 PetPals.inc. All rights reserved.
//

import UIKit
import FirebaseAuth

class PendingViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    // Connect to tableView
    @IBOutlet weak var tableView: UITableView!
    
    // Label for when there are no pending meetups
    @IBOutlet weak var noAvailPendLabel: UILabel!
    
    // Identifier for tableView
    var pendingTableViewCellIdentifier = "pendingTableViewCellIdentifier"
    
    // List to contain all pending meetups for this user
    var pendingMeetups = [Meetup]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Set delegate & data source for tableView
        tableView.delegate = self
        tableView.dataSource = self
        
        // Get pending meetups
        getPending()
    }
    
    // Required function for tableView; Number of Rows equals number of Pending Users
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        checkIfNoMeetups()
        return pendingMeetups.count
    }
    
    // Required function for tableView
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // Get this cell
        let cell:PendingTableViewCell = tableView.dequeueReusableCell(withIdentifier: pendingTableViewCellIdentifier, for: indexPath as IndexPath) as! PendingTableViewCell
        
        // Find the associated meetup
        let meetup:Meetup = pendingMeetups[indexPath.row]
        
        // Update the cell information with this meetup's info
        cell.meetup = meetup
        let otherUser = meetup.toUser
        cell.userName.text = otherUser.firstName
        let imageUrl = otherUser.imageURL
        cell.userImage.load(fromURL: imageUrl)
        cell.meetDate.text = "\(meetup.date) at \(meetup.time)"
        cell.meetLocation.text = meetup.location
        
        // Let cell know that this is parent table View for reload purposes
        cell.parent = self
        
        return cell as UITableViewCell
    }
    
    // Don't allow users to click on cells
    func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        return nil
    }
    
    // Call database and update list of pending meetups
    func getPending() {
        if let id = Auth.auth().currentUser?.uid {
            UserProfile.getProfile(forUserID: id, completion: { (user) in
                user.getMeetups(withType: .pending, completion: { (meetup) in
                    DispatchQueue.main.async {
                        self.pendingMeetups.append(meetup)
                        self.tableView.reloadData()
                    }
                })
            })
        }
    }
    
    // Reload when a meetup is canceled
    func reloadMeetups(meetupToDelete: Meetup) {
        if let idx = pendingMeetups.firstIndex(where: { $0 === meetupToDelete }) {
            pendingMeetups.remove(at: idx)
        }
        tableView.reloadData()
    }
    
    // If there are no meetups pending, do not show table view but instead label
    // If there are now meetups, show table view and hide label
    func checkIfNoMeetups() {
        if pendingMeetups.count == 0 {
            tableView.alpha = 0
            noAvailPendLabel.alpha = 1
        } else {
            tableView.alpha = 1
            noAvailPendLabel.alpha = 0
        }
    }

}
