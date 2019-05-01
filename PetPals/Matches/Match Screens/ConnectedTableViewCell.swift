//
//  ConnectedTableViewCell.swift
//  PetPals
//
//  Created by Georgina Garza on 3/19/19.
//  Copyright © 2019 PetPals.inc. All rights reserved.
//

import UIKit

class ConnectedTableViewCell: UITableViewCell {
    // Connect necessary fields
    @IBOutlet weak var userImage: MatchesImage!
    @IBOutlet weak var userName: UILabel!
    @IBOutlet weak var meetupLabel: UILabel!
    
    // Know what meetup this is
    var meetup: Meetup!
    
    override func awakeFromNib() {
        super.awakeFromNib()

        // Make the profile pictures circles
        userImage.layer.cornerRadius = userImage.frame.size.width / 2
        userImage.clipsToBounds = true
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

}
