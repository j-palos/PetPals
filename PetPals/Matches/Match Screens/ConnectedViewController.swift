//
//  ConnectedViewController.swift
//  PetPals
//
//  Created by Georgina Garza on 3/19/19.
//  Copyright © 2019 PetPals.inc. All rights reserved.
//

import UIKit
import FirebaseAuth

class ConnectedViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    // Connect to tableView
    @IBOutlet weak var tableView: UITableView!
    
    // Label for when no connected meetups
    @IBOutlet weak var noAvailConLabel: UILabel!
    
    // Identifier for tableView
    var connectedTableViewCellIdentifier = "connectedTableViewCellIdentifier"
    
    // List to contain all connected meetups for this user
    var connectedMeetups = [Meetup]()
    
    // This user's ID to know which user the date is with
    var thisUser: UserProfile?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Set delegate & data source for tableView
        tableView.delegate = self
        tableView.dataSource = self
        
        // Get connected meetups
        getConnected()
    }
    
    // Required function for tableView; Number of Rows equals number of Connected Users
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        checkIfNoMeetups()
        return connectedMeetups.count
    }
    
    // Required function for tableView
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // Get this cell
        let cell:ConnectedTableViewCell = tableView.dequeueReusableCell(withIdentifier: connectedTableViewCellIdentifier, for: indexPath as IndexPath) as! ConnectedTableViewCell
        
        // Find the associated meetup
        let meetup:Meetup = connectedMeetups[indexPath.row]
        
        // Update the cell information with this meetup's info
        cell.meetup = meetup
        let otherUser: UserProfile!
        // Determine who the other user is
        if meetup.fromUser != thisUser {
            otherUser = meetup.fromUser
        } else {
            otherUser = meetup.toUser
        }
        cell.userName.text = otherUser.firstName
        let imageUrl = otherUser.imageURL
        cell.userImage.load(fromURL: imageUrl)
        //previous versus not?
        cell.meetupLabel.text = "Meetup on \(meetup.date)"        
        
        return cell as UITableViewCell
    }
    
    // Don't allow users to click on cells
    func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        return nil
    }
    
    // Call database and update list of connected meetups
    func getConnected() {
        if let id = Auth.auth().currentUser?.uid {
            UserProfile.getProfile(forUserID: id, completion: { (user) in
                self.thisUser = user
                user.getMeetups(withType: .connected, completion: { (meetup) in
                    DispatchQueue.main.async {
                        self.connectedMeetups.append(meetup)
                        print("I found a connected User")
                        self.tableView.reloadData()
                    }
                })
            })
        }
    }
    
    // If there are no meetups, do not show table view but instead label
    // If there are now meetups, show table view and hide label
    func checkIfNoMeetups() {
        if connectedMeetups.count == 0 {
            tableView.alpha = 0
            noAvailConLabel.alpha = 1
        } else {
            tableView.alpha = 1
            noAvailConLabel.alpha = 0
        }
    }

}
