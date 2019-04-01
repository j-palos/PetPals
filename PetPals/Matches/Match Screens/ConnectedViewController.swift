//
//  ConnectedViewController.swift
//  PetPals
//
//  Created by Georgina Garza on 3/19/19.
//  Copyright © 2019 PetPals.inc. All rights reserved.
//

import UIKit

// Hard coded data for connected users
var connected:[User] = [User(name: "Matthew", picture: "matthew", meetPrior: false, meetup: "MAR 12", meetupTime: "", meetupLoc: ""), User(name: "Chris", picture: "chris", meetPrior: true, meetup: "JAN 25", meetupTime: "", meetupLoc: ""), User(name: "Bastian", picture: "bastian", meetPrior: true, meetup: "DEC 13", meetupTime: "", meetupLoc: "")]

class ConnectedViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    // Connect to tableView
    @IBOutlet weak var tableView: UITableView!
    
    // Identifier for tableView
    var connectedTableViewCellIdentifier = "connectedTableViewCellIdentifier"
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Set delegate & data source for tableView
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    // Required function for tableView; Number of Rows equals number of Connected Users
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return connected.count
    }
    
    // Required function for tableView
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // Get this cell
        let cell:ConnectedTableViewCell = tableView.dequeueReusableCell(withIdentifier: connectedTableViewCellIdentifier, for: indexPath as IndexPath) as! ConnectedTableViewCell
        
        // Find the associated user based on index
        let user:User = connected[indexPath.row]
        
        // Update the cell information with this user's info
        cell.userName.text = user.userName
        cell.userImage.image = UIImage(named: "\(user.image)")
        var meetup = ""
        if user.prevMeet {
            meetup = "Previous "
        }
        cell.meetupLabel.text = meetup + "Meetup on " + user.date
        
        return cell as UITableViewCell
    }

}
