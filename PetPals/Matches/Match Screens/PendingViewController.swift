//
//  PendingViewController.swift
//  PetPals
//
//  Created by Georgina Garza on 3/19/19.
//  Copyright © 2019 PetPals.inc. All rights reserved.
//

import UIKit

var pending:[User] = [User(name: "Bailey", picture: "matthew", meetPrior: false, meetup: "MAR 16", meetupTime: "12pm", meetupLoc: "Zilker Park"), User(name: "Ann", picture: "chris", meetPrior: false, meetup: "APR 1", meetupTime: "2pm", meetupLoc: "Zilker Park"), User(name: "Mike", picture: "bastian", meetPrior: false, meetup: "APR 1", meetupTime: "4pm", meetupLoc: "Zilker Park")]

class PendingViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!
    
    var pendingTableViewCellIdentifier = "pendingTableViewCellIdentifier"
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return pending.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell:PendingTableViewCell = tableView.dequeueReusableCell(withIdentifier: pendingTableViewCellIdentifier, for: indexPath as IndexPath) as! PendingTableViewCell
        let user:User = pending[indexPath.row]
        
        cell.userName.text = user.userName
        cell.userImage.image = UIImage(named: "\(user.image)")
        cell.meetDate.text = "\(user.date) at \(user.time)"
        cell.meetLocation.text = user.location
        
        return cell as UITableViewCell
    }
    
}
