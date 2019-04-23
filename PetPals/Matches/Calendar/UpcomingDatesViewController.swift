//
//  UpcomingDatesViewController.swift
//  PetPals
//
//  Created by Georgina Garza on 3/24/19.
//  Copyright © 2019 PetPals.inc. All rights reserved.
//

import UIKit

let dates = [["Emily", "April 02", "12 pm"], ["Jeffery", "April 11", "12 pm"], ["Leo", "April 20", "12 pm"]]

class UpcomingDatesViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    // Connect necessary fields
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.tableFooterView = UIView()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dates.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell:UpcomingDateTableViewCell = tableView.dequeueReusableCell(withIdentifier: "upcomingDateTableViewCellIdentifier", for: indexPath as IndexPath) as! UpcomingDateTableViewCell
        
        let currDate = dates[indexPath.row]
        
        cell.nameLabel.text = currDate[0]
        cell.dateLabel.text = currDate[1]
        cell.timeLabel.text = currDate[2]
        
        return cell
    }

}
