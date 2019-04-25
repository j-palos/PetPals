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
        return inviteMeetups.count
    }
    
    // Required function for tableView
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // Get this cell
        let cell:InvitesTableViewCell = tableView.dequeueReusableCell(withIdentifier: invitesTableViewCellIdentifier, for: indexPath as IndexPath) as! InvitesTableViewCell
        
        // Find the associated meetup
        let meetup:Meetup = inviteMeetups[indexPath.row]
        
        // Update the cell information with this meetup's info
        let otherUser = meetup.fromUser
        cell.userName.text = otherUser.firstName
        let imageUrl = otherUser.imageURL
        cell.userImage.load(fromURL: imageUrl)
        cell.meetDate.text = "\(meetup.date) at \(meetup.time)"
        cell.meetLocation.text = meetup.location
        
        return cell as UITableViewCell
    }
    
    // Call database and update list of invite meetups
    func getInvites() {
        if let id = Auth.auth().currentUser?.uid {
            UserProfile.getProfile(forUserID: id, completion: { (user) in
                user.getMeetups(withType: .invites, completion: { (meetup) in
                    DispatchQueue.main.async {
                        self.inviteMeetups.append(meetup)
                        print("I found an invite")
                        self.tableView.reloadData()
                    }
                })
            })
        }
    }
    
}
