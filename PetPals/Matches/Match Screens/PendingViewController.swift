//
//  PendingViewController.swift
//  PetPals
//
//  Created by Georgina Garza on 3/19/19.
//  Copyright © 2019 PetPals.inc. All rights reserved.
//

import UIKit
import FirebaseAuth

// Call database and update list of pending meetups
func getPending() {
    profile!.getMeetups(withType: .pending, completion: { (meetup) in
        DispatchQueue.main.async {
            if pendingMeetups[meetup.id!] == nil {
                let otherUser = meetup.toUser
                // Create a blank Match Image
                let matchImage = MatchesImage(frame: CGRect(x: 0, y: 0, width: 55, height: 55))
                // Perform promise to ensure picture gets loaded properly
                matchPicture(url: otherUser.imageURL).done {
                    matchImage.setMatchesImage(image: $0)
                    pendingMeetups[meetup.id!] =  (meetup, matchImage)
                } .catch { _ in
                    print("I resulted in an error")
                }
            }
        }
    })
}

class PendingViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    // Connect to tableView
    @IBOutlet weak var tableView: UITableView!
    
    // Label for when there are no pending meetups
    @IBOutlet weak var noAvailPendLabel: UILabel!
    
    // Identifier for tableView
    var pendingTableViewCellIdentifier = "pendingTableViewCellIdentifier"
    
    let queue = DispatchQueue(label: "sleepQueue", qos: .userInitiated, attributes: .concurrent)
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Set delegate & data source for tableView
        tableView.delegate = self
        tableView.dataSource = self
        
        // Get pending meetups
        getPending()
        
        //reload data
        self.tableView.reloadData()
    }
    
    // All this is doing is waiting to display none
    override func viewWillAppear(_ animated: Bool) {
        // wait for a second, if we don't have potentials show out of cards
        queue.async {
            sleep(1)
            if pendingMeetups.isEmpty {
                DispatchQueue.main.async {
                    self.checkIfNoMeetups()
                }
            }
        }
        tableView.reloadData()
    }
    
    // Required function for tableView; Number of Rows equals number of Pending Users
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        checkIfUpdate()
        return pendingMeetups.count
    }
    
    // Required function for tableView
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // Get this cell
        let cell:PendingTableViewCell = tableView.dequeueReusableCell(withIdentifier: pendingTableViewCellIdentifier, for: indexPath as IndexPath) as! PendingTableViewCell
        
        // Find the associated meetup
        // Find the associated meetup
        let meetupID:String = Array(pendingMeetups.keys)[indexPath.row]
        let (meetup, userImage):(Meetup, MatchesImage) = pendingMeetups[meetupID]!
        
        // Update the cell information with this meetup's info
        cell.meetup = meetup
        let otherUser = meetup.toUser
        cell.userName.text = otherUser.firstName
        cell.userImage.image = userImage.image
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
    
    // Reload when a meetup is canceled
    func reloadMeetups(meetupToDelete: Meetup) {
        pendingMeetups.removeValue(forKey: meetupToDelete.id!)
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
    
    func checkIfUpdate() {
        if noAvailPendLabel.alpha == 1 {
            if pendingMeetups.count > 0 {
                noAvailPendLabel.alpha = 0
            }
        }
    }

}
