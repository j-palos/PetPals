//
//  SwipeViewController.swift
//  PetPals
//
//  Created by Jesus Palos on 3/25/19.
//  Copyright © 2019 PetPals.inc. All rights reserved.
//

import FirebaseAuth
import Koloda
import pop
import UIKit
import GeoFire
import FirebaseDatabase

private let frameAnimationSpringBounciness: CGFloat = 9
private let frameAnimationSpringSpeed: CGFloat = 16
private let kolodaCountOfVisibleCards = 4

class SwipeViewController: UIViewController {
    @IBOutlet var kolodaView: KolodaView!

    var gradientLayer: CAGradientLayer!
    var users: [UserProfile] = []
    @IBOutlet weak var noButton: UIButton!
    @IBOutlet weak var yesButton: UIButton!
    
    var profile: UserProfile?
    
    //for getting users locations
    var geoFireRef: DatabaseReference?
    var geoFire: GeoFire?
    var geoQuery: GFQuery?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        kolodaView.countOfVisibleCards = kolodaCountOfVisibleCards
        kolodaView.dataSource = self
        kolodaView.delegate = self
        
        geoFireRef = Database.database().reference().child("Geolocations")
        geoFire = GeoFire(firebaseRef: geoFireRef!)

        if let id = Auth.auth().currentUser?.uid {
            UserProfile.getProfile(forUserID: id, completion: { user in
                self.profile = user
            })
        }
        
        getUsers()
        
        //If the user defaults changed, then reload the users data to mactch the changes
        NotificationCenter.default.addObserver(self, selector: #selector(getUsers), name: UserDefaults.didChangeNotification, object: nil)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        geoQuery?.removeAllObservers()
    }

    // Create the gradient we want for our background
    func createGradientLayer() {
        gradientLayer = CAGradientLayer()
        gradientLayer.frame = view.bounds
        gradientLayer.colors = [UIColor.white.cgColor, UIColor.white.cgColor, UIColor.white.cgColor, UIColor(red: 243 / 255, green: 244 / 255, blue: 248 / 255, alpha: 1.0).cgColor]
        gradientLayer.zPosition = -2
        //let cards slide over the buttons
        yesButton.layer.zPosition = -1
        noButton.layer.zPosition = -1
        view.layer.addSublayer(gradientLayer)
    }

    // All this is doing is setting our background layer gradient
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        createGradientLayer()
    }

    @IBAction func noButtonTapped(_ sender: Any) {
        kolodaView.swipe(.left)
    }

    @IBAction func yesButtonTapped(_ sender: Any) {
        kolodaView.swipe(.right)
    }

    // Retrieve users within the desired radius of the user
    //todo: need to add withinMileRadius from userDefaults
   @objc func getUsers() {
    
        //Make sure that user location saved first before getting users
        if  let lat = UserDefaults.standard.value(forKey: "current_latitude") as? String,
            let lon = UserDefaults.standard.value(forKey: "current_longitude") as? String {
        
            // get our location
            // clearing phone removes
            //todo: move storing location to login and not signup
            let location: CLLocation = CLLocation(latitude: CLLocationDegrees(Double(lat)!), longitude: CLLocationDegrees(Double(lon)!))
            //We want users within the specified radius
            //if user hasn't specified a dearch radius set to 5 initially?
            let searchRadius = UserDefaults.standard.value(forKey: "distance") as? Double ?? 5.0
            //search radius is in miles but geofire takes in KM so convert from miles to KM
            let radiusInKM = searchRadius * 1.60934
            geoQuery = geoFire!.query(at: location, withRadius: radiusInKM)
            users.removeAll()
            kolodaView.reloadData()
            UserProfile.getAllUsersWithinRadius(geoQuery: geoQuery, withinMileRadius: searchRadius, completion: {
                user in DispatchQueue.main.async {
                    self.users.append(user)
                    //todo: change this to in completion
                    self.kolodaView.reloadData()
                }
            })
            
        }
    
    }
}

extension SwipeViewController: KolodaViewDataSource {
    // Generates a stack of user cards
    func koloda(_ koloda: KolodaView, viewForCardAt index: Int) -> UIView {
        let card: CardView = CardView()
        let user = users[index]
        card.initWithURL(user.imageURL.absoluteString)
        card.setName(user.firstName, user.lastName)
        card.setBio(bio: user.bio)
        card.setPetType(user.petType)
        card.setDistance(String(UserProfile.getDistanceInMiles(fromUsersLocation: user.location!)))
        return card
    }

    // set number of cards to the number of users
    func kolodaNumberOfCards(_ koloda: KolodaView) -> Int {
        return users.count
    }
}

extension SwipeViewController: KolodaViewDelegate {
    // This function will handle the swiping/network interaction
    func koloda(_ koloda: KolodaView, didSwipeCardAt index: Int, in direction: SwipeResultDirection) {
        //  print("\(images[index]) in the \(direction)")
        
        let user = users[index]
        if let profile = profile {
            switch direction {
            case .left:
                profile.swipeLeft(onUserProfile: user)
            case .right:
                profile.swipeRight(onUserProfile: user)
            default:
                print("User swiped neither left or right")
            }
        }
        
    }

    // for now, we reset the cards so we can tests better
    func kolodaDidRunOutOfCards(_ koloda: KolodaView) {
        getUsers()
    }

    // This is just the animation for background card
    func koloda(kolodaBackgroundCardAnimation koloda: KolodaView) -> POPPropertyAnimation? {
        let animation = POPSpringAnimation(propertyNamed: kPOPViewFrame)
        animation?.springBounciness = frameAnimationSpringBounciness
        animation?.springSpeed = frameAnimationSpringSpeed
        return animation
    }
}
