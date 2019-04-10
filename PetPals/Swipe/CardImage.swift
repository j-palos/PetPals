//
//  CardImage.swift
//  PetPals
//
//  Created by Jesus Palos on 4/1/19.
//  Copyright © 2019 PetPals.inc. All rights reserved.
//

import UIKit

// This is a custom UIImageView class for
// populating our swipe cards with images from the user database
class CardImage: UIImageView {
    override init(image: UIImage?) {
        super.init(image: image)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    // This handles the graphics of the card, scaling the pictures, and clipping it to
    //the rounding
    override func layoutSubviews() {
        super.layoutSubviews()
        // These values must be hardcoded
        self.image = self.image?.scaleToSize(aSize: CGSize(width: 350, height: 350))
        self.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        self.clipsToBounds = true
        self.layer.frame = bounds
        self.layer.cornerRadius = 10.0
        self.layer.masksToBounds = true
    }
    
    // Loads our pictures for each card from the url passed in
    func load(fromURL url: URL) {
        // shows a loading animation while image is downloaded from url
        let activityIndicator = UIActivityIndicatorView(style: UIActivityIndicatorView.Style.gray)
        activityIndicator.startAnimating()
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        let leftSpaceConstraint = NSLayoutConstraint(item: activityIndicator, attribute: NSLayoutConstraint.Attribute.centerX, relatedBy: NSLayoutConstraint.Relation.equal, toItem: self, attribute: NSLayoutConstraint.Attribute.centerX, multiplier: 1, constant: 0)
        
        let widthConstraint = NSLayoutConstraint(item: activityIndicator, attribute: NSLayoutConstraint.Attribute.width, relatedBy: NSLayoutConstraint.Relation.equal, toItem: nil, attribute: NSLayoutConstraint.Attribute.notAnAttribute, multiplier: 1, constant: 20)
        
        let heightConstraint = NSLayoutConstraint(item: activityIndicator, attribute: NSLayoutConstraint.Attribute.height, relatedBy: NSLayoutConstraint.Relation.equal, toItem: nil, attribute: NSLayoutConstraint.Attribute.notAnAttribute, multiplier: 1, constant: 20)
        self.addSubview(activityIndicator)
        self.addConstraints([leftSpaceConstraint, widthConstraint, heightConstraint])
        
        // download image in a new async thread
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            if let data = try? Data(contentsOf: url) {
                if let image = UIImage(data: data) {
                    DispatchQueue.main.async {
                        activityIndicator.stopAnimating()
                        self?.image = image
                    }
                }
            }
        }
    }
}
