//
//  CreateProfileViewController.swift
//  PetPals
//
//  Created by Gerardo Mares on 4/1/19.
//  Copyright © 2019 PetPals.inc. All rights reserved.
//


import UIKit
import FirebaseAuth
import FirebaseDatabase
import GeoFire
import CoreLocation
import SwiftOverlays

class CreateProfileViewController: UIViewController {
    
    @IBOutlet weak var profileImage: ProfileImageView!
    @IBOutlet weak var bioTextField:UITextView!
    @IBOutlet weak var petTypeTextField: UITextField!
    @IBOutlet weak var lastNameTextField: UITextField!
    @IBOutlet weak var firstNameTextField: UITextField!
    
    
    let petOptions = AppConstants.petOptions
    var imagePicker: UIImagePickerController!
    private let manager = CLLocationManager()
    
    var geoFireRef: DatabaseReference?
    var geoFire: GeoFire?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        configureLocationManager()
        geoFireRef = Database.database().reference().child("Geolocations")
        
        geoFire = GeoFire(firebaseRef: geoFireRef!)
        
        
        let picker: UIPickerView
        picker = UIPickerView(frame: CGRect(x: 0, y: 200, width: self.view.frame.width, height: 300))
        
        picker.backgroundColor = .white
        
        picker.showsSelectionIndicator = true
        picker.delegate = self
        picker.dataSource = self
        
        let toolBar = UIToolbar()
        toolBar.barStyle = UIBarStyle.default
        toolBar.isTranslucent = true
        toolBar.sizeToFit()
        toolBar.tintColor = UIColor(named: "PetPalDarkBlue")
        
        let doneButton = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(CreateProfileViewController.donePickingImage))
        let spaceButton = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let cancelButton = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(CreateProfileViewController.donePickingImage))
        
        toolBar.setItems([cancelButton, spaceButton, doneButton], animated: false)
        toolBar.isUserInteractionEnabled = true
        
        petTypeTextField.inputView = picker
        petTypeTextField.inputAccessoryView = toolBar
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    private func configureLocationManager(){
        
        if #available(iOS 9.0, *) {
            manager.allowsBackgroundLocationUpdates = true
        } else {
            // Fallback on earlier versions
        }
        manager.desiredAccuracy = kCLLocationAccuracyBest
        manager.distanceFilter = kCLDistanceFilterNone
        manager.pausesLocationUpdatesAutomatically = false
        manager.delegate = self
        manager.requestWhenInUseAuthorization()
    }
    
    @objc
    func donePickingImage() {
        petTypeTextField.resignFirstResponder()
    }
    
    //user is done and wants to create the profile
    @IBAction func creatProfileClicked(_ sender: UIButton) {
        //ensure all input valid
        guard let image = profileImage.image else {
            alertError(message: "Your profile picture is required")
            return
        }
        
        guard let first = firstNameTextField.text, first.count > 0 else {
            alertError(message: "Your first name is required")
            return
        }
        
        guard let last = lastNameTextField.text, last.count > 0 else {
            alertError(message: "Your last name is required")
            return
        }
        
        guard let bio = bioTextField.text, bio.count > 0 else {
            alertError(message: "Your bio is required")
            return
        }
        
        guard let petType = petTypeTextField.text, petType.count > 0 else {
            alertError(message: "Your pet type is required")
            return
        }
        
        //ensure user logged in
        guard let user = Auth.auth().currentUser else {return}
        SwiftOverlays.showTextOverlay(self.view, text: "Creating profile...")
        
        //get the location data for user
        let userLat = UserDefaults.standard.value(forKey: "current_latitude") as! String
        let userLong = UserDefaults.standard.value(forKey: "current_longitude") as! String
        
        //create their profile
        UserProfile.createProfile(forUserWithId: user.uid, withImage: image, withBio: bio, withFirstName: first, withLastName: last, withPet: petType) { (success) in
            DispatchQueue.main.async {
                SwiftOverlays.removeAllBlockingOverlays()
            }
            
            if success {
                //on success update firebase location info
                let location:CLLocation = CLLocation(latitude: CLLocationDegrees(Double(userLat)!), longitude: CLLocationDegrees(Double(userLong)!))
                self.geoFire?.setLocation(location, forKey:user.uid)
                
                //go to main app
                let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
                let newViewController = storyBoard.instantiateViewController(withIdentifier: mainVCAfterAuthIdentifier)
                self.present(newViewController, animated: true, completion: nil)
            }
            else {
                //error creating profile
                self.alertError(message: "Failed To create profile...")
            }
        }
    }
    
    //user wants to edit the photo
    @IBAction func buttonOnClick(_ sender: UIButton) {
        let alert = UIAlertController(title: "", message: "Photo Selection", preferredStyle: UIAlertController.Style.actionSheet)
        let cancel = UIAlertAction(title: "Cancle", style: .cancel, handler: nil)
        alert.addAction(UIAlertAction(title: "Browse", style: .default, handler: { (action: UIAlertAction!) in
            self.uploadFromFiles()
        }))
        
        alert.addAction(UIAlertAction(title: "Camera", style: .default, handler: { (action: UIAlertAction!) in
            self.uploadFromCamera()
        }))
        alert.addAction(cancel)
        
        // show the alert so user can choose between camer or photos
        self.present(alert, animated: true, completion: nil)
    }
    
    //user wants to choose an image from their photos
    func uploadFromFiles() {
        self.imagePicker = UIImagePickerController()
        self.imagePicker.delegate = self
        self.imagePicker.sourceType = .photoLibrary
        self.imagePicker.allowsEditing = true
        
        self.present(self.imagePicker, animated: true, completion: nil)
    }
    
    //user wants to get an image from the camera
    func uploadFromCamera() {
        self.imagePicker = UIImagePickerController()
        self.imagePicker.delegate = self
        //check to be ssure camera available
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            self.imagePicker.sourceType = .camera
            self.imagePicker.cameraCaptureMode = .photo
            self.imagePicker.allowsEditing = true
            self.present(self.imagePicker, animated: true, completion: nil)
        }
        else {
            //not available camer so alert error
            let alert  = UIAlertController(title: "Warning", message: "You don't have a camera", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    private func alertError(message: String) {
        let alertController = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
        
        alertController.addAction(defaultAction)
        self.present(alertController, animated: true, completion: nil)
    }
}


//Image upload picker view
extension CreateProfileViewController : UIImagePickerControllerDelegate, UINavigationControllerDelegate{
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true)
        
        guard let image = info[.editedImage] as? UIImage else {
            print("No image found")
            return
        }
        
        //the image at this point is either from camer or photos and cropped to be a square
        //set the image to be scaled and dismiss the picker
        self.profileImage.image = image.scaleToSize(aSize: CGSize(width: 200.0, height: 200.0))
        self.dismiss(animated: true, completion: nil)
    }
    
    
    func imagePickerControllerDidCancel(_ picker:UIImagePickerController) {
        self.dismiss(animated: true, completion: nil)
    }
    
}


//Pet type picker view delegate and data source functions
extension CreateProfileViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return petOptions.count
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        petTypeTextField.text = petOptions[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return petOptions[row]
    }
}


extension CreateProfileViewController: CLLocationManagerDelegate {
    
    //if the user changed the authorization for getting location get it
    public func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        
        if (status == .authorizedAlways) || (status == .authorizedWhenInUse) {
            manager.startUpdatingLocation()
        }
    }
    
    public func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        
        print("Location Error:\(error.localizedDescription)")
    }
    
    //when location is updated, store it in user defaults
    public func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        let updatedLocation:CLLocation = locations.first!
        let newCoordinate: CLLocationCoordinate2D = updatedLocation.coordinate
        let usrDefaults:UserDefaults = UserDefaults.standard
        
        usrDefaults.set("\(newCoordinate.latitude)", forKey: "current_latitude")
        usrDefaults.set("\(newCoordinate.longitude)", forKey: "current_longitude")
        usrDefaults.synchronize()
    }
}
