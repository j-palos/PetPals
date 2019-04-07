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
    lazy var imageName:URL = URL(string: "")!
    lazy var contentView: UIImageView = {
        
        let contentView = UIImageView()
//        if(imageName != "" ){
//        contentView.image = contentView.image!.scaleToSize(aSize: CGSize(width: 150.0, height: 150.0))
//        contentView.translatesAutoresizingMaskIntoConstraints = false
//        contentView.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
//        contentView.setContentCompressionResistancePriority(.defaultLow, for: .vertical)
//        contentView.clipsToBounds = true
        load(url: self.imageName)
//        contentView.image = contentView.image?.scaleToSize(aSize: CGSize(width: 150.0, height: 150.0))
        load(url: imageName)
        return contentView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
//        setupView()
    }
    
    func initWithName(_ url: String){
        setupView(URL(string: url)!)
    }
    
    private func setupView(_ url:URL) {
        self.imageName = url
        
        addSubview(contentView)
        
//        setupLayout()
        //Clips the image and rounds the top only.
//        self.layer.frame = bounds
//        self.layer.cornerRadius = 70
//        self.layer.masksToBounds = true
//        self.clipsToBounds = true
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

//    override class var requiresConstraintBasedLayout: Bool {
//        return true
//    }
}

extension CardImage {
    func load(url: URL) {
        DispatchQueue.global().async { [weak self] in
            if let data = try? Data(contentsOf: url) {
                if let image = UIImage(data: data) {
                    DispatchQueue.main.async {
                        self?.contentView.image = image
                    }
                }
            }
        }
    }
}
