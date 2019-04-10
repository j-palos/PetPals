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
    
    init(bio: String, firstName: String, lastName: String, id: String, profilePic: URL, petType: String) {
        self.bio = bio
        self.id = id
        self.imageURL = profilePic
        self.petType = petType
        self.lastName = lastName
        self.firstName = firstName
        self.location = nil
    }
    
    init(bio: String, firstName: String, lastName: String, id: String, profilePic: URL, petType: String, location: CLLocation) {
        self.bio = bio
        self.id = id
        self.imageURL = profilePic
        self.petType = petType
        self.lastName = lastName
        self.firstName = firstName
        self.location = location
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
                
                let user = UserProfile(bio: bio, firstName: firstname, lastName: lastname,
                                       id: uid, profilePic: link, petType: pettype)
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
            
                let user = UserProfile(bio: bio, firstName: firstname, lastName: lastname,
                                       id: id, profilePic: link, petType: pettype)
                completion(user)
            }
        })
    }
    
    class func getAllUsersWithinRadius(exceptID: String, withinMileRadius radius: Double, completion: @escaping (UserProfile) -> Swift.Void) {
        // where user geolocations are stored
        let geoFireRef = Database.database().reference().child("Geolocations")
        let geoFire = GeoFire(firebaseRef: geoFireRef)
        var geoQuery: GFQuery?
        
        // get our location
        // clearing phone removes
        //todo: move storing location to login and not signup
        let userLat = UserDefaults.standard.value(forKey: "current_latitude") as! String
        let userLong = UserDefaults.standard.value(forKey: "current_longitude") as! String
        
        let lat = CLLocationDegrees(Double(userLat)!)
        let lon = CLLocationDegrees(Double(userLong)!)
        let location: CLLocation = CLLocation(latitude: lat, longitude: lon)
        
        let userid = Auth.auth().currentUser!.uid
        let petTypes = UserDefaults.standard.stringArray(forKey: "petTypes") ?? AppConstants.petOptions
        
        var swipedAlready = [String]()
        let ref = Database.database().reference().child("Swipes").child(userid)
        ref.observeSingleEvent(of: .value, with: { snapshot in
            if snapshot.exists() {
                for swipe in snapshot.childSnapshot(forPath: "Likes").children {
                    
                    let uid = (swipe as! DataSnapshot).key
                    swipedAlready.append(uid)
                    print("Liked user \(uid) already")
                }
                for swipe in snapshot.childSnapshot(forPath: "DisLikes").children {
                    
                    let uid = (swipe as! DataSnapshot).key
                    swipedAlready.append(uid)
                    print("Disliked user \(uid) already")
                }
            }
            
            //We want users within the specified radius
            let radiusInKM = radius * 1.60934
            geoQuery = geoFire.query(at: location, withRadius: radiusInKM)
            geoQuery?.observe(.keyEntered, with: { (key: String!, location: CLLocation!)  in
                if (key != userid && key != exceptID) && !swipedAlready.contains(key) {
                    let ref = Database.database().reference().child("Users").child(key!).child("user_details")
                    
                    ref.observeSingleEvent(of: .value, with: { (snapshot) in
                        let data = snapshot.value as! [String: Any]
                        
                        let bio = data["bio"] as! String
                        let firstname = data["first_name"] as! String
                        let lastname = data["last_name"] as! String
                        let link = URL(string: data["profile_pic_url"] as! String)!
                        let pettype = data["pet_type"] as! String
                        let active = data["is_active"] as! Bool
                        
                        if petTypes.contains(pettype) && active == true {
                            let user = UserProfile(bio: bio, firstName: firstname, lastName: lastname,
                                                   id: key!, profilePic: link, petType: pettype, location: location)
                            completion(user)
                        }
                        
                    })
                }
            })
            
        })
    }
    
    func swipeRight(onUserProfile profile: UserProfile) {
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
                      "is_active": true] as [String : Any]
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
                                  "is_active": true] as [String : Any]
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
    
}
