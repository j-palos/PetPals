//
//  CardView.swift
//  PetPals
//
//  Created by Jesus Palos on 3/26/19.
//  Copyright © 2019 PetPals.inc. All rights reserved.
//

import UIKit

@IBDesignable
// Custom UIView class that handles making our actual swipe cards
class CardView: UIView {
    let kCONTENT_XIB_NAME = "CardView"
    
    // Outlet Variables
    @IBOutlet var nameLabel: UILabel!
    @IBOutlet var distanceLabel: UILabel!
    @IBOutlet var cardImage: CardImage!
    @IBOutlet var petTypeLabel: UILabel!
    @IBOutlet var bioBox: UITextView!
    
    // vars to set up the view
    var name = String()
    var petType = String()
    var bio = String()
    var distance = String()
    var view: UIView!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        loadViewFromNib()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        loadViewFromNib()
    }
    
    func commonInit() {
        Bundle.main.loadNibNamed(kCONTENT_XIB_NAME, owner: self, options: nil)
    }
    
    // loads a new instance of our CardView xib
    func loadViewFromNib() {
        let bundle = Bundle(for: type(of: self))
        let nib = UINib(nibName: String(describing: type(of: self)), bundle: bundle)
        let view = nib.instantiate(withOwner: self, options: nil).first as! UIView
        view.frame = bounds
        view.autoresizingMask = [
            UIView.AutoresizingMask.flexibleWidth,
            UIView.AutoresizingMask.flexibleHeight
        ]
        cardImage.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        // set corner radius
        view.layer.cornerRadius = 10.0
        // set the shadow properties
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOffset = CGSize(width: 1, height: 2.0)
        layer.shadowOpacity = 0.5
        // shadow radius should be same as corner radius
        layer.shadowRadius = 10.0
        addSubview(view)
        self.view = view
    }
    
    func setBio(bio: String) {
        bioBox.text = "Bio: \(bio)"
    }
    
    func setName(_ first: String, _ second: String) {
        nameLabel.text = "\(first)"
        nameLabel.sizeToFit()
    }
    
    func setDistance(_ distance: String) {
        distanceLabel.text = "\(distance) Miles Away"
        distanceLabel.sizeToFit()
    }
    
    func setPetType(_ type: String) {
        petTypeLabel.text = "\(type)"
    }
    
    func initWithURL(_ name: String) {
        cardImage.load(fromURL: URL(string: name)!)
    }
    
    func setImage(_ pic: UIImage) {
        cardImage.image = pic
    }
}
