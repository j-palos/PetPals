//
//  Meetup.swift
//  PetPals
//
//  Created by Gerardo Mares on 4/19/19.
//  Copyright © 2019 PetPals.inc. All rights reserved.
//

import FirebaseDatabase

enum MeetupStatus: String {
    case pending = "pending"
    case accepted = "accepted"
    case past = "past"
    case canceled = "canceled"
}

enum MeetupType {
    case connected
    case invites
    case pending
}

class Meetup {
    
    var location: String
    var date: String
    var time: String
    var status: MeetupStatus
    var fromUser: UserProfile
    var toUser: UserProfile
    
    init(location: String, date: String, time: String, from: UserProfile, with: UserProfile) {
        
        self.fromUser = from
        self.toUser = with
        self.location = location
        self.date = date
        self.time = time
        self.status = .pending
    }
    
    init(location: String, date: String, time: String, from: UserProfile, with: UserProfile, status: MeetupStatus) {
        
        self.fromUser = from
        self.toUser = with
        self.location = location
        self.date = date
        self.time = time
        self.status = status
    }
    
    func setStatus(withStatus status: MeetupStatus) {
        self.status = status
    }
    
    func suggest(completion: @escaping (Error?) -> Swift.Void) {
        
        let timestamp = NSDate().timeIntervalSince1970
        let meetupRef = Database.database().reference().child("Meetups").childByAutoId()
        let values = ["timestamp": timestamp,
                      "from": fromUser.id,
                      "to": toUser.id,
                      "location": location,
                      "date": date,
                      "time": time,
                      "status": status.rawValue ] as [String: Any]
        
        meetupRef.updateChildValues(values) { (err: Error?, ref: DatabaseReference) in
            
            if let error = err {
                completion(error)
            }
            
            guard let meetupId = ref.key else {
                let error = NSError(domain:"", code:401, userInfo:[ NSLocalizedDescriptionKey: "Invaild access token"]) as Error
                completion(error)
                return
            }
            
            let userMeetupsRef = Database.database().reference().child("UserMeetups")
            
            let timeValues = ["timestamp": timestamp]
            
            userMeetupsRef.child(self.fromUser.id).child("sent").child(meetupId).updateChildValues(timeValues)

            userMeetupsRef.child(self.toUser.id).child("received").child(meetupId).updateChildValues(timeValues)
        
            
        }
        
        
    }
}
