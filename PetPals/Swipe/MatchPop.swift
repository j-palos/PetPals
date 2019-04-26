//
//  MatchPop.swift
//  PetPals
//
//  Created by Jesus Palos on 4/24/19.
//  Copyright © 2019 PetPals.inc. All rights reserved.
//

import UIKit

class MatchPop: UIView {
    
    @IBOutlet weak var myImage: UIImageView!
    @IBOutlet weak var theirImage: UIImageView!
   
    override init(frame: CGRect) {
        super.init(frame: frame)
        loadViewFromNib()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        loadViewFromNib()
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
        addSubview(view)
    }
    
    
    func setImages(myImage:UIImage, theirImage:UIImage){
        self.myImage.image = myImage
        self.theirImage.image = theirImage
        setStyles()
    }
    
    func setStyles(){
        self.myImage.layer.cornerRadius = self.frame.size.height / 2
        self.myImage.clipsToBounds = true
        self.myImage.layer.masksToBounds = true
        self.myImage.layer.borderWidth = 0.50
        self.myImage.layer.borderColor = UIColor.black.cgColor
        self.theirImage.layer.cornerRadius = self.frame.size.height / 2
        self.theirImage.clipsToBounds = true
        self.theirImage.layer.masksToBounds = true
        self.theirImage.layer.borderWidth = 0.50
        self.theirImage.layer.borderColor = UIColor.black.cgColor
    }
}
