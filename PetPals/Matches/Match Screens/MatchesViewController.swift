//
//  MatchesViewController.swift
//  PetPals
//
//  Created by Georgina Garza on 3/19/19.
//  Copyright © 2019 PetPals.inc. All rights reserved.
//

import UIKit
import FirebaseAuth

class MatchesViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {
    
    // Connect the various views
    @IBOutlet weak var connectedContainerView: UIView!
    @IBOutlet weak var invitesContainerView: UIView!
    @IBOutlet weak var pendingContainerView: UIView!
    
    // Connect the buttons to lead to other views
    @IBOutlet weak var connectedButton: UIButton!
    @IBOutlet weak var invitesButton: UIButton!
    @IBOutlet weak var pendingButton: UIButton!
    
    // Set colors for text
    let blueColor:UIColor = UIColor(red: 0.44, green:0.78, blue:0.78, alpha: 1)
    let grayColor:UIColor = UIColor(red: 0.78, green: 0.78, blue: 0.8, alpha: 1)
    
    // Variable to connect to Overall Matches VC
    var parentVC: OverallMatchesViewController?
    
    // List to contain all new matches for this user
    var newMatches = [UserProfile]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let id = Auth.auth().currentUser?.uid {
            UserProfile.getProfile(forUserID: id, completion: { (user) in
                self.newMatches = user.getMatches()
            })
        }
    }
    
    // Required function for CollectionView; New Matches row should have same number as new match users
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        print("NUMBER OF MATCHES: \(newMatches.count)")
        return newMatches.count
    }
    
    // Required function for CollectionView
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        // Get this cell
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "newMatchCollectionViewCell", for: indexPath) as! NewMatchCollectionViewCell
        
        // Find the associated User
        let user:UserProfile = newMatches[indexPath.row]
        
        // Update the cell information with this user's info
        cell.nameLabel.text = user.firstName
        let imageUrl = UserDefaults.standard.url(forKey: "profile_image") ?? user.imageURL
        cell.image.load(fromURL: imageUrl)
        cell.image.image = cell.image.image!.scaleToSize(aSize: CGSize(width: 55.0, height: 55.0))
        
        return cell as UICollectionViewCell
    }
    
    // If a new match is selected, bring up the Meetup Screen
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        // Get this cell
        let cell:NewMatchCollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: "newMatchCollectionViewCell", for: indexPath) as! NewMatchCollectionViewCell
        
        // Destination will be Meetup Screen, child of OverallMatchesVC
        // Need destination to be loaded first to be able to send data
        let destination = self.storyboard!.instantiateViewController(withIdentifier: "meetupVCIdentifier") as! MeetupViewController
        
        // Send over information about the user selected
        destination.userName = cell.nameLabel.text!
        destination.userImage = cell.image.image!
        
        // Present the screen
        self.navigationController?.pushViewController(destination, animated: false)
    }
    
    // If connected is clicked, show that view
    @IBAction func connectedButtonPressed(_ sender: Any) {
        // Animate the connected view, and hide the others
        UIView.animate(withDuration: 0.5, animations: {
            self.connectedContainerView.alpha = 1
            self.invitesContainerView.alpha = 0
            self.pendingContainerView.alpha = 0
        })
        
        // Update the colors of text buttons accordingly
        connectedButton.setTitleColor(blueColor, for: .normal)
        invitesButton.setTitleColor(grayColor, for: .normal)
        pendingButton.setTitleColor(grayColor, for: .normal)
    }
    
    // If invites is clicked, show that view
    @IBAction func invitesButtonPressed(_ sender: Any) {
        // Animate the invites view, and hide the others
        UIView.animate(withDuration: 0.5, animations: {
            self.connectedContainerView.alpha = 0
            self.invitesContainerView.alpha = 1
            self.pendingContainerView.alpha = 0
        })
        
        // Update the colors of text buttons accordingly
        invitesButton.setTitleColor(blueColor, for: .normal)
        connectedButton.setTitleColor(grayColor, for: .normal)
        pendingButton.setTitleColor(grayColor, for: .normal)
    }
    
    // If pending is clicked, show that view
    @IBAction func pendingButtonPressed(_ sender: Any) {
        // Animate the pending view, and hide the others
        UIView.animate(withDuration: 0.5, animations: {
            self.connectedContainerView.alpha = 0
            self.invitesContainerView.alpha = 0
            self.pendingContainerView.alpha = 1
        })
        
        // Update the colors of text buttons accordingly
        pendingButton.setTitleColor(blueColor, for: .normal)
        connectedButton.setTitleColor(grayColor, for: .normal)
        invitesButton.setTitleColor(grayColor, for: .normal)
    }
    
}

