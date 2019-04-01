//
//  SwipeViewController.swift
//  PetPals
//
//  Created by Jesus Palos on 3/25/19.
//  Copyright © 2019 PetPals.inc. All rights reserved.
//

import UIKit
import Koloda


var count = 3

var images = ["parrot.png","charles","chris"]

class SwipeViewController: UIViewController {
   
 

    @IBOutlet weak var kolodaView: KolodaView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        kolodaView.dataSource = self
        kolodaView.delegate = self
        // Do any additional setup after loading the view.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

extension SwipeViewController: KolodaViewDataSource {
    func koloda(_ koloda: KolodaView, viewForCardAt index: Int) -> UIView {
//        return UIImageView(image: UIImage(named: "cards_\(index + 1)"))
        
        let cardView: CardView = CardView()
        cardView.initWithName(images[index])
        return cardView
    }
    
    func kolodaNumberOfCards(_ koloda: KolodaView) -> Int {
        return 3
    }
}

extension SwipeViewController : KolodaViewDelegate {
    
}
