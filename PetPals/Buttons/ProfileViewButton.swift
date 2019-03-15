//
//  ProfileViewButton.swift
//  PetPals
//
//  Created by Gerardo Mares on 3/13/19.
//  Copyright © 2019 PetPals.inc. All rights reserved.
//

import UIKit

class ProfileViewButton: UIButton {
    /*
     // Only override draw() if you perform custom drawing.
     // An empty implementation adversely affects performance during animation.
     override func draw(_ rect: CGRect) {
     // Drawing code
     }
     */
    
    
    //    override init(frame: CGRect) {
    //        super.init(frame: frame)
    //        let btnImage = UIImage(named: "paw-colored")
    //          let button = UIButton(type: UIButton.ButtonType.system) as UIButton
    //
    //            button.setImage(btnImage , for: UIControl.State.normal)
    //
    //    }
    
    required init?(coder aDecoder: NSCoder) {
        // set myValue before super.init is called
        
        super.init(coder: aDecoder)
        //        layer.cornerRadius = 25
        let button = self as UIButton
//        button.addTarget(self, action: #selector(buttonClicked), for: .touchUpInside)
        
    }
    
//    @objc func buttonClicked(sender : UIButton){
//        //        let alert = UIAlertController(title: "Clicked", message: "You have clicked on the button", preferredStyle: .alert)
//        //        print("Here")
////
////        let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
////        let newViewController = storyBoard.instantiateViewController(withIdentifier: "ProfileVC")
////        //        let childVC = storyboard!.instantiateViewController(withIdentifier: "Child")
////        let segue = UIStoryboardSegue(identifier:  "segue", source: findViewController()!, destination: newViewController)
////        //        segue.prepare(for: segue, sender: nil)
////        segue.perform()
////        //        self.present(alert, animated: true, completion: nil)
//    }
    
    //    @objc profileClicked(sender : UIButton){
    //        let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
    //        let newViewController = storyBoard.instantiateViewController(withIdentifier: mainVCAfterAuthIdentifier)
    //        self.present(newViewController, animated: true, completion: nil)
    //    }
    
}

extension UIView {
    func findViewController() -> UIViewController? {
        if let nextResponder = self.next as? UIViewController {
            return nextResponder
        } else if let nextResponder = self.next as? UIView {
            return nextResponder.findViewController()
        } else {
            return nil
        }
    }
}

class BottomCardSegue: UIStoryboardSegue {
    
    private var selfRetainer: BottomCardSegue? = nil
    
    override func perform() {
    
        selfRetainer = self
        destination.modalPresentationStyle = .overCurrentContext
        source.present(destination, animated: true, completion: nil)
    }
}
