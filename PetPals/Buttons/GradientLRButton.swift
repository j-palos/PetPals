//
//  GradientBlueButton.swift
//  PetPals
//
//  Created by Gerardo Mares on 3/12/19.
//  Copyright © 2019 PetPals.inc. All rights reserved.
//

import UIKit

@IBDesignable
class GradientLRButton: UIButton {
    
    let gradientLayer = CAGradientLayer()
    
    @IBInspectable
    var leftGradientColor: UIColor? {
        didSet {
            setGradient(leftGradientColor: leftGradientColor, rightGradientColor: rightGradientColor)
        }
    }
    
    @IBInspectable
    var rightGradientColor: UIColor? {
        didSet {
            setGradient(leftGradientColor: leftGradientColor, rightGradientColor: rightGradientColor)
        }
    }
    
    private func setGradient(leftGradientColor: UIColor?, rightGradientColor: UIColor?) {
        if let leftGradientColor = leftGradientColor, let rightGradientColor = rightGradientColor {

            gradientLayer.frame = bounds
            gradientLayer.colors = [leftGradientColor.cgColor, rightGradientColor.cgColor]
            gradientLayer.borderColor = layer.borderColor
            gradientLayer.borderWidth = layer.borderWidth
            gradientLayer.cornerRadius = layer.cornerRadius
            
            gradientLayer.startPoint = CGPoint(x: 0.0, y: 0.5)
            gradientLayer.endPoint = CGPoint(x: 1.0, y: 0.5)
            
            layer.insertSublayer(gradientLayer, at: 0)
        } else {
            gradientLayer.removeFromSuperlayer()
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        // set myValue before super.init is called
    
        super.init(coder: aDecoder)
        layer.cornerRadius = 25
    }

}
