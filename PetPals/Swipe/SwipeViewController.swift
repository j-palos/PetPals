//
//  SwipeViewController.swift
//  PetPals
//
//  Created by Jesus Palos on 3/25/19.
//  Copyright © 2019 PetPals.inc. All rights reserved.
//

import UIKit
import Koloda
import pop
import FirebaseAuth

var count = 3

var images = ["parrot.png","charles","chris"]


class user {
    
}
private let frameAnimationSpringBounciness: CGFloat = 9
private let frameAnimationSpringSpeed: CGFloat = 16
private let kolodaCountOfVisibleCards = 2

class SwipeViewController: UIViewController {
    
    @IBOutlet weak var kolodaView: KolodaView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        kolodaView.countOfVisibleCards = kolodaCountOfVisibleCards
        kolodaView.dataSource = self
        kolodaView.delegate = self
        getUsers()
    }
    
    var users:[UserProfile] = []
    
    
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    @IBAction func noButtonTapped(_ sender: Any) {
        kolodaView.swipe(.left)
        
    }
    
    @IBAction func yesButtonTapped(_ sender: Any) {
        kolodaView.swipe(.right)
    }
    
    func getUsers()  {
        if let id = Auth.auth().currentUser?.uid {
            UserProfile.getAllUsers(exceptID: id, completion: { (user) in
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
        let cardView: CardView = CardView()
//        cardView.initWithName(images[index])
        let user = users[index]
        cardView.initWithName(user.imageURL.absoluteString)
        cardView.setName(user.firstName, user.lastName)
        cardView.setBio(bio: user.bio)
        cardView.setPetType(user.petType)
        cardView.setDistance("3 miles")
        return cardView
    }
    
    func kolodaNumberOfCards(_ koloda: KolodaView) -> Int {
        return users.count
    }
}

extension SwipeViewController : KolodaViewDelegate {
    
    func koloda(_ koloda: KolodaView, didSwipeCardAt index: Int, in direction: SwipeResultDirection){
        print("\(images[index]) in the \(direction)")
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
