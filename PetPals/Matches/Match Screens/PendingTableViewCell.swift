//
//  PendingTableViewCell.swift
//  PetPals
//
//  Created by Georgina Garza on 3/19/19.
//  Copyright © 2019 PetPals.inc. All rights reserved.
//

import UIKit

class PendingTableViewCell: UITableViewCell {
    // Connect necessary fields
    @IBOutlet weak var userImage: MatchesImage!
    @IBOutlet weak var userName: UILabel!
    @IBOutlet weak var meetDate: UILabel!
    @IBOutlet weak var meetLocation: UILabel!
    
    // Know what meetup this is
    var meetup: Meetup!
    
    // Parent for reload
    var parent: PendingViewController!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        // Make the profile pictures circles
        userImage.layer.cornerRadius = userImage.frame.size.width / 2
        userImage.clipsToBounds = true
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

    // ***ISSUE in UI: the sent 3 days ago thing: I went ahead and deleted since we didn't include in DB
    
    // User wants to cancel this meetup
    @IBAction func cancelClicked(_ sender: Any) {
        meetup.cancel(completion: { (error) in
        })
        parent.reloadMeetups(meetupToDelete: meetup)
    }
}
