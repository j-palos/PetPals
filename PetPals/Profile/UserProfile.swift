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
import PromiseKit

struct CustomError : LocalizedError {
    var errorDescription: String? { return errorMsg }
    var failureReason: String? { return errorMsg }

    private var errorMsg : String
    
    init(_ description: String) {
        errorMsg = description
    }
}

class UserProfile: NSObject {
    var id: String
    var lastName: String
    var firstName: String
    var bio: String
    var imageURL: URL
    var image: UIImage
    var petType: String
    var location: CLLocation?
    var active: Bool
    var deleted: Bool

    init(bio: String, firstName: String, lastName: String, id: String, profilePic: URL, petType: String, location: CLLocation, active: Bool, deleted: Bool, image: UIImage) {
        self.bio = bio
        self.id = id
        self.imageURL = profilePic
        self.petType = petType
        self.lastName = lastName
        self.firstName = firstName
        self.location = location
        self.image = image
        self.active = active
        self.deleted = deleted
    
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
                                  "is_active": true,
                                  "is_deleted": false] as [String: Any]
                    let usersRef = Database.database().reference().child("Users")
                    let userDetailsRef = usersRef.child(uid).child("user_details")
                    userDetailsRef.updateChildValues(values, withCompletionBlock: { err, _ in
                        
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
    
    class func checkIfProfileCreated(forUserWithId uid: String, completion: @escaping (Error?, UserProfile?, UIViewController?) -> Swift.Void) {
        let usersRef = Database.database().reference().child("Users")
        usersRef.child(uid).child("user_details").observeSingleEvent(of: .value, with: { snapshot in
            let storyboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
            var viewController: UIViewController
            if !snapshot.exists() {
                viewController = storyboard.instantiateViewController(withIdentifier: createProfileVCIdenfifier)
                completion(nil, nil, viewController)
            }
            else {
                viewController = storyboard.instantiateViewController(withIdentifier: mainVCAfterAuthIdentifier)
                if let data = snapshot.value as? [String: Any] {
                    let usrDefaults: UserDefaults = .standard
                    let url = data["profile_pic_url"] as! String
                    usrDefaults.set(URL(string: url), forKey: "profile_image")
                    
                    var user:UserProfile? //will set this variable once all values are loaded in
                    
                    let bio = data["bio"] as! String
                    let firstname = data["first_name"] as! String
                    let lastname = data["last_name"] as! String
                    let link = URL(string: data["profile_pic_url"] as! String)!
                    let pettype = data["pet_type"] as! String
                    let isActive = data["is_active"] as! Bool
                    var deleted = false
                    if let is_deleted = data["is_deleted"] as! Bool? {
                        deleted = is_deleted
                    }
                    var image:UIImage?
                    //load image
                    avatar(url:link).done {
                        image = $0
                        
                        //load location
                        //Geofire references
                        let geofireRef = Database.database().reference().child("Geolocations")
                        let geoFire = GeoFire(firebaseRef: geofireRef)
                        geoFire.getLocationForKey(uid, withCallback: { (location: CLLocation?, error: Error?) in
                            if let error = error {
                                print("An error occurred getting the location for \(uid): \(error.localizedDescription)")
                                completion(error, nil, viewController)
                                return
                            }
                            if location != nil {
                                print("Location for \(uid) is [\(location!.coordinate.latitude), \(location!.coordinate.longitude)]")
                                //load data into the global user profile
                                user = UserProfile(bio: bio, firstName: firstname, lastName: lastname,
                                                   id: uid, profilePic: link, petType: pettype,
                                                   location: location!, active: isActive, deleted: deleted, image: image!)
                                completion(nil, user, viewController)
                            } else {
                                print("GeoFire does not contain a location for \(uid)")
                                completion(nil, nil, viewController)
                            }
                        })
                    }
                }
            }
        }) { error in
            completion(error, nil, nil)
        }
    }
    
    class func loginUser(withEmail: String, password: String, completion: @escaping (Error?, UIViewController?) -> Swift.Void) {
        Auth.auth().signIn(withEmail: withEmail, password: password, completion: { user, error in
            if error == nil, let user = user?.user {
                UserProfile.checkIfProfileCreated(forUserWithId: user.uid, completion: { err, currentUser, nextVC in
                    profile = currentUser
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
                UserProfile.checkIfProfileCreated(forUserWithId: user.uid) { error, currentUser, nextVC in
                    profile = currentUser
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
            
            connectedMeetups.removeAll()
            inviteMeetups.removeAll()
            pendingMeetups.removeAll()
            matches.removeAll()
            
            completion(nil)
        }
        catch let signOutError as NSError {
            completion(signOutError)
        }
    }
    
    //TO DO: should really only be called at login and at app load
    class func getProfile(forUserID uid: String, completion: @escaping (UserProfile) -> Swift.Void) {
        //load values from the database
        let usersRef = Database.database().reference().child("Users")
        usersRef.child(uid).child("user_details").observeSingleEvent(of: .value, with: { snapshot in
            if let data = snapshot.value as? [String: Any] {
                var user:UserProfile? //will set this variable once all values are loaded in
                
                let bio = data["bio"] as! String
                let firstname = data["first_name"] as! String
                let lastname = data["last_name"] as! String
                let link = URL(string: data["profile_pic_url"] as! String)!
                let pettype = data["pet_type"] as! String
                let isActive = data["is_active"] as! Bool
                var deleted = false
                if let is_deleted = data["is_deleted"] as! Bool? {
                    deleted = is_deleted
                }
                var image:UIImage?
                //load image
                avatar(url:link).done {
                    image = $0
                    
                    //load location
                    //Geofire references
                    let geofireRef = Database.database().reference().child("Geolocations")
                    let geoFire = GeoFire(firebaseRef: geofireRef)
                    geoFire.getLocationForKey(uid, withCallback: { (location: CLLocation?, error: Error?) in
                        if let error = error {
                            print("An error occurred getting the location for \(uid): \(error.localizedDescription)")
                            return
                        }
                        if location != nil{
                            print("Location for \(uid) is [\(location!.coordinate.latitude), \(location!.coordinate.longitude)]")
                            //load data into the global user profile
                            user = UserProfile(bio: bio, firstName: firstname, lastName: lastname,
                                               id: uid, profilePic: link, petType: pettype,
                                               location: location!, active: isActive, deleted: deleted, image: image!)
                            completion(user!)
                        } else {
                            print("GeoFire does not contain a location for \(uid)")
                        }
                    })
                }
                
                
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
                            let isActive = data["is_active"] as! Bool
                            var deleted = false
                            if let isDeleted = data["is_deleted"] as! Bool? {
                                deleted = isDeleted
                            }
                            
                            //check if they have desired pet type and are active
                            if deleted == false && isActive == true && petTypes.contains(pettype) {
                                //get the rest of the profile info
                                let bio = data["bio"] as! String
                                let firstname = data["first_name"] as! String
                                let lastname = data["last_name"] as! String
                                let link = URL(string: data["profile_pic_url"] as! String)!
                                var image:UIImage?
                                //load image
                                avatar(url:link).done {
                                    image = $0
                                    let user = UserProfile(bio: bio, firstName: firstname, lastName: lastname,
                                                           id: key!, profilePic: link, petType: pettype, location: location,
                                                           active: isActive, deleted: deleted, image: image!)
                                    
                                    completion(user)
                                }
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
                UserProfile.getProfile(forUserID: snapshot.key, completion: { (match: UserProfile?) in
                    if let match = match {
                        print("I found another match")
                        if !match.deleted && match.active {
                            completion(match)
                        }
                    }
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
            //Connected meetups are those where both parties accepted so could be receved or sent
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
                            if !fromUser.deleted && fromUser.active {
                                completion(Meetup(id: id, location: location, date: date,
                                                  time: time, from: fromUser, with: self, status: status))
                            }
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
                            if !toUser.deleted && toUser.active {
                                completion(Meetup(id: id, location: location, date: date,
                                                  time: time, from: self, with: toUser, status: status))
                            }
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
                            if !fromUser.deleted && fromUser.active {
                                completion(Meetup(id: id, location: location, date: date,
                                                  time: time, from: fromUser, with: self, status: status))
                            }
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
                            if !toUser.deleted && toUser.active {
                                completion(Meetup(id: id, location: location, date: date,
                                                  time: time, from: self, with: toUser, status: status))
                            }
                        })
                    }
                })
            })
        }
        
    }
    
    
    func suggestMeetup(withUser user: UserProfile, onDate date: String, atTime time: String,
                       atLocation loc: String, completion: @escaping (Error?) -> Swift.Void) {
        
        //Make usre that a user is active before we suggest any meetups with them
        guard user.active else {
            completion(CustomError("User is not active"))
            return
        }
        
        //Make sure user isn't deleted before suggesting meetup
        guard !user.deleted else {
            completion(CustomError("User is deleted"))
            return
        }
        
        //Create a meetup and suggest
        Meetup(location: loc, date: date, time: time, from: self, with: user).suggest { (error) in
            //Return any error
            completion(error)
        }
    }
    
    // promise function for obtaining our card avatage image
    static func avatar(url: URL) -> Promise<UIImage> {
        return firstly {
            URLSession.shared.dataTask(.promise, with: url)
            }.compactMap {
                UIImage(data: $0.data)
        }
    }
    
    func deleteAccount(completion: @escaping (Error?) -> Swift.Void) {
        //Geofire references
        //let geofireRef = Database.database().reference()
        //let geoFire = GeoFire(firebaseRef: geofireRef)
        
        //Make sure user is authenticated
        if let user = Auth.auth().currentUser {
            print("HERE")
            let userId = user.uid
            print("\(userId)")
            //if they are then try to delete the login credentials
            user.delete { (error: Error?) in
                if let error = error {
                    // An error happened.
                
                    completion(error)
                    
                } else {
                    // Account deleted.
                    
                    //Delete geofire location
                    //geoFire.removeKey(userId)
                    
                    //Set profile to deleted?
                    let values = ["is_active": false, "is_deleted": true] as [String : Any]
                    let usersRef = Database.database().reference().child("Users")
                    let userDetailsRef = usersRef.child(userId).child("user_details")
                    userDetailsRef.updateChildValues(values, withCompletionBlock: { (err, _) in
                        completion(err)
                    })
                }
            }
        } else {
            completion(CustomError("Not currently logged in"))
        }
    }
}
