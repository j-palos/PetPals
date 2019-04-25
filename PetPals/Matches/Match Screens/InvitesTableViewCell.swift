//
//  InvitesTableViewCell.swift
//  PetPals
//
//  Created by Georgina Garza on 3/19/19.
//  Copyright © 2019 PetPals.inc. All rights reserved.
//

import UIKit

class InvitesTableViewCell: UITableViewCell {
    // Connect necessary fields
    @IBOutlet weak var userImage: MatchesImage!
    @IBOutlet weak var userName: UILabel!
    @IBOutlet weak var meetDate: UILabel!
    @IBOutlet weak var meetLocation: UILabel!
    
    // Know what meetup this is
    var meetup: Meetup!
    
    // Parent for reload
    var parent: InvitesViewController!
    
    override func awakeFromNib() {
        super.awakeFromNib()
 
        // Make the profile pictures circles
        userImage.layer.cornerRadius = userImage.frame.size.width / 2
        userImage.clipsToBounds = true
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    // ***ISSUE: None of the following methods worked in relation to DB? But no error?
    
    // User wants to accept this meetup
    @IBAction func acceptClicked(_ sender: Any) {
        meetup.accept(completion: { (error) in
            print("There was an error accepting this meetup \(String(describing: error)).")
        })
        parent.reloadMeetups(meetupToDelete: meetup)
    }
    
    // User wants to decline this meetup
    @IBAction func declineClicked(_ sender: Any) {
        meetup.cancel(completion: { (error) in
            print("There was an error declining this meetup \(String(describing: error)).")
        })
        parent.reloadMeetups(meetupToDelete: meetup)
    }
}
