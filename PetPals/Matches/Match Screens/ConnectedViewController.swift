//
//  ConnectedViewController.swift
//  PetPals
//
//  Created by Georgina Garza on 3/19/19.
//  Copyright © 2019 PetPals.inc. All rights reserved.
//

import UIKit
import FirebaseAuth

var thisUser: UserProfile?

// Call database and update list of connected meetups
func getConnected() {
    profile!.getMeetups(withType: .connected, completion: { (meetup) in
        DispatchQueue.main.async {
            if connectedMeetups[meetup.id!] == nil {
                let otherUser: UserProfile!
                if meetup.fromUser.id != profile!.id {
                    otherUser = meetup.fromUser
                } else {
                    otherUser = meetup.toUser
                }
                // Create a blank Match Image
                let matchImage = MatchesImage(frame: CGRect(x: 0, y: 0, width: 55, height: 55))
                // Perform promise to ensure picture gets loaded properly
                matchPicture(url: otherUser.imageURL).done {
                    matchImage.setMatchesImage(image: $0)
                    connectedMeetups[meetup.id!] =  (meetup, matchImage)
                } .catch { _ in
                    print("I resulted in an error")
                }
            }
        }
    })
}


class ConnectedViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    // Connect to tableView
    @IBOutlet weak var tableView: UITableView!
    
    // Label for when no connected meetups
    @IBOutlet weak var noAvailConLabel: UILabel!
    
    // Identifier for tableView
    var connectedTableViewCellIdentifier = "connectedTableViewCellIdentifier"
    
    // This user's ID to know which user the date is with
    var thisUser: UserProfile?
    
    let queue = DispatchQueue(label: "sleepQueue", qos: .userInitiated, attributes: .concurrent)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set delegate & data source for tableView
        tableView.delegate = self
        tableView.dataSource = self
        
        // Get connected meetups
        getConnected()
        
        //reload data
        self.tableView.reloadData()
    }
    
    // All this is doing is waiting to display none
    override func viewWillAppear(_ animated: Bool) {
        // wait for a second, if we don't have potentials show out of cards
        queue.async {
            sleep(1)
            if connectedMeetups.isEmpty {
                DispatchQueue.main.async {
                    self.checkIfNoMeetups()
                }
            }
        }
        tableView.reloadData()
    }
    
    // Required function for tableView; Number of Rows equals number of Connected Users
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        checkIfUpdate()
        return connectedMeetups.count
    }
    
    // Required function for tableView
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // Get this cell
        let cell:ConnectedTableViewCell = tableView.dequeueReusableCell(withIdentifier: connectedTableViewCellIdentifier, for: indexPath as IndexPath) as! ConnectedTableViewCell
        
        // Find the associated meetup
        let meetupID:String = Array(connectedMeetups.keys)[indexPath.row]
        let (meetup, userImage):(Meetup, MatchesImage) = connectedMeetups[meetupID]!
        
        // Update the cell information with this meetup's info
        cell.meetup = meetup
        let otherUser: UserProfile!
        // Determine who the other user is
        if meetup.fromUser.id != profile!.id {
            otherUser = meetup.fromUser
        } else {
            otherUser = meetup.toUser
        }
        cell.userName.text = otherUser.firstName
        cell.userImage.image = userImage.image
        //previous versus not?
        cell.meetupLabel.text = "Meetup on \(meetup.date)"        
        
        return cell as UITableViewCell
    }
    
    // Don't allow users to click on cells
    func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        return nil
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
    
    func checkIfUpdate() {
        if noAvailConLabel.alpha == 1 {
            if connectedMeetups.count > 0 {
                noAvailConLabel.alpha = 0
            }
        }
    }

}
