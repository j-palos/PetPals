//
//  DateFinderViewController.swift
//  PetPals
//
//  Created by Georgina Garza on 3/12/19.
//  Copyright © 2019 PetPals.inc. All rights reserved.
//

import UIKit
import Koloda

class DateFinderViewController: UIViewController {

    @IBOutlet weak var kolodaView: KolodaView!
    fileprivate var dataSource: [UIImage] = {
        var array: [UIImage] = []
        for index in stride(from:0, to: 5, by:1) {
            array.append(UIImage(named: "Card_like_\(index + 1)")!)
        }
        
        return array
    }()
    override func viewDidLoad() {
        super.viewDidLoad()
        kolodaView.dataSource = self
        kolodaView.delegate = self
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

extension DateFinderViewController: KolodaViewDelegate {
    func kolodaDidRunOutOfCards(_ koloda: KolodaView) {
        koloda.reloadData()
    }
    
    func koloda(_ koloda: KolodaView, didSelectCardAt index: Int) {
        UIApplication.shared.openURL(URL(string: "https://yalantis.com/")!)
    }
}
    
    extension DateFinderViewController: KolodaViewDataSource {
        
        func kolodaNumberOfCards(_ koloda:KolodaView) -> Int {
            return dataSource.count
        }
        
        func kolodaSpeedThatCardShouldDrag(_ koloda: KolodaView) -> DragSpeed {
            return .fast
        }
        
        func koloda(_ koloda: KolodaView, viewForCardAt index: Int) -> UIView {
            return UIImageView(image: dataSource[index])
        }
        
        func koloda(_ koloda: KolodaView, viewForCardOverlayAt index: Int) -> OverlayView? {
            return Bundle.main.loadNibNamed("OverlayView", owner: self, options: nil)?[0] as OverlayView
        }
    }

