//
//  MatchesViewController.swift
//  PetPals
//
//  Created by Georgina Garza on 3/19/19.
//  Copyright © 2019 PetPals.inc. All rights reserved.
//

import UIKit
import FirebaseAuth
import PromiseKit

// promise function for obtaining our match image
func matchPicture(url: URL) -> Promise<UIImage> {
    return firstly {
        URLSession.shared.dataTask(.promise, with: url)
        }.compactMap {
            UIImage(data: $0.data)
    }
}

func getMatches() {
    profile!.getMatches(completion: { (match) in
        DispatchQueue.main.async {
            // Only add the match if it's not already in global
            if !matchIDs.contains(match.id) {
                matchIDs.insert(match.id)
                // Create a blank Match Image
                let matchImage = MatchesImage(frame: CGRect(x: 0, y: 0, width: 55, height: 55))
                // Perform promise to ensure picture gets loaded properly
                matchPicture(url: match.imageURL).done{
                    matchImage.setMatchesImage(image: $0)
                    matches[match.id] =  (match, matchImage)
                } .catch { _ in
                    print("I resulted in an error")
                }
            }
        }
    })
}

class MatchesViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {
    
    // Connect the various views
    @IBOutlet weak var connectedContainerView: UIView!
    @IBOutlet weak var invitesContainerView: UIView!
    @IBOutlet weak var pendingContainerView: UIView!
    
    // Connect the buttons to lead to other views
    @IBOutlet weak var connectedButton: UIButton!
    @IBOutlet weak var invitesButton: UIButton!
    @IBOutlet weak var pendingButton: UIButton!
    
    // Label for when there are no matches
    @IBOutlet weak var noMatchAvailLabel: UILabel!
    
    // Connect the collection view for New Matches
    @IBOutlet weak var newMatchesCollectionView: UICollectionView!
    
    let queue = DispatchQueue(label: "sleepQueue", qos: .userInitiated, attributes: .concurrent)
    
    // Set colors for text
    let blueColor:UIColor = UIColor(red: 0.44, green:0.78, blue:0.78, alpha: 1)
    let grayColor:UIColor = UIColor(red: 0.78, green: 0.78, blue: 0.8, alpha: 1)
    
    // Variable to connect to Overall Matches VC
    var parentVC: OverallMatchesViewController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        getMatches()
        self.newMatchesCollectionView.reloadData()
    }
    
    // All this is doing is waiting to display none
    override func viewWillAppear(_ animated: Bool) {
        // wait for a second, if we don't have potentials show out of cards
        queue.async {
            sleep(1)
            if matches.isEmpty {
                DispatchQueue.main.async {
                    self.checkIfNoMatches()
                }
            }
        }
        newMatchesCollectionView.reloadData()
    }
    
    // Required function for CollectionView; New Matches row should have same number as new match users
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        checkIfUpdate()
        return matches.count
    }
    
    // Required function for CollectionView
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        // Get this cell
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "newMatchCollectionViewCell", for: indexPath) as! NewMatchCollectionViewCell
    
        // Find the associated User
        let userID:String = Array(matches.keys)[indexPath.row]
        let (user, userImage):(UserProfile, MatchesImage) = matches[userID]!

        
        // Update the cell information with this user's info
        cell.nameLabel.text = user.firstName
        cell.image.image = userImage.image
        
        return cell as UICollectionViewCell
    }
    
    // If a new match is selected, bring up the Meetup Screen
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        // Get this cell
        let _:NewMatchCollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: "newMatchCollectionViewCell", for: indexPath) as! NewMatchCollectionViewCell
        
        // Destination will be Meetup Screen, child of OverallMatchesVC
        // Need destination to be loaded first to be able to send data
        let destination = self.storyboard!.instantiateViewController(withIdentifier: "meetupVCIdentifier") as! MeetupViewController
        
        // Find the associated User
        let userID:String = Array(matches.keys)[indexPath.row]
        let (user, userImage):(UserProfile, MatchesImage) = matches[userID]!
        
        // Send over information about the user selected
        destination.userProfile = user
        destination.userName = user.firstName
        destination.userImage = userImage
        
        // Present the screen
        self.navigationController?.pushViewController(destination, animated: false)
    }
    
    // If connected is clicked, show that view
    @IBAction func connectedButtonPressed(_ sender: Any) {
        if invitesContainerView.alpha == 1 {
            // If came from invites, connected data needs to be updated
            // Since can't share infomration between views of same parent VC, just reload this VC
            let destination = self.storyboard!.instantiateViewController(withIdentifier: "MatchesVC") as! MatchesViewController
            
            // Present the screen
            self.navigationController?.pushViewController(destination, animated: false)
        }
        
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
    
    // If there are no matches, do not show collection view but instead label
    // If there are now matches, show collection view and hide label
    func checkIfNoMatches() {
        if matches.count == 0 {
            newMatchesCollectionView.alpha = 0
            noMatchAvailLabel.alpha = 1
        } else {
            newMatchesCollectionView.alpha = 1
            noMatchAvailLabel.alpha = 0
        }
    }
    
    func checkIfUpdate() {
        if noMatchAvailLabel.alpha == 1 {
            if matches.count > 0 {
                noMatchAvailLabel.alpha = 0
            }
        }
    }
    
}

