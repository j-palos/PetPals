//
//  CardImage.swift
//  PetPals
//
//  Created by Jesus Palos on 4/1/19.
//  Copyright © 2019 PetPals.inc. All rights reserved.
//

import UIKit

class CardImage: UIImageView {

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
    lazy var imageName:String = String()
    lazy var contentView: UIImageView = {
        
        let contentView = UIImageView()
        if(imageName != "" ){
        contentView.image = UIImage(named: self.imageName)
       
        contentView.translatesAutoresizingMaskIntoConstraints = false
        contentView.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        contentView.setContentCompressionResistancePriority(.defaultLow, for: .vertical)
        contentView.clipsToBounds = true
        }
        return contentView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
//        setupView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
//        setupView()
    }
    
    func initWithName(_ name: String){
        setupView(name)
    }
    
    private func setupView(_ name:String) {
//        backgroundColor = .white
        self.imageName = name
        addSubview(contentView)
        setupLayout()
        //Clips the image and rounds the top only.
        self.layer.frame = bounds
        self.layer.cornerRadius = 70
        self.layer.masksToBounds = true
        self.clipsToBounds = true
    }
    
    private func setupLayout() {
        NSLayoutConstraint.activate([
            
            //layout contentView
            contentView.topAnchor.constraint(equalTo: topAnchor),
            contentView.bottomAnchor.constraint(equalTo: bottomAnchor),
            contentView.leadingAnchor.constraint(equalTo: leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: trailingAnchor)
            ])
    }

    override class var requiresConstraintBasedLayout: Bool {
        return true
    }
}
