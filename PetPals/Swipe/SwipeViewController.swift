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

class user {}

private let frameAnimationSpringBounciness: CGFloat = 9
private let frameAnimationSpringSpeed: CGFloat = 16
private let kolodaCountOfVisibleCards = 4

class SwipeViewController: UIViewController {
    @IBOutlet var kolodaView: KolodaView!
    
    var gradientLayer: CAGradientLayer!
    var users: [UserProfile] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        kolodaView.countOfVisibleCards = kolodaCountOfVisibleCards
        kolodaView.dataSource = self
        kolodaView.delegate = self
        getUsers()
    }
   
    func createGradientLayer() {
        gradientLayer = CAGradientLayer()
        gradientLayer.frame = view.bounds
        gradientLayer.colors = [UIColor.white.cgColor, UIColor.white.cgColor, UIColor.white.cgColor, UIColor(red: 243 / 255, green: 244 / 255, blue: 248 / 255, alpha: 1.0).cgColor]
        gradientLayer.zPosition = -1
        view.layer.addSublayer(gradientLayer)
    }
    
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
    
    func getUsers() {
        if let id = Auth.auth().currentUser?.uid {
            UserProfile.getAllUsers(exceptID: id, completion: { user in
                DispatchQueue.main.async {
                    self.users.append(user)
                    self.kolodaView.reloadData()
                }
            })
        }
    }
}

extension SwipeViewController: KolodaViewDataSource {
    func koloda(_ koloda: KolodaView, viewForCardAt index: Int) -> UIView {
        let card: CardView = CardView()
        let user = users[index]
        card.initWithURL(user.imageURL.absoluteString)
        card.setName(user.firstName, user.lastName)
        card.setBio(bio: user.bio)
        card.setPetType(user.petType)
        card.setDistance("3 miles")
        return card
    }
    
    func kolodaNumberOfCards(_ koloda: KolodaView) -> Int {
        return users.count
    }
}

extension SwipeViewController: KolodaViewDelegate {
    func koloda(_ koloda: KolodaView, didSwipeCardAt index: Int, in direction: SwipeResultDirection) {
//        print("\(images[index]) in the \(direction)")
    }
    
    func kolodaDidRunOutOfCards(_ koloda: KolodaView) {
        kolodaView.resetCurrentCardIndex()
    }
    
    func koloda(kolodaBackgroundCardAnimation koloda: KolodaView) -> POPPropertyAnimation? {
        let animation = POPSpringAnimation(propertyNamed: kPOPViewFrame)
        animation?.springBounciness = frameAnimationSpringBounciness
        animation?.springSpeed = frameAnimationSpringSpeed
        return animation
    }
}
