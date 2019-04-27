//
//  SwipeViewController.swift
//  PetPals
//
//  Created by Jesus Palos on 3/25/19.
//  Copyright © 2019 PetPals.inc. All rights reserved.
//

import FirebaseAuth
import FirebaseDatabase
import GeoFire
import Koloda
import pop
import PromiseKit
import UIKit

private let frameAnimationSpringBounciness: CGFloat = 9
private let frameAnimationSpringSpeed: CGFloat = 16
private let kolodaCountOfVisibleCards = 4

class SwipeViewController: UIViewController {
    @IBOutlet var kolodaView: KolodaView!

    var gradientLayer: CAGradientLayer!
    var users: [UserProfile] = []
    @IBOutlet var noButton: UIButton!
    @IBOutlet var yesButton: UIButton!
    var theirImage: UIImage = UIImage()
    var myImage: UIImage = UIImage()
    @IBOutlet var outOfProfilesImageView: UIImageView!

    var profile: UserProfile?
    let queue = DispatchQueue(label: "sleepQueue", qos: .userInitiated, attributes: .concurrent)
    // for getting users locations
    var geoFireRef: DatabaseReference?
    var geoFire: GeoFire?
    var geoQuery: GFCircleQuery?

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
                self.popMatchUp(user: user)
            })
        }

        // initially don't show that
        removeOutOfCards()
        // startup the user gathering

        getUsers()

        // set self as observer for user defaults needed for getting users
        UserDefaults.standard.addObserver(self, forKeyPath: "current_latitude", options: .new, context: nil)
        UserDefaults.standard.addObserver(self, forKeyPath: "current_longitude", options: .new, context: nil)
        UserDefaults.standard.addObserver(self, forKeyPath: "distance", options: .new, context: nil)
        UserDefaults.standard.addObserver(self, forKeyPath: "petTypes", options: .new, context: nil)
    }

    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey: Any]?, context: UnsafeMutableRawPointer?) {
        if object is UserDefaults {
            // Here you can grab the values or just respond to it with an action.
            switch keyPath {
            case "current_latitude", "current_longitude":
                // users location updated so refresh the users based on that
                geoQuery?.removeAllObservers()
                getUsers()

            case "distance":
                // updated the search radius so refresh the users based on that
                geoQuery?.removeAllObservers()
                getUsers()
            case "petTypes":
                // pet type was changed so we need to kill all observers and create new one with updated pets
                geoQuery?.removeAllObservers()
                getUsers()
            default: break
            }
        }
    }

    override func viewDidDisappear(_ animated: Bool) {
        // geoQuery?.removeAllObservers()
    }

    // Create the gradient we want for our background
    func createGradientLayer() {
        gradientLayer = CAGradientLayer()
        gradientLayer.frame = view.bounds
        gradientLayer.colors = [UIColor.white.cgColor, UIColor.white.cgColor, UIColor.white.cgColor, UIColor(red: 243 / 255, green: 244 / 255, blue: 248 / 255, alpha: 1.0).cgColor]
        gradientLayer.zPosition = -2
        // let cards slide over the buttons
        yesButton.layer.zPosition = -1
        noButton.layer.zPosition = -1
        view.layer.addSublayer(gradientLayer)
    }

    // All this is doing is setting our background layer gradient
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        createGradientLayer()
        // wait for a second, if we don't have potentials show out of cards
        queue.async {
            sleep(1)
//            if self.users.isEmpty {
//                DispatchQueue.main.async {
//                    self.displayOutOfCards()
//                }
//            }
        }
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
        // Make sure that user location saved first before getting users
        if let lat = UserDefaults.standard.value(forKey: "current_latitude") as? String,
            let lon = UserDefaults.standard.value(forKey: "current_longitude") as? String {
            // get our location
            // clearing phone removes
            //todo: move storing location to login and not signup
            let location: CLLocation = CLLocation(latitude: CLLocationDegrees(Double(lat)!), longitude: CLLocationDegrees(Double(lon)!))
            // We want users within the specified radius
            // if user hasn't specified a dearch radius set to 5 initially?
            let searchRadius = UserDefaults.standard.value(forKey: "distance") as? Double ?? 5.0
            // search radius is in miles but geofire takes in KM so convert from miles to KM
            let radiusInKM = searchRadius * 1.60934
            geoQuery = geoFire!.query(at: location, withRadius: radiusInKM)
            users.removeAll()
            kolodaView.reloadData()
            UserProfile.getAllUsersWithinRadius(geoQuery: geoQuery, completion: {
                user in DispatchQueue.main.async {
                    self.users.append(user)
                    //todo: change this to in completion
                    if self.outOfProfilesImageView.alpha > 0 {
                        self.removeOutOfCards()
                    }
                    self.kolodaView.reloadData()
                }
            })
        }
    }

    // show the out of cards image
    private func displayOutOfCards() {
        UIView.animate(
            withDuration: 2.0,
            delay: 0.0,
            options: .curveEaseIn,
            animations: {
                self.outOfProfilesImageView.alpha = 1.0
                self.outOfProfilesImageView.layer.zPosition = 1
            }
        )
    }

    // remove the out of cards image from view
    private func removeOutOfCards() {
        outOfProfilesImageView.alpha = 0.0
        outOfProfilesImageView.layer.zPosition = -3
    }
}

extension SwipeViewController: KolodaViewDataSource {
    // Generates a stack of user cards
    func koloda(_ koloda: KolodaView, viewForCardAt index: Int) -> UIView {
        let card: CardView = CardView()
        initCard(index: index, card: card)
        return card
    }

    // wrapper function to init our card
    //the point of using promises here is
    // so that our card comes into view with an image already loaded
    func initCard(index: Int, card: CardView) {
        let user = users[index]
        card.setName(user.firstName, user.lastName)
        card.setBio(bio: user.bio)
        card.setPetType(user.petType)
        card.setDistance(String(UserProfile.getDistanceInMiles(fromUsersLocation: user.location!)))
        avatar(url: user.imageURL).done {
            card.setImage($0)
            return
        }.catch { _ in
            print("error in network")
        }
    }

    // promise function for obtaining our card avatage image
    func avatar(url: URL) -> Promise<UIImage> {
        return firstly {
            URLSession.shared.dataTask(.promise, with: url)
        }.compactMap {
            UIImage(data: $0.data)
        }
    }

    // set number of cards to the number of users
    func kolodaNumberOfCards(_ koloda: KolodaView) -> Int {
        return users.count
    }
}

extension SwipeViewController: KolodaViewDelegate {
    // This function will handle the swiping/network interaction
    func koloda(_ koloda: KolodaView, didSwipeCardAt index: Int, in direction: SwipeResultDirection) {
        let user = users[index]
        if let profile = profile {
            switch direction {
            case .left:
                profile.swipeLeft(onUserProfile: user)
            case .right:
                profile.swipeRight(onUserProfile: user) { matchMade in
                    if matchMade {
                        self.popMatchUp(user: user)
                        // a match was made
                    }
                }
            default:
                print("User swiped neither left or right")
            }
        }
    }

    // pops up the view for our new match
    private func popMatchUp(user: UserProfile) {
        removeOutOfCards()
        let pop: MatchPop = MatchPop()
        let url = UserDefaults.standard.url(forKey: "profile_image") ?? user.imageURL
        when(resolved: setMyImage(url: url), setTheirImage(url: user.imageURL)).done { _ in
            pop.setImages(myImage: self.myImage, theirImage: self.theirImage)
            pop.layer.zPosition = 3
            self.view.addSubview(pop)
            self.queue.async {
                sleep(2)
                DispatchQueue.main.async {
                    pop.removeFromSuperview()
                }
            }
        }
    }

    func setTheirImage(url: URL) -> Promise<Void> {
        return avatar(url: url).done {
            self.theirImage = $0
        }
    }

    func setMyImage(url: URL) -> Promise<Void> {
        return avatar(url: url).done {
            self.myImage = $0
        }
    }

    // for now, we reset the cards so we can tests better
    func kolodaDidRunOutOfCards(_ koloda: KolodaView) {
        displayOutOfCards()
    }

    // This is just the animation for background card
    func koloda(kolodaBackgroundCardAnimation koloda: KolodaView) -> POPPropertyAnimation? {
        let animation = POPSpringAnimation(propertyNamed: kPOPViewFrame)
        animation?.springBounciness = frameAnimationSpringBounciness
        animation?.springSpeed = frameAnimationSpringSpeed
        return animation
    }
}
