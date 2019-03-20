//
//  User.swift
//  PetPals
//
//  Created by Georgina Garza on 3/19/19.
//  Copyright © 2019 PetPals.inc. All rights reserved.
//

import UIKit

class User {
    
    var userName: String
    var image: String
    var prevMeet: Bool
    var date: String
    var time: String
    var location: String
    
    init(name: String, picture: String, meetPrior: Bool, meetup: String, meetupTime: String, meetupLoc: String) {
        userName = name
        image = picture
        prevMeet = meetPrior
        date = meetup
        time = meetupTime
        location = meetupLoc
    }
    
}
