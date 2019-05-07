//
//  AppDelegate.swift
//  PetPals
//
//  Created by Jesus Palos on 2/26/19.
//  Copyright © 2019 PetPals.inc. All rights reserved.
//

import CoreData
import CoreLocation
import Firebase
import GeoFire
import GoogleSignIn
import UIKit

let mainVCAfterAuthIdentifier = "Home"
let createProfileVCIdenfifier = "CreateProfile"

// global user profile
var profile: UserProfile?

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, GIDSignInDelegate {
    var window: UIWindow?
    private let manager = CLLocationManager()
    
    private func configureLocationManager() {
        if #available(iOS 9.0, *) {
            manager.allowsBackgroundLocationUpdates = false
        } else {
            // Fallback on earlier versions
        }
        manager.desiredAccuracy = kCLLocationAccuracyBest
        manager.distanceFilter = kCLDistanceFilterNone
        manager.pausesLocationUpdatesAutomatically = false
        manager.delegate = self
        manager.requestWhenInUseAuthorization()
    }
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        FirebaseApp.configure()
        configureLocationManager()
        // Give time for the load animation to occur, then set up firebase & check if user logged in
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.5) {
            GIDSignIn.sharedInstance().clientID = FirebaseApp.app()?.options.clientID
            GIDSignIn.sharedInstance().delegate = self
            if let user = Auth.auth().currentUser {
                UserProfile.checkIfProfileCreated(forUserWithId: user.uid) { error, startVC in
                    if error == nil {
                        self.window?.rootViewController = startVC
                        UserDefaults.standard.set(user.uid, forKey: "user_uid")
                    }
                }
            } else {
                // Go to login screen if not logged in (prevents from staying on animation)
                let storyBoard: UIStoryboard = UIStoryboard(name: "Initial", bundle: nil)
                self.window?.rootViewController = storyBoard.instantiateInitialViewController()
            }
        }
        if let tabBarController = self.window!.rootViewController as? UITabBarController {
            tabBarController.selectedIndex = 2
        }
        return true
    }
    
    func application(_ application: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey: Any]) -> Bool {
        return GIDSignIn.sharedInstance().handle(url,
                                                 // added exclamation mark
                                                 sourceApplication: String(describing: options[UIApplication.OpenURLOptionsKey.sourceApplication]!),
                                                 annotation: options[UIApplication.OpenURLOptionsKey.annotation])
    }
    
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
        if let err = error {
            print("failed to log into Google: ", err.localizedDescription)
            return
        }
        
        print("successfully logged into Google", user)
        guard let idToken = user.authentication.idToken else { return }
        guard let accessToken = user.authentication.accessToken else { return }
        let credentials = GoogleAuthProvider.credential(withIDToken: idToken, accessToken: accessToken)
        
        UserProfile.loginUser(withCredentials: credentials) { error, startVC in
            if error == nil {
                self.window?.rootViewController = startVC
            }
        }
    }
    
    func sign(_ signIn: GIDSignIn!, didDisconnectWith user: GIDGoogleUser!, withError error: Error!) {
        // Perform any operations when the user disconnects from app here.
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        configureLocationManager()
        
        // load user profile
        if let id = Auth.auth().currentUser?.uid {
            UserProfile.getProfile(forUserID: id, completion: { user in
                profile = user
            })
        }
        
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        // Saves changes in the application's managed object context before the application terminates.
        saveContext()
    }
    
    // MARK: - Core Data stack
    
    lazy var persistentContainer: NSPersistentContainer = {
        /*
         The persistent container for the application. This implementation
         creates and returns a container, having loaded the store for the
         application to it. This property is optional since there are legitimate
         error conditions that could cause the creation of the store to fail.
         */
        let container = NSPersistentContainer(name: "PetPals")
        container.loadPersistentStores(completionHandler: { _, error in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                
                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()
    
    // MARK: - Core Data Saving support
    
    func saveContext() {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
}

extension AppDelegate: CLLocationManagerDelegate {
    // if the user changed the authorization for getting location get it
    public func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if (status == .authorizedAlways) || (status == .authorizedWhenInUse) {
            manager.startUpdatingLocation()
        }
    }
    
    public func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Location Error:\(error.localizedDescription)")
    }
    
    // when location is updated, store it in user defaults
    public func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let updatedLocation: CLLocation = locations.first!
        let newCoordinate: CLLocationCoordinate2D = updatedLocation.coordinate
        let usrDefaults: UserDefaults = UserDefaults.standard
        
        // location has changed so we should update geofire
        let geoFire = GeoFire(firebaseRef: Database.database().reference().child("Geolocations"))
        if let uid = UserDefaults.standard.string(forKey: "user_uid") {
            // make sure we have users uid to update
            let location = CLLocation(latitude: newCoordinate.latitude, longitude: newCoordinate.longitude)
            geoFire.setLocation(location, forKey: uid)
        }
        usrDefaults.set("\(newCoordinate.latitude)", forKey: "current_latitude")
        usrDefaults.set("\(newCoordinate.longitude)", forKey: "current_longitude")
        usrDefaults.synchronize()
    }
}
