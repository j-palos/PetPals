//
//  UpcomingDateTableViewCell.swift
//  PetPals
//
//  Created by Georgina Garza on 4/22/19.
//  Copyright © 2019 PetPals.inc. All rights reserved.
//

import UIKit

class UpcomingDateTableViewCell: UITableViewCell {
    
    // Connect necessary fields
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

}
