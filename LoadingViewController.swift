//
//  LoadingViewController.swift
//  PetPals
//
//  Created by Georgina Garza on 4/5/19.
//  Copyright © 2019 PetPals.inc. All rights reserved.
//

import UIKit
import CoreData
import Firebase
import GoogleSignIn

class LoadingViewController: UIViewController {
    
    @IBOutlet weak var circle: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        UIView.animate(withDuration: 4.0, animations: { () -> Void in
            let scale = CGAffineTransform(scaleX: 10.0, y: 10.0)
            self.circle.transform = scale
        }, completion: nil)
    }
}

