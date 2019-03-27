//
//  CardView.swift
//  PetPals
//
//  Created by Jesus Palos on 3/26/19.
//  Copyright © 2019 PetPals.inc. All rights reserved.
//

import UIKit

@IBDesignable
class CardView: UIView {

    let kCONTENT_XIB_NAME = "CardView"
    @IBOutlet  var bioLabel: UILabel!
    @IBOutlet  var nameLabel: UILabel!
    @IBOutlet  var distanceLabel: UILabel!
    @IBOutlet  var cardImage: UIImageView!
    @IBOutlet  var petTypeLabel: UILabel!
    
    //vars to set up the view
    var name = String()
    var petType = String()
    var bio = String()
    var distance = String()
    var image: UIImage
    
    var view: UIView!
    override init(frame: CGRect) {
        self.image = UIImage(named: "cards_1")!
//        name = "name"
//        distanceLabel.text = "distance stuff"
//        nameLabel.text =  "name stuff"
////                self.cardImage = UIImageView(image : UIImage(named: "cards_1"))
        super.init(frame: frame)
        loadViewFromNib()
    }
    
    required init?(coder aDecoder: NSCoder) {
        self.image = UIImage(named: "cards_1")!
        super.init(coder: aDecoder)
        loadViewFromNib()
        
    }
    
    func commonInit() {
        Bundle.main.loadNibNamed(kCONTENT_XIB_NAME, owner: self, options: nil)
//        contentView.fixInView(self)
        image = UIImage(named: "cards_1")!
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
        //fix this image
//        image = UIImage(named: "cards_2")!
        self.distanceLabel.text = "distance stuff"
        self.nameLabel.text =  "name stuff"
        let cardmage = UIImageView(image : UIImage(named: "cards_1"))
        cardmage.contentMode = .scaleAspectFit
        addSubview(view)
        self.view = view
        addSubview(cardmage)
        
//        self.cardImage  = cardmage
//        self.view.addSubview(self.cardImage)
//        self.view.addSubview(cardImage)
//        self.view.addSubview(cardImage)
//        return view
        
    }
    
    func CardView(){
            self.commonInit()
    }
    
    override func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()
        layer.borderColor = borderColor?.cgColor
        layer.borderWidth = borderWidth
        layer.cornerRadius = cornerRadius
    }
    
    @IBInspectable var borderColor: UIColor? {
        didSet {
            layer.borderColor = borderColor?.cgColor
            setNeedsLayout()
        }
    }
    
    @IBInspectable var borderWidth: CGFloat = 0.0 {
        didSet {
            layer.borderWidth = borderWidth
            setNeedsLayout()
        }
    }
    
    @IBInspectable var cornerRadius: CGFloat = 0.0 {
        didSet {
            layer.cornerRadius = cornerRadius
            setNeedsLayout()
        }
    }
    
    
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}

extension UIView
{
    func fixInView(_ container: UIView!) -> Void{
        self.translatesAutoresizingMaskIntoConstraints = false;
        self.frame = container.frame;
        container.addSubview(self);
        NSLayoutConstraint(item: self, attribute: .leading, relatedBy: .equal, toItem: container, attribute: .leading, multiplier: 1.0, constant: 0).isActive = true
        NSLayoutConstraint(item: self, attribute: .trailing, relatedBy: .equal, toItem: container, attribute: .trailing, multiplier: 1.0, constant: 0).isActive = true
        NSLayoutConstraint(item: self, attribute: .top, relatedBy: .equal, toItem: container, attribute: .top, multiplier: 1.0, constant: 0).isActive = true
        NSLayoutConstraint(item: self, attribute: .bottom, relatedBy: .equal, toItem: container, attribute: .bottom, multiplier: 1.0, constant: 0).isActive = true
    }
}
