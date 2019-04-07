//
//  UserProfile.swift
//  PetPals
//
//  Created by Gerardo Mares on 4/1/19.
//  Copyright © 2019 PetPals.inc. All rights reserved.
//

import Foundation
import Firebase
import FirebaseDatabase
import FirebaseStorage
import GeoFire

class UserProfile: NSObject {
    
    var id:String
    var lastName:String
    var firstName:String
    var bio:String
    var imageURL:URL
    var petType:String
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
        Auth.auth().createUser(withEmail: email, password: password, completion: { (user, error) in
            completion(error == nil)
        })
    }
    
    class func createProfile(forUserWithId uid:String,
                             withImage profilePic: UIImage,
                             withBio bio: String,
                             withFirstName first: String,
                             withLastName last: String,
                             withPet pet: String,
                             completion: @escaping (Bool) -> Swift.Void) {
        
        let storageRef = Storage.storage().reference().child("usersPics").child(uid)
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
                    let values = ["bio": bio,
                                  "first_name": first,
                                  "last_name": last,
                                  "profile_pic_url": path,
                                  "pet_type": pet,
                                  "is_active": true] as [String : Any]
                    let usersRef = Database.database().reference().child("Users")
                    usersRef.child(uid).child("user_details").updateChildValues(values, withCompletionBlock: { (err, _) in
                        
                        if err == nil {
                            completion(true)
                            let usrDefaults:UserDefaults = UserDefaults.standard
                            usrDefaults.set(URL(string:path), forKey: "profile_image")
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
        usersRef.child(uid).child("user_details").observeSingleEvent(of: .value, with: { (snapshot) in
            let storyboard: UIStoryboard = UIStoryboard(name:"Main", bundle: nil)
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
        }) { (error) in
            completion(error, nil)
        }
    }
    
    class func loginUser(withEmail: String, password: String, completion: @escaping (Error?, UIViewController?) -> Swift.Void) {
        Auth.auth().signIn(withEmail: withEmail, password: password, completion: { (user, error) in
            if error == nil, let user = user?.user {
                UserProfile.checkIfProfileCreated(forUserWithId: user.uid, completion: { (err, nextVC) in
                    completion(err, nextVC)
                })
            }
            else {
                completion(error, nil)
            }
        })
    }
    
    class func loginUser(withCredentials creds: AuthCredential, completion: @escaping (Error?, UIViewController?) -> Swift.Void) {
        
        Auth.auth().signInAndRetrieveData(with: creds, completion: { (user, error) in
            if let err = error {
                completion(err, nil)
            }
            if let user = user?.user {
                UserProfile.checkIfProfileCreated(forUserWithId: user.uid) { (error, nextVC) in
                    completion(error, nextVC)
                }
            }
            
        })
    }
    
    class func logOutUser(completion: @escaping (NSError?) -> Swift.Void) {
        do {
            try Auth.auth().signOut()
            let storyBoard : UIStoryboard = UIStoryboard(name: "Initial", bundle:nil)
            let appdelegate = UIApplication.shared.delegate as! AppDelegate
            appdelegate.window!.rootViewController = storyBoard.instantiateInitialViewController()
            
            completion(nil)
        } catch let signOutError as NSError {
            completion(signOutError)
        }
    }
    
    class func getProfile(forUserID uid: String, completion: @escaping (UserProfile) -> Swift.Void) {
        let usersRef = Database.database().reference().child("Users")
        usersRef.child(uid).child("user_details").observeSingleEvent(of: .value, with: { (snapshot) in
            if let data = snapshot.value as? [String: String] {
                
                let bio = data["bio"]!
                let firstname = data["first_name"]!
                let lastname = data["last_name"]!
                let link = URL(string: data["profile_pic_url"]!)!
                let pettype = data["pet_type"]!
                
                URLSession.shared.dataTask(with: link, completionHandler: { (data, response, error) in
                    if error == nil {
                        _ = UIImage.init(data: data!)
                        let user = UserProfile(bio: bio, firstName: firstname, lastName: lastname,
                                               id: uid, profilePic: link, petType: pettype)
                        completion(user)
                    }
                }).resume()
            }
        })
    }
    
    
    class func getDistanceInMiles(fromUsersLocation userLocation: CLLocation) -> Int {
        
        let userLat = UserDefaults.standard.value(forKey: "current_latitude") as! String
        let userLong = UserDefaults.standard.value(forKey: "current_longitude") as! String
        let myLocation:CLLocation = CLLocation(latitude: CLLocationDegrees(Double(userLat)!), longitude: CLLocationDegrees(Double(userLong)!))
        
        
        let distance = myLocation.distance(from: userLocation) * 0.000621371
        return Int(round(distance))
    }
    
    class func getAllUsers(exceptID: String, completion: @escaping (UserProfile) -> Swift.Void) {
        Database.database().reference().child("Users").observe(.childAdded, with: { (snapshot) in
            let id = snapshot.key
            let data = snapshot.value as! [String: Any]
            
            if id != exceptID && data["is_active"] as! Bool == true {
                let bio = data["bio"] as! String
                let firstname = data["first_name"] as! String
                let lastname = data["last_name"] as! String
                let link = URL(string: data["profile_pic_url"] as! String)!
                let pettype = data["pet_type"] as! String
                URLSession.shared.dataTask(with: link, completionHandler: { (data, response, error) in
                    if error == nil {
                        _ = UIImage.init(data: data!)
                        let user = UserProfile(bio: bio, firstName: firstname, lastName: lastname,
                                               id: id, profilePic: link, petType: pettype)
                        completion(user)
                    }
                }).resume()
            }
        })
    }
    
    class func getAllUsers(exceptID: String, withinMileRadius radius: Double,  completion: @escaping (UserProfile) -> Swift.Void) {
        
        //where user geolocations are stored
        let geoFireRef = Database.database().reference().child("Geolocations")
        let geoFire = GeoFire(firebaseRef: geoFireRef)
        var geoQuery: GFQuery?

        
        //get our location
        let userLat = UserDefaults.standard.value(forKey: "current_latitude") as! String
        let userLong = UserDefaults.standard.value(forKey: "current_longitude") as! String
        
        let lat = CLLocationDegrees(Double(userLat)!)
        let lon = CLLocationDegrees(Double(userLong)!)
        let location: CLLocation = CLLocation(latitude: lat, longitude: lon)
        
        //We want users within the specified radius
        let radiusInKM = radius * 1.60934
        geoQuery = geoFire.query(at: location, withRadius: radiusInKM)
        geoQuery?.observe(.keyEntered, with: { (key: String!, location: CLLocation!)  in
            
            if key != Auth.auth().currentUser?.uid {
                let ref = Database.database().reference().child("Users").child(key!)
                
                ref.observeSingleEvent(of: .value, with: { (snapshot) in
                    let id = snapshot.key
                    let snap = snapshot.value as! [String: Any]
                    let data = snap["user_details"] as! [String: Any]
                    
                    let bio = data["bio"] as! String
                    let firstname = data["first_name"] as! String
                    let lastname = data["last_name"] as! String
                    let link = URL(string: data["profile_pic_url"] as! String)!
                    let pettype = data["pet_type"] as! String
                    
                    URLSession.shared.dataTask(with: link, completionHandler: { (data, response, error) in
                        if error == nil {
                            _ = UIImage.init(data: data!)
                            let user = UserProfile(bio: bio, firstName: firstname, lastName: lastname,
                                                   id: id, profilePic: link, petType: pettype, location: location)
                            completion(user)
                        }
                    }).resume()
                    
                })
            }
        })
    }
    
    
    
}
