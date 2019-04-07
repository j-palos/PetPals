//
//  InvitesViewController.swift
//  PetPals
//
//  Created by Georgina Garza on 3/19/19.
//  Copyright © 2019 PetPals.inc. All rights reserved.
//

import UIKit

// Hard coded data for invites users
var invites:[User] = [User(name: "Bailey", picture: "matthew", meetPrior: false, meetup: "MAR 16", meetupTime: "12pm", meetupLoc: "Zilker Park"), User(name: "Ann", picture: "chris", meetPrior: false, meetup: "APR 1", meetupTime: "2pm", meetupLoc: "Zilker Park"), User(name: "Mike", picture: "bastian", meetPrior: false, meetup: "APR 1", meetupTime: "4pm", meetupLoc: "Zilker Park")]

class InvitesViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    // Connect to tableView
    @IBOutlet weak var tableView: UITableView!
    
    // Identifier for tableView
    var invitesTableViewCellIdentifier = "invitesTableViewCellIdentifier"
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Set delegate & data source for tableView
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    // Required function for tableView; Number of Rows equals number of Invites Users
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return invites.count
    }
    
    // Required function for tableView
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // Get this cell
        let cell:InvitesTableViewCell = tableView.dequeueReusableCell(withIdentifier: invitesTableViewCellIdentifier, for: indexPath as IndexPath) as! InvitesTableViewCell
        
        // Find the associated user to this cell
        let user:User = invites[indexPath.row]
        
        // Update the cell information with this user's info
        cell.userName.text = user.userName
        cell.userImage.image = UIImage(named: "\(user.image)")!.scaleToSize(aSize: CGSize(width: 55.0, height: 55.0))
        cell.meetDate.text = "\(user.date) at \(user.time)"
        cell.meetLocation.text = user.location
        
        return cell as UITableViewCell
    }
    
}
