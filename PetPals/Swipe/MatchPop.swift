//
//  MatchPop.swift
//  PetPals
//
//  Created by Jesus Palos on 4/24/19.
//  Copyright © 2019 PetPals.inc. All rights reserved.
//

import UIKit

class MatchPop: UIView {
    @IBOutlet var myImage: UIImageView!
    @IBOutlet var theirImage: UIImageView!
    var view : UIView = UIView()
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.loadViewFromNib()
    }
    
    @IBOutlet weak var dismissButton: UIButton!
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.loadViewFromNib()
    }
    
    func commonInit() {
        Bundle.main.loadNibNamed("MatchPop", owner: self, options: nil)
    }
    
    func loadViewFromNib() {
        let bundle = Bundle(for: type(of: self))
        let nib = UINib(nibName: String(describing: type(of: self)), bundle: bundle)
        let view = nib.instantiate(withOwner: self, options: nil).first as! UIView
        view.frame = bounds
        view.autoresizingMask = [
            UIView.AutoresizingMask.flexibleWidth,
            UIView.AutoresizingMask.flexibleHeight
        ]
        self.view = view
        self.addSubview(view)
        
        let buttonX = 150
        let buttonY = 150
        let buttonWidth = 100
        let buttonHeight = 50
        
        let button = UIButton(type: .system)
        button.setTitle("Click here", for: .normal)
        button.tintColor = .white
        button.backgroundColor = .red
        button.addTarget(self, action: #selector(buttonClicked), for: .touchUpInside)
        
        button.frame = CGRect(x: buttonX, y: buttonY, width: buttonWidth, height: buttonHeight)
        
        self.view.addSubview(button)
        self.view.addSubview(dismissButton)
        self.view.bringSubviewToFront(dismissButton)
    }
    
    @objc func buttonClicked(sender : UIButton){
        UIView.animate(
            withDuration: 1.0,
            delay: 0.0,
            options: .curveEaseOut,
            animations: {
                self.alpha = 0.0
        }
        )
        self.removeFromSuperview()
    }
    
    
    
    @IBAction func dismissButton(_ sender: Any) {
        
        
        UIView.animate(
            withDuration: 1.0,
            delay: 0.0,
            options: .curveEaseOut,
            animations: {
                self.alpha = 0.0
        }
        )
        self.removeFromSuperview()
    }
    
    func setImages(myImage: UIImage, theirImage: UIImage) {
        let mimage: UIImage = myImage.scaleToSize(aSize: CGSize(width: 145.0, height: 145.0))
        let timage: UIImage = theirImage.scaleToSize(aSize: CGSize(width: 145.0, height: 145.0))
        self.myImage.image = mimage
        self.theirImage.image = timage
        self.myImage.layer.cornerRadius = self.myImage.frame.size.width / 2
        self.myImage.clipsToBounds = true
        self.theirImage.layer.cornerRadius = self.myImage.frame.size.width / 2
        self.theirImage.clipsToBounds = true
        setStyles()
    }
    
    func setStyles() {
        self.myImage.layer.borderWidth = 5.0
        self.myImage.layer.borderColor = UIColor(named: "PetPalYellow")?.cgColor
        self.theirImage.layer.borderWidth = 5.0
        self.theirImage.layer.borderColor = UIColor(named: "PetPalYellow")?.cgColor
    }
}
