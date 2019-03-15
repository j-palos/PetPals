//
//  ProfileViewButton.swift
//  PetPals
//
//  Created by Gerardo Mares on 3/13/19.
//  Copyright © 2019 PetPals.inc. All rights reserved.
//

import UIKit

class ProfileViewButton: UIButton {
}

extension UIView {
    func findViewController() -> UIViewController? {
        if let nextResponder = self.next as? UIViewController {
            return nextResponder
        } else if let nextResponder = self.next as? UIView {
            return nextResponder.findViewController()
        } else {
            return nil
        }
    }
}


