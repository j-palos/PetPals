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
