//
//  InvitesViewController.swift
//  PetPals
//
//  Created by Georgina Garza on 3/19/19.
//  Copyright © 2019 PetPals.inc. All rights reserved.
//

import UIKit
import FirebaseAuth

class InvitesViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    // Connect to tableView
    @IBOutlet weak var tableView: UITableView!
    
    // Label for when no invite meetups
    @IBOutlet weak var noAvailInvLabel: UILabel!
    
    // Identifier for tableView
    var invitesTableViewCellIdentifier = "invitesTableViewCellIdentifier"
    
    // List to contain all invite meetups for this user
    var inviteMeetups = [Meetup]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Set delegate & data source for tableView
        tableView.delegate = self
        tableView.dataSource = self
        
        // Get pending meetups
        getInvites()
    }
    
    // Required function for tableView; Number of Rows equals number of Invites Users
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        checkIfNoMeetups()
        return inviteMeetups.count
    }
    
    // Required function for tableView
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // Get this cell
        let cell:InvitesTableViewCell = tableView.dequeueReusableCell(withIdentifier: invitesTableViewCellIdentifier, for: indexPath as IndexPath) as! InvitesTableViewCell
        
        // Find the associated meetup
        let meetup:Meetup = inviteMeetups[indexPath.row]
        
        // Update the cell information with this meetup's info
        cell.meetup = meetup
        let otherUser = meetup.fromUser
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
    
    // Call database and update list of invite meetups
    func getInvites() {
        if let id = Auth.auth().currentUser?.uid {
            UserProfile.getProfile(forUserID: id, completion: { (user) in
                user.getMeetups(withType: .invites, completion: { (meetup) in
                    DispatchQueue.main.async {
                        self.inviteMeetups.append(meetup)
                        self.tableView.reloadData()
                    }
                })
            })
        }
    }
    
    // Reload when a meetup is declined or accepted
    func reloadMeetups(meetupToDelete: Meetup) {
        if let idx = inviteMeetups.firstIndex(where: { $0 === meetupToDelete }) {
            inviteMeetups.remove(at: idx)
        }
        tableView.reloadData()
    }
    
    // If there are no meetups pending, do not show table view but instead label
    // If there are now meetups, show table view and hide label
    func checkIfNoMeetups() {
        if inviteMeetups.count == 0 {
            tableView.alpha = 0
            noAvailInvLabel.alpha = 1
        } else {
            tableView.alpha = 1
            noAvailInvLabel.alpha = 0
        }
    }
    
}
