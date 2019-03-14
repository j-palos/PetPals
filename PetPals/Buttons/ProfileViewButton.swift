//
//  ProfileViewButton.swift
//  PetPals
//
//  Created by Gerardo Mares on 3/13/19.
//  Copyright © 2019 PetPals.inc. All rights reserved.
//

import UIKit

class ProfileViewButton: UIButton {

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
    
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.addTarget(self, action: #selector(buttonAction(_:)), for: .touchUpInside)
    }

    @objc func buttonAction(_ sender:UIButton!)
    {
        
        print("Button tapped")
    }
    
    required init?(coder aDecoder: NSCoder) {
        // set myValue before super.init is called

        super.init(coder: aDecoder)
        //        layer.cornerRadius = 25
    }

}
