//
//  ConnectedViewController.swift
//  PetPals
//
//  Created by Georgina Garza on 3/19/19.
//  Copyright © 2019 PetPals.inc. All rights reserved.
//

import UIKit

var connected:[User] = [User(name: "Matthew", picture: "matthew", meetPrior: false, meetup: "MAR 12", meetupTime: "", meetupLoc: ""), User(name: "Chris", picture: "chris", meetPrior: true, meetup: "JAN 25", meetupTime: "", meetupLoc: ""), User(name: "Bastian", picture: "bastian", meetPrior: true, meetup: "DEC 13", meetupTime: "", meetupLoc: "")]

class ConnectedViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!
    
    var connectedTableViewCellIdentifier = "connectedTableViewCellIdentifier"
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return connected.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell:ConnectedTableViewCell = tableView.dequeueReusableCell(withIdentifier: connectedTableViewCellIdentifier, for: indexPath as IndexPath) as! ConnectedTableViewCell
        let user:User = connected[indexPath.row]
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
