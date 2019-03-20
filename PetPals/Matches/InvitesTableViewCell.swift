//
//  InvitesTableViewCell.swift
//  PetPals
//
//  Created by Georgina Garza on 3/19/19.
//  Copyright © 2019 PetPals.inc. All rights reserved.
//

import UIKit

class InvitesTableViewCell: UITableViewCell {
    @IBOutlet weak var userImage: UIImageView!
    @IBOutlet weak var userName: UILabel!
    @IBOutlet weak var meetDate: UILabel!
    @IBOutlet weak var meetLocation: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
