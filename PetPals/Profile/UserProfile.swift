//
//  UserProfile.swift
//  PetPals
//
//  Created by Gerardo Mares on 4/1/19.
//  Copyright © 2019 PetPals.inc. All rights reserved.
//

import Firebase
import FirebaseDatabase
import FirebaseStorage
import Foundation
import GeoFire

class UserProfile: NSObject {
    var id: String
    var lastName: String
    var firstName: String
    var bio: String
    var imageURL: URL
    var petType: String
    var location: CLLocation?
    var active: Bool
    
    init(bio: String, firstName: String, lastName: String, id: String, profilePic: URL, petType: String, active: Bool) {
        self.bio = bio
        self.id = id
        self.imageURL = profilePic
        self.petType = petType
        self.lastName = lastName
        self.firstName = firstName
        self.location = nil
        self.active = active
    }
    
    init(bio: String, firstName: String, lastName: String, id: String, profilePic: URL, petType: String, location: CLLocation, active: Bool) {
        self.bio = bio
        self.id = id
        self.imageURL = profilePic
        self.petType = petType
        self.lastName = lastName
        self.firstName = firstName
        self.location = location
        self.active = active
    }
    
    class func registerUser(email: String, password: String, completion: @escaping (Bool) -> Swift.Void) {
        Auth.auth().createUser(withEmail: email, password: password, completion: { _, error in
            completion(error == nil)
        })
    }
    
    class func createProfile(forUserWithId uid: String,
                             withImage profilePic: UIImage,
                             withBio bio: String,
                             withFirstName first: String,
                             withLastName last: String,
                             withPet pet: String,
                             completion: @escaping (Bool) -> Swift.Void) {
        let storageRef = Storage.storage().reference().child("usersPics").child(uid)
        let imageData = profilePic.pngData()
        storageRef.putData(imageData!, metadata: nil) { _, err in
            if err == nil {
                storageRef.downloadURL { url, _ in
                    guard let downloadURL = url else {
                        // Uh-oh, an error occurred!
                        completion(false)
                        return
                    }
                    let path = downloadURL.absoluteString
                    let values = ["bio": bio,
                                  "first_name": first,
                                  "last_name": last,
                                  "profile_pic_url": path,
                                  "pet_type": pet,
                                  "is_active": true] as [String: Any]
                    let usersRef = Database.database().reference().child("Users")
                    usersRef.child(uid).child("user_details").updateChildValues(values, withCompletionBlock: { err, _ in
                        
                        if err == nil {
                            completion(true)
                            let usrDefaults: UserDefaults = UserDefaults.standard
                            usrDefaults.set(URL(string: path), forKey: "profile_image")
                        }
                    })
                }
            }
            else {
                completion(false)
            }
        }
    }
    
    class func checkIfProfileCreated(forUserWithId uid: String, completion: @escaping (Error?, UIViewController?) -> Swift.Void) {
        let usersRef = Database.database().reference().child("Users")
        usersRef.child(uid).child("user_details").observeSingleEvent(of: .value, with: { snapshot in
            let storyboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
            var viewController: UIViewController
            if !snapshot.exists() {
                viewController = storyboard.instantiateViewController(withIdentifier: createProfileVCIdenfifier)
            }
            else {
                if let data = snapshot.value as? [String: Any] {
                    let usrDefaults: UserDefaults = .standard
                    let url = data["profile_pic_url"] as! String
                    usrDefaults.set(URL(string: url), forKey: "profile_image")
                }
                viewController = storyboard.instantiateViewController(withIdentifier: mainVCAfterAuthIdentifier)
            }
            
            completion(nil, viewController as UIViewController)
        }) { error in
            completion(error, nil)
        }
    }
    
    class func loginUser(withEmail: String, password: String, completion: @escaping (Error?, UIViewController?) -> Swift.Void) {
        Auth.auth().signIn(withEmail: withEmail, password: password, completion: { user, error in
            if error == nil, let user = user?.user {
                UserProfile.checkIfProfileCreated(forUserWithId: user.uid, completion: { err, nextVC in
                    completion(err, nextVC)
                })
            }
            else {
                completion(error, nil)
            }
        })
    }
    
    class func loginUser(withCredentials creds: AuthCredential, completion: @escaping (Error?, UIViewController?) -> Swift.Void) {
        Auth.auth().signInAndRetrieveData(with: creds, completion: { user, error in
            if let err = error {
                completion(err, nil)
            }
            if let user = user?.user {
                UserDefaults.standard.set(user.uid, forKey: "user_uid")
                UserProfile.checkIfProfileCreated(forUserWithId: user.uid) { error, nextVC in
                    completion(error, nextVC)
                }
            }
        })
    }
    
    class func logOutUser(completion: @escaping (NSError?) -> Swift.Void) {
        do {
            try Auth.auth().signOut()
            let storyBoard: UIStoryboard = UIStoryboard(name: "Initial", bundle: nil)
            let appdelegate = UIApplication.shared.delegate as! AppDelegate
            appdelegate.window!.rootViewController = storyBoard.instantiateInitialViewController()
            
            completion(nil)
        }
        catch let signOutError as NSError {
            completion(signOutError)
        }
    }
    
    class func getProfile(forUserID uid: String, completion: @escaping (UserProfile) -> Swift.Void) {
        let usersRef = Database.database().reference().child("Users")
        usersRef.child(uid).child("user_details").observeSingleEvent(of: .value, with: { snapshot in
            if let data = snapshot.value as? [String: Any] {
                let bio = data["bio"] as! String
                let firstname = data["first_name"] as! String
                let lastname = data["last_name"] as! String
                let link = URL(string: data["profile_pic_url"] as! String)!
                let pettype = data["pet_type"] as! String
                let isActive = data["is_active"] as! Bool
                
                let user = UserProfile(bio: bio, firstName: firstname, lastName: lastname,
                                       id: uid, profilePic: link, petType: pettype, active: isActive)
                completion(user)
            }
        })
    }
    
    class func getDistanceInMiles(fromUsersLocation userLocation: CLLocation) -> Int {
        let userLat = UserDefaults.standard.value(forKey: "current_latitude") as! String
        let userLong = UserDefaults.standard.value(forKey: "current_longitude") as! String
        let myLocation: CLLocation = CLLocation(latitude: CLLocationDegrees(Double(userLat)!), longitude: CLLocationDegrees(Double(userLong)!))
        
        // What is this?
        let distance = myLocation.distance(from: userLocation) * 0.000621371
        return Int(round(distance))
    }
    
    class func getAllUsers(exceptID: String, completion: @escaping (UserProfile) -> Swift.Void) {
        Database.database().reference().child("Users").observe(.childAdded, with: { snapshot in
            let id = snapshot.key
            let snap = snapshot.value as! [String: Any]
            let data = snap["user_details"] as! [String: Any]

            if id != exceptID && data["is_active"] as! Bool == true {

                let bio = data["bio"] as! String
                let firstname = data["first_name"] as! String
                let lastname = data["last_name"] as! String
                let link = URL(string: data["profile_pic_url"] as! String)!
                let pettype = data["pet_type"] as! String
                let isActive = data["is_active"] as! Bool
            
                let user = UserProfile(bio: bio, firstName: firstname, lastName: lastname,
                                       id: id, profilePic: link, petType: pettype, active: isActive)
                completion(user)
            }
        })
    }
    
    class func getAllUsersWithinRadius(geoQuery: GFQuery?, completion: @escaping (UserProfile) -> Swift.Void) {
        let userid = Auth.auth().currentUser!.uid
        let swipesRef = Database.database().reference().child("Swipes").child(userid)
        
        let petTypes = UserDefaults.standard.stringArray(forKey: "petTypes") ?? AppConstants.petOptions
        geoQuery?.observe(.keyEntered, with: { (key: String!, location: CLLocation!)  in
            if key != userid {
                let ref = Database.database().reference().child("Users").child(key!).child("user_details")
                ref.observeSingleEvent(of: .value, with: { (snapshot) in
                    if snapshot.exists() {
                    swipesRef.observeSingleEvent(of: .value, with: { swipesSnapshot in
                        //we only want this user if we havent swiped on them already
                        if !(swipesSnapshot.hasChild("Likes/\(key!)") ||
                            swipesSnapshot.hasChild("DisLikes/\(key!)")) {
                            
                            let data = snapshot.value as! [String: Any]
                            
                            let pettype = data["pet_type"] as! String
                            let active = data["is_active"] as! Bool
                            
                            //check if they have desired pet type and are active
                            if petTypes.contains(pettype) && active == true {
                                //get the rest of the profile info
                                let bio = data["bio"] as! String
                                let firstname = data["first_name"] as! String
                                let lastname = data["last_name"] as! String
                                let link = URL(string: data["profile_pic_url"] as! String)!
                                let isActive = data["is_active"] as! Bool
                                
                                let user = UserProfile(bio: bio, firstName: firstname, lastName: lastname,
                                                       id: key!, profilePic: link, petType: pettype, location: location, active: isActive)
                                completion(user)
                            }
                            
                        }
                    })
                    }
                })
            }
        })
    }
    
    func swipeRight(onUserProfile profile: UserProfile, completion: @escaping (Bool) -> Swift.Void) {
        let swipeRef = Database.database().reference().child("Swipes")
        let values = ["timestamp": NSDate().timeIntervalSince1970]
        swipeRef.child(self.id).child("Likes").child(profile.id).updateChildValues(values, withCompletionBlock: { (err, _) in
            print("Liked user \(profile.id)")
            swipeRef.child(profile.id).child("Likes").child(self.id).observeSingleEvent(of: .value, with: { (snapshot) in
                if snapshot.exists() {
                    print("Match made between users \(self.id) and \(profile.id)")
                    let match_values = ["timestamp": NSDate().timeIntervalSince1970]
                    let matchesRef = Database.database().reference().child("Matches")
                    matchesRef.child(self.id).child("users").child(profile.id).updateChildValues(match_values,withCompletionBlock: { (err, _) in
                        
                    })
                    matchesRef.child(profile.id).child("users").child(self.id).updateChildValues(match_values, withCompletionBlock: { (err, _) in
                        
                    })
                    
                    completion(true)
                }
                else {
                    //no match exists yet between the users
                    completion(false)
                }
            })
        })
    }
    
    func swipeLeft(onUserProfile profile: UserProfile) {
        let swipeRef = Database.database().reference().child("Swipes")
        
        let datetime = NSDate().timeIntervalSince1970
        swipeRef.child(self.id).child("DisLikes").child(profile.id).updateChildValues(["timestamp": datetime], withCompletionBlock: { (err, _) in
             print("DisLiked user \(profile.id)")
        })
    }
    
    //gets matches and calls completion handler every time a new match is added
    func getMatches(completion: @escaping (UserProfile) -> Swift.Void) {
        let ref = Database.database().reference().child("Matches").child("\(self.id)/users")
        ref.observe(.childAdded) { (snapshot) in
            if snapshot.exists() {
                UserProfile.getProfile(forUserID: snapshot.key, completion: { (match) in
                    print("I found another match")
                    completion(match)
                })
            }
        }
    }
    
    
    
    //updates the profiles data in database when called
    func update(completion: @escaping (Bool) -> Swift.Void) {
        let values = ["bio": self.bio,
                      "first_name": self.firstName,
                      "last_name": self.lastName,
                      "profile_pic_url": self.imageURL.absoluteString,
                      "pet_type": self.petType,
                      "is_active": self.active] as [String : Any]
        let usersRef = Database.database().reference().child("Users")
        usersRef.child(self.id).child("user_details").updateChildValues(values, withCompletionBlock: { (err, _) in
            
            if err == nil {
                completion(true)
                let usrDefaults:UserDefaults = UserDefaults.standard
                usrDefaults.set(self.imageURL, forKey: "profile_image")
            }
            else {
                completion(false)
            }
        })
    }
    
     //updates the profiles data in database when called, including image
    func update(toHaveImage profilePic: UIImage, completion: @escaping (Bool) -> Swift.Void) {
        let storageRef = Storage.storage().reference().child("usersPics").child(self.id)
        let imageData = profilePic.pngData()
        storageRef.putData(imageData!, metadata: nil) { (metadata, err) in
            if err == nil {
                
                storageRef.downloadURL { (url, error) in
                    guard let downloadURL = url else {
                        // Uh-oh, an error occurred!
                        completion(false)
                        return
                    }
                    let path = downloadURL.absoluteString
                    let values = ["bio": self.bio,
                                  "first_name": self.firstName,
                                  "last_name": self.lastName,
                                  "profile_pic_url": path,
                                  "pet_type": self.petType,
                                  "is_active": self.active] as [String : Any]
                    let usersRef = Database.database().reference().child("Users")
                    usersRef.child(self.id).child("user_details").updateChildValues(values, withCompletionBlock: { (err, _) in
                        
                        if err == nil {
                            completion(true)
                            let usrDefaults:UserDefaults = UserDefaults.standard
                            usrDefaults.set(URL(string:path), forKey: "profile_image")
                        }
                        else {
                            completion(false)
                        }
                    })
                }
            }
            else {
                completion(false)
            }
        }
    }
    
    
    func getMeetups(withType meetupType: MeetupType, completion: @escaping (Meetup) -> Swift.Void) {
        
        let userMeetupRef = Database.database().reference().child("UserMeetups").child(self.id)
        let meetupRef = Database.database().reference().child("Meetups")
        
        switch meetupType {
        case .connected:
            userMeetupRef.child("received").observe(.childAdded, with: { (snapshot: DataSnapshot) in
                
                let meetupId = snapshot.key
                
                meetupRef.child(meetupId).observeSingleEvent(of: .value, with: { (meetupSnapshot: DataSnapshot) in
                    
                    let data = meetupSnapshot.value as! [String: Any]
                    
                    let id = meetupSnapshot.key
                    let date = data["date"] as! String
                    let time =  data["time"] as! String
                    let location =  data["location"] as! String
                    let fromId =  data["from"] as! String
                    let status = MeetupStatus(rawValue: data["status"] as! String)!
                    
                    if status == .accepted || status == .past {
                        UserProfile.getProfile(forUserID: fromId, completion: { (fromUser: UserProfile) in
                            completion(Meetup(id: id, location: location, date: date, time: time, from: fromUser, with: self, status: status))
                        })
                    }
                })
            })
            
            userMeetupRef.child("sent").observe(.childAdded, with: { (snapshot: DataSnapshot) in
                let meetupId = snapshot.key
                meetupRef.child(meetupId).observeSingleEvent(of: .value, with: { (meetupSnapshot: DataSnapshot) in
                    
                    let data = meetupSnapshot.value as! [String: Any]
                    
                    let id = meetupSnapshot.key
                    let date = data["date"] as! String
                    let time =  data["time"] as! String
                    let location = data["location"] as! String
                    let toId =  data["to"] as! String
                    let status = MeetupStatus(rawValue: data["status"] as! String)!
                    
                    if status == .accepted || status == .past {
                        UserProfile.getProfile(forUserID: toId, completion: { (toUser: UserProfile) in
                            completion(Meetup(id: id, location: location, date: date, time: time, from: self, with: toUser, status: status))
                        })
                    }
                })
            })
        case .invites:
            //sent from other to you
            
            userMeetupRef.child("received").observe(.childAdded, with: { (snapshot: DataSnapshot) in
                
                let meetupId = snapshot.key
                
                meetupRef.child(meetupId).observeSingleEvent(of: .value, with: { (meetupSnapshot: DataSnapshot) in
                
                    let data = meetupSnapshot.value as! [String: Any]
                    
                    let id = meetupSnapshot.key
                    let date = data["date"] as! String
                    let time =  data["time"] as! String
                    let location =  data["location"] as! String
                    let fromId =  data["from"] as! String
                    let status = MeetupStatus(rawValue: data["status"] as! String)!

                    if status == .pending {
                        UserProfile.getProfile(forUserID: fromId, completion: { (fromUser: UserProfile) in
                            completion(Meetup(id: id, location: location, date: date, time: time, from: fromUser, with: self, status: status))
                        })
                    }
                })
            })
        case .pending:
            //sent from you to other
            userMeetupRef.child("sent").observe(.childAdded, with: { (snapshot: DataSnapshot) in
                let meetupId = snapshot.key
                meetupRef.child(meetupId).observeSingleEvent(of: .value, with: { (meetupSnapshot: DataSnapshot) in
                    
                    let data = meetupSnapshot.value as! [String: Any]
                    
                    
                    let id = meetupSnapshot.key
                    let date = data["date"] as! String
                    let time =  data["time"] as! String
                    let location = data["location"] as! String
                    let toId =  data["to"] as! String
                    let status = MeetupStatus(rawValue: data["status"] as! String)!
                    
                    if status == .pending {
                        UserProfile.getProfile(forUserID: toId, completion: { (toUser: UserProfile) in
                            completion(Meetup(id: id, location: location, date: date, time: time, from: self, with: toUser, status: status))
                        })
                    }
                })
            })
        }
        
    }
    
    
    func suggestMeetup(withUser user: UserProfile, onDate date: String, atTime time: String, atLocation loc: String,
                       completion: @escaping (Error?) -> Swift.Void) {
        
        Meetup(location: loc, date: date, time: time, from: self, with: user).suggest { (error) in
            completion(error)
        }
    }
    
}
