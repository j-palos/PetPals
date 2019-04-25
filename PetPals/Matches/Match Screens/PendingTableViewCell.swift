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
