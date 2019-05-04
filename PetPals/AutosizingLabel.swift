//
//  AutosizingLabel.swift
//  PetPals
//
//  Created by Jesus Palos on 5/2/19.
//  Copyright © 2019 PetPals.inc. All rights reserved.
//

import UIKit

class AutosizingLabel: UILabel {

    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
        self.commonInit()
        
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.commonInit()
    }
     
    func commonInit(){
//        self.adjustsFontSizeToFitWidth = true
//        self.minimumScaleFactor = CGFloat(0.5)
//        self.numberOfLines = 5
    }
}
