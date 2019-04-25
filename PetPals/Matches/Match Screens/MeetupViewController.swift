//
//  MeetupViewController.swift
//  PetPals
//
//  Created by Georgina Garza on 3/25/19.
//  Copyright © 2019 PetPals.inc. All rights reserved.
//

import UIKit

class MeetupViewController: UIViewController {
    // Connect necessary fields
    @IBOutlet weak var chosenUserImage: MatchesImage!
    @IBOutlet weak var chosenUserName: UILabel!
    
    @IBOutlet weak var dateTextField: UITextField!
    @IBOutlet weak var timeTextField: UITextField!
    @IBOutlet weak var locationTextField: UITextField!
    
    // Picker for date
    var datePicker: UIDatePicker!
    var timePicker: UIDatePicker!
    
    // Variables so this information can be passed in
    var userName = String()
    var userImage = NSURL(fileURLWithPath: "")
    
    // Variable to connect to Overall Matches VC
    var parentVC: OverallMatchesViewController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set label and image to variables passed over from MatchesVC
        chosenUserName.text = userName
        chosenUserImage.load(fromURL: userImage as URL)
        
        // Setup date picker
        datePicker = UIDatePicker()
        datePicker.datePickerMode = .date
        datePicker.minimumDate = Date()
        dateTextField.inputView = datePicker
        datePicker.addTarget(self, action: #selector(self.dateChanged(datePicker:)), for: .valueChanged)
        
        // Setup time picker
        timePicker = UIDatePicker()
        timePicker.datePickerMode = .time
        timeTextField.inputView = timePicker
        timePicker.addTarget(self, action: #selector(self.timeChanged(datePicker:)), for: .valueChanged)
    }
    
    // When the user updates the date picker, update the text field accordingly
    @objc func dateChanged(datePicker: UIDatePicker) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM/dd/yyyy"
        
        dateTextField.text = dateFormatter.string(from: datePicker.date)
    }
    
    // When the user updates the time picker, update the text field accordingly
    @objc func timeChanged(datePicker: UIDatePicker) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "hh:mm a"
        
        timeTextField.text = dateFormatter.string(from: datePicker.date)
    }
    
    // code to dismiss keyboard when user clicks on background
    
    func textFieldShouldReturn(textField:UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    // When the user is done, create the meetup
    @IBAction func submitClicked(_ sender: Any) {
        // Ensure all input valid
        guard let date = dateTextField.text, date.count > 0 else {
            alertError(message: "The date is required")
            return
        }
        
        guard let time = timeTextField.text, time.count > 0 else {
            alertError(message: "The time is required")
            return
        }
        
        guard let location = locationTextField.text, location.count > 0 else {
            alertError(message: "A location is required")
            return
        }
        
        print("The suggested meetup date: \(date), time: \(time), location: \(location)")
    }
    
    private func alertError(message: String) {
        let alertController = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
        
        alertController.addAction(defaultAction)
        self.present(alertController, animated: true, completion: nil)
    }
}
