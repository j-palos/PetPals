//
//  ProfileViewController.swift
//  PetPals
//
//  Created by Sabrina Herrero on 3/27/19.
//  Copyright © 2019 PetPals.inc. All rights reserved.
//

import UIKit
import FirebaseAuth

class ProfileViewController: UIViewController {
    
    // Elements on screen
    @IBOutlet weak var profilePicture: ProfileImageView!
    @IBOutlet weak var profileName: UILabel!
    @IBOutlet weak var profilePetType: UILabel!
    @IBOutlet weak var profileBio: UILabel!
    
    // Initially will be hidden elements on screen
    @IBOutlet weak var nameField: UITextField!
    @IBOutlet weak var bioField: UITextField!
    @IBOutlet weak var typePicker: UIPickerView!
    
    // Get options for pet types
    let petOptions = AppConstants.petOptions
    var imagePicker: UIImagePickerController!
    var count = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Display this user's profile picture
        self.profilePicture.layer.zPosition = -1
        self.profilePicture.layer.cornerRadius = self.profilePicture.frame.size.width / 2;
        self.profilePicture.clipsToBounds = true
        let usrDefaults: UserDefaults = .standard
        if let url = usrDefaults.url(forKey: "profile_image") {
            profilePicture.load(fromURL: url)
        }

        // Display this user's information
        if let id = Auth.auth().currentUser?.uid {
            UserProfile.getProfile(forUserID: id, completion: { (user) in
                DispatchQueue.main.async {
                    self.profileName.text = user.firstName
                    self.profilePetType.text = user.petType
                    self.profileBio.text = user.bio
                }
            })
        }
        
        // Set up picker
        let picker: UIPickerView
        picker = UIPickerView(frame: CGRect(x: 0, y: 200, width: self.view.frame.width, height: 300))
        
        picker.backgroundColor = .white
        
        picker.showsSelectionIndicator = true
        picker.delegate = self
        picker.dataSource = self
        
        typePicker.delegate = self
        typePicker.dataSource = self
    }
    
    @IBAction func pictureButtonClicked(_ sender: Any) {
        // If a user wants to edit their profile picture
        // let them select from their pictures or take one with camera
        let alert = UIAlertController(title: "", message: "Photo Selection", preferredStyle: UIAlertController.Style.actionSheet)
        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
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
    
    // Want to edit name, so show name field
    @IBAction func nameButtonClicked(_ sender: Any) {
        nameField.alpha = 1
        
        // Initially name field has current profile name
        nameField.text = profileName.text
    }
    
    // Want to edit pet type, so show pet type picker
    @IBAction func typeButtonClicked(_ sender: Any) {
        typePicker.isHidden = false
    }
    
    @IBAction func bioButtonClicked(_ sender: Any) {
        bioField.alpha = 1
        bioField.text = profileBio.text
    }

    @IBAction func nameEditEnd(_ sender: Any) {
        nameField.alpha = 0
        profileName.text = nameField.text
    }
    
    @IBAction func bioEditEnd(_ sender: Any) {
        bioField.alpha = 0
        profileBio.text = bioField.text
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
    
    // code to dismiss keyboard when user clicks on background
    
    func textFieldShouldReturn(textField:UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
        
        let touch: UITouch? = touches.first
        if !typePicker.isHidden && touch?.view != typePicker {
            typePicker.isHidden = true
        }
    }
}
///Image upload picker view
extension ProfileViewController : UIImagePickerControllerDelegate, UINavigationControllerDelegate{
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true)
        
        guard let image = info[.editedImage] as? UIImage else {
            print("No image found")
            return
        }
        
        //the image at this point is either from camer or photos and cropped to be a square
        //set the image to be scaled and dismiss the picker
        self.profilePicture.image = image.scaleToSize(aSize: CGSize(width: 200.0, height: 200.0))
    }
    
    
    func imagePickerControllerDidCancel(_ picker:UIImagePickerController) {
        self.dismiss(animated: true, completion: nil)
    }
    
}


//Pet type picker view delegate and data source functions
extension ProfileViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return petOptions.count
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        profilePetType.text = petOptions[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return petOptions[row]
    }
}

