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

var images = ["One","Two","Three"]

class SwipeViewController: UIViewController, KolodaViewDelegate,KolodaViewDataSource {
   
    func koloda(_ koloda: KolodaView, viewForCardAt index: Int) -> UIView {
//        return UIImageView(image: UIImage(named: "cards_\(index + 1)"))
        
        return
    }
    
    func kolodaNumberOfCards(_ koloda: KolodaView) -> Int {
        return 5
    }
    

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

//extension SwipeViewController: KolodaViewDelegate {
//
//}
