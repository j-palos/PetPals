//
//  ProfileViewController.swift
//  PetPals
//
//  Created by Sabrina Herrero on 3/27/19.
//  Copyright © 2019 PetPals.inc. All rights reserved.
//

import UIKit
import FirebaseAuth

class ProfileViewController: UIViewController {
    
    @IBOutlet weak var profilePicture: ProfileImageView!
    @IBOutlet weak var profileName: UILabel!
    @IBOutlet weak var profilePetType: UILabel!
    @IBOutlet weak var profileBio: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.profilePicture.layer.zPosition = -1
        self.profilePicture.layer.cornerRadius = self.profilePicture.frame.size.width / 2;
        self.profilePicture.clipsToBounds = true
        let usrDefaults: UserDefaults = .standard
        if let url = usrDefaults.url(forKey: "profile_image") {
            profilePicture.load(fromURL: url)
        }

        if let id = Auth.auth().currentUser?.uid {
            UserProfile.getProfile(forUserID: id, completion: { (user) in
                DispatchQueue.main.async {
                    self.profileName.text = user.firstName
                    self.profilePetType.text = user.petType
                    self.profileBio.text = user.bio
                }
            })
        }
    }
}
