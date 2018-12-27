//
//  EditVC.swift
//  CorkBoard
//
//  Created by Tanner Luke on 10/22/17.
//  Copyright © 2017 CorkBoard Co. All rights reserved.
//

import UIKit
import Parse

class EditVC: UIViewController,  UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextViewDelegate {
    
    
    //UIPickerViewDelegate, UIPickerViewDataSource,
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var profilePic: UIImageView!
    @IBOutlet weak var username: UITextField!
    @IBOutlet weak var fullname: UITextField!
    @IBOutlet weak var bio: UITextView!
    @IBOutlet weak var email: UITextField!
    @IBOutlet weak var phoneNumber: UITextField!
    @IBOutlet weak var gender: UITextField!
    let gray = UIColor(displayP3Red: 184/255, green: 184/255, blue: 184/255, alpha: 1)
    //var genderPicker: UIPickerView!
    //let genders = ["Male", "Female", "Other"]
    var keyboard = CGRect()
    var scrollViewHeight: CGFloat = 0
   
    @IBOutlet weak var savingView: UIView!
    @IBOutlet weak var indicatorView: UIActivityIndicatorView!
    @IBOutlet weak var savingLabel: UILabel!
    // user variables
    
    var startingUsername: String?
    var startingFullName: String?
    var startingBio: String?
    var startingEmail: String?
    var startingPhone: String?
    var startingGender: String?
    var startingProfilePic: UIImage?
    
    var shouldSaveNewPicData: Bool = false
    var shouldSaveNewUsername: Bool = false
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        networkNotification()
//        genderPicker = UIPickerView()
//        genderPicker.dataSource = self
//        genderPicker.delegate = self
//        genderPicker.backgroundColor = UIColor.groupTableViewBackground
//        genderPicker.showsSelectionIndicator = true
//        gender.inputView = genderPicker
        scrollView.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height)
        scrollView.contentSize.height = self.view.frame.height
        scrollViewHeight = scrollView.frame.size.height
        bio.delegate = self
        NotificationCenter.default.addObserver(self, selector: #selector(EditVC.showKeyboard(notification:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(EditVC.hideKeyboard(notification:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        let tapToHide = UITapGestureRecognizer(target: self, action: #selector(EditVC.hideKeyboardTap(recognizer:)))
        tapToHide.numberOfTapsRequired = 1
        self.view.isUserInteractionEnabled = true
        self.view.addGestureRecognizer(tapToHide)
        let profilePicTap = UITapGestureRecognizer(target: self, action: #selector(EditVC.getProfilePic(recognizer:)))
        profilePicTap.numberOfTapsRequired = 1
        profilePic.isUserInteractionEnabled = true
        profilePic.addGestureRecognizer(profilePicTap)
        self.navigationController?.navigationBar.isHidden = false
        
        savingView.isHidden = true
        indicatorView.alpha = 1
        savingView.alpha = 1
        
        alignment()
        userInfo()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.navigationBar.isHidden = false
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func networkNotification() {
        if Reachability.isConnectedToNetwork() {
            
            print("connected")
        } else {
            
            let alert = UIAlertController(title: "Network Error", message: "Sorry, but there appears to be an error with your internet connection. Please try again later.", preferredStyle: .alert)
            let okay = UIAlertAction(title: "Okay", style: UIAlertActionStyle.cancel, handler: nil)
            alert.addAction(okay)
            present(alert, animated: true, completion: nil)
        }
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        let currentText = textView.text ?? ""
        guard let stringRange = Range(range, in: currentText) else { return false }
        
        let changedText = currentText.replacingCharacters(in: stringRange, with: text)
        
        return changedText.count <= 140
    }
    
    @objc func getProfilePic(recognizer: UITapGestureRecognizer) {
        let picker = UIImagePickerController()
        picker.delegate = self as UIImagePickerControllerDelegate & UINavigationControllerDelegate
        picker.sourceType = .photoLibrary
        picker.allowsEditing = true
        present(picker, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        profilePic.image = info[UIImagePickerControllerEditedImage] as? UIImage
        self.dismiss(animated: true) {
            self.shouldSaveNewPicData = true
            print(self.shouldSaveNewPicData)
        }
    }
    
    @objc func hideKeyboardTap(recognizer: UITapGestureRecognizer){
        self.view.endEditing(true)
    }
    
    @objc func showKeyboard(notification: NSNotification) {
        keyboard = ((notification.userInfo?[UIKeyboardFrameEndUserInfoKey]! as AnyObject).cgRectValue)!
        UIView.animate(withDuration: 0.4) {
            self.scrollView.frame.size.height = self.scrollViewHeight - self.keyboard.height
        }
    }
    
    @objc func hideKeyboard(notification: NSNotification) {
        UIView.animate(withDuration: 0.4) {
            self.scrollView.frame.size.height = self.view.frame.height
        }
    }
    
    func alignment() {
        profilePic.frame = CGRect(x: self.view.frame.size.width/2 - 40, y: 40, width: 80, height: 80)
        profilePic.layer.cornerRadius = profilePic.frame.size.width / 2
        profilePic.clipsToBounds = true
        username.frame = CGRect(x: 10, y: profilePic.frame.origin.y + 90, width: self.view.frame.size.width - 20, height: 30)
        fullname.frame = CGRect(x: 10, y: username.frame.origin.y + 40, width: self.view.frame.size.width - 20, height: 30)
        bio.frame = CGRect(x: 10, y: fullname.frame.origin.y + 40, width: self.view.frame.size.width - 20, height: 60)
        bio.layer.borderWidth = 0.33
        bio.layer.borderColor = gray.cgColor
        bio.layer.cornerRadius = bio.frame.size.width/50
        bio.clipsToBounds = true
        email.frame = CGRect(x: 10, y: bio.frame.origin.y + 70, width: self.view.frame.size.width - 20, height: 30)
        phoneNumber.frame = CGRect(x: 10, y: email.frame.origin.y + 40, width: self.view.frame.size.width - 20, height: 30)
        //gender.frame = CGRect(x: 10, y: phoneNumber.frame.origin.y + 40, width: self.view.frame.size.width - 20, height: 30)
    }
    
    func userInfo() {
        let profilePicture = PFUser.current()?.object(forKey: "profilepic") as! PFFile
        profilePicture.getDataInBackground { (data, error) in
            self.profilePic.image = UIImage(data: data!)
            self.startingProfilePic = self.profilePic.image
        }
        username.text = PFUser.current()?.username
        fullname.text = PFUser.current()?.object(forKey: "fullname") as? String
        bio.text = PFUser.current()?.object(forKey: "bio") as? String
        email.text = PFUser.current()?.email
        phoneNumber.text = PFUser.current()?.object(forKey: "cellnumber") as? String
        //gender.text = PFUser.current()?.object(forKey: "gender") as? String
        
        startingUsername = username.text
        startingFullName = fullname.text
        startingBio = bio.text
        startingEmail = email.text
        startingPhone = phoneNumber.text
        startingGender = gender.text
        
        
        
    }
    
    func validateEmail(email: String) -> Bool {
        let regex = "[A-Z0-9a-z._%+-]{4}+@[A-Za-z0-9.-]+\\.[A-Za-z]{2}"
        let range = email.range(of: regex, options: .regularExpression)
        let result = range != nil ? true : false
        return result
    }
    
    func alertMessage(error: String, message: String) {
        let alert = UIAlertController(title: error, message: message, preferredStyle: .alert)
        let okay = UIAlertAction(title: "Okay", style: UIAlertActionStyle.cancel, handler: nil)
        alert.addAction(okay)
        self.present(alert, animated: true, completion: nil)
    }
    
    @IBAction func saveButton(_ sender: Any) {
        
        savingView.isHidden = true
        indicatorView.startAnimating()
        
        networkNotification()
        if !validateEmail(email: email.text!) {
            alertMessage(error: "Invalid Email", message: "Please provide a valid Email")
            return
        }
        
        let user = PFUser.current()!
        
        if startingUsername != username.text! {
            user.username = username.text
            shouldSaveNewUsername = true
        }
        if startingEmail != email.text! {
            user.email = email.text
        }
        if startingFullName != fullname.text {
            user["fullname"] = fullname.text
        }
        if startingPhone != phoneNumber.text! {
            if phoneNumber.text!.isEmpty {
                user["phonenumber"] = ""
            } else {
                user["phonenumber"] = phoneNumber.text
            }
        }
        
        if bio.text!.isEmpty {
            user["bio"] = ""
        } else {
            user["bio"] = bio.text
        }
        /*
        if startingGender != gender.text! {
            if gender.text!.isEmpty {
                user["gender"] = ""
            } else {
                user["gender"] = gender.text
            }
        }
        */
        if shouldSaveNewPicData == true {
            let profilePicData = UIImageJPEGRepresentation(profilePic.image!, 0.5)
            let profilePicFile = PFFile(name: "profilepic.jpg", data: profilePicData!)
            user["profilepic"] = profilePicFile
        }
        user.saveInBackground { (success, error) in
           if error == nil {
            
            if self.shouldSaveNewPicData == true {
                self.updateProfilePicObjects()
            }
            
            if self.shouldSaveNewUsername == true {
                self.updateUsernameInObjects()
            }
            
            
                self.indicatorView.stopAnimating()
                self.savingView.isHidden = true
                self.view.endEditing(true)
                self.dismiss(animated: true, completion: nil)
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "reloadBio"), object: nil)
            } else {
                //self.parseErrorAlert()
                self.indicatorView.stopAnimating()
                self.savingView.isHidden = true
            
                let alert = UIAlertController(title: "Error", message: error!.localizedDescription, preferredStyle: UIAlertControllerStyle.alert)
                let cancel = UIAlertAction(title: "Okay", style: UIAlertActionStyle.cancel, handler: nil)
                alert.addAction(cancel)
                self.present(alert, animated: true, completion: nil)
                print(error!.localizedDescription)
            }
        }
    }
    
    @IBAction func cancelButton(_ sender: Any) {
        self.view.endEditing(true)
        self.dismiss(animated: true, completion: nil)
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
//    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
//        return genders.count
//    }
//
//   func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
//        return genders[row]
//    }
//
//    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
//        gender.text = genders[row]
//        self.view.endEditing(true)
//    }
    
    
    func updateUsernameInObjects() {
        let postQuery = PFQuery(className: "posts")
        postQuery.whereKey("username", equalTo: startingUsername!)
        postQuery.findObjectsInBackground { (objects, error) in
            if error == nil {
                for object in objects! {
                    object["username"] = self.username.text
                    object.saveInBackground(block: { (success, error) in
                        if error == nil {
                            print("changed")
                        } else {
                            print(error!.localizedDescription)
                            self.parseErrorAlert()
                        }
                    })
                }
            } else {
                self.parseErrorAlert()
                print(error!.localizedDescription)
            }
        }
        let likeQuery = PFQuery(className: "likes")
        likeQuery.whereKey("by", equalTo: startingUsername!)
        likeQuery.findObjectsInBackground { (objects, error) in
            if error == nil {
                for object in objects! {
                    object["by"] = self.username.text
                    object.saveInBackground(block: { (success, error) in
                        if error == nil {
                            print("likes changed")
                        } else {
                            self.parseErrorAlert()
                        }
                    })
                }
            } else {
                self.parseErrorAlert()
            }
        }
        let commentQuery = PFQuery(className: "comments")
        commentQuery.whereKey("username", equalTo: startingUsername!)
        commentQuery.findObjectsInBackground { (objects, error) in
            if error == nil {
                for object in objects! {
                    object["username"] = self.username.text
                    object.saveInBackground(block: { (success, error) in
                        if error == nil {
                            print("comments working")
                        } else {
                            self.parseErrorAlert()
                        }
                    })
                }
            } else {
                self.parseErrorAlert()
            }
        }
        
        let commentToQuery = PFQuery(className: "comment")
        commentToQuery.whereKey("to", equalTo: startingUsername!)
        commentToQuery.findObjectsInBackground { (objects, error) in
            if error == nil {
                for object in objects! {
                    object["to"] = self.username.text
                    if error == nil {
                        print("comments to")
                    }
                }
            }
        }
        
        
        let followerQuery = PFQuery(className: "follow")
        followerQuery.whereKey("follower", equalTo: startingUsername!)
        followerQuery.findObjectsInBackground { (objects, error) in
            if error == nil {
                for object in objects! {
                    object["follower"] = self.username.text
                    object.saveInBackground(block: { (success, error) in
                        if error == nil {
                            print("follower updated")
                        } else {
                            self.parseErrorAlert()
                        }
                    })
                }
            } else {
                self.parseErrorAlert()
            }
        }
        let followingQuery = PFQuery(className: "follow")
        followingQuery.whereKey("following", equalTo: startingUsername!)
        followingQuery.findObjectsInBackground { (objects, error) in
            if error == nil {
                for object in objects! {
                    object["following"] = self.username.text
                    object.saveInBackground(block: { (success, error) in
                        if error == nil {
                            print("following updated")
                        } else {
                            self.parseErrorAlert()
                        }
                    })
                }
            } else {
                self.parseErrorAlert()
            }
            
        }
        let notificationQuery = PFQuery(className: "notification")
        notificationQuery.whereKey("owner", equalTo: startingUsername!)
        notificationQuery.findObjectsInBackground { (objects, error) in
            if error == nil {
                for object in objects! {
                    object["to"] = self.username.text
                    object["owner"] = self.username.text
                    object.saveInBackground(block: { (success, error) in
                        if error == nil {
                            print("notification to updated")
                        } else {
                            self.parseErrorAlert()
                        }
                    })
                }
            } else {
                self.parseErrorAlert()
            }
        }
        let notificationByQuery = PFQuery(className: "notification")
        notificationByQuery.whereKey("by", equalTo: startingUsername!)
        notificationByQuery.findObjectsInBackground { (objects, error) in
            if error == nil {
                for object in objects! {
                    object["by"] = self.username.text
                    object.saveInBackground(block: { (success, error) in
                        if error == nil {
                            print("notifications by updated")
                        } else {
                            self.parseErrorAlert()
                        }
                    })
                }
            } else {
                self.parseErrorAlert()
            }
        }
        let requestQueryFollower = PFQuery(className: "request")
        requestQueryFollower.whereKey("follower", equalTo: startingUsername!)
        requestQueryFollower.findObjectsInBackground { (objects, error) in
            if error == nil {
                for object in objects! {
                    object["follower"] = self.username.text
                    object.saveInBackground(block: { (success, error) in
                        if error == nil {
                            print("request follower updated")
                        } else {
                            self.parseErrorAlert()
                        }
                    })
                }
            } else {
                self.parseErrorAlert()
            }
        }
        let requestQueryFollowing = PFQuery(className: "request")
        requestQueryFollowing.whereKey("following", equalTo: startingUsername!)
        requestQueryFollowing.findObjectsInBackground { (objects, error) in
            if error == nil {
                for object in objects! {
                    object["following"] = self.username.text
                }
            } else {
                self.parseErrorAlert()
            }
        }
    }
    
    func updateProfilePicObjects() {
        
        let postQuery = PFQuery(className: "posts")
        postQuery.whereKey("username", equalTo: startingUsername!)
        postQuery.findObjectsInBackground { (objects, error) in
            if error == nil {
                for object in objects! {
                    
                    let profilePicData = UIImageJPEGRepresentation(self.profilePic.image!, 0.5)
                    let profilePicFile = PFFile(name: "profilepic.jpg", data: profilePicData!)
                    object["profilepic"] = profilePicFile
                    
                    object.saveInBackground(block: { (success, error) in
                        if error == nil {
                            print("profilePic is updated")
                        }
                    })
                    
                }
            }
        }
        
        let commentToQuery = PFQuery(className: "comments")
        commentToQuery.whereKey("to", equalTo: startingUsername!)
        commentToQuery.findObjectsInBackground { (objects, error) in
            if error == nil {
                for object in objects! {
                    
                    let profilePicData = UIImageJPEGRepresentation(self.profilePic.image!, 0.5)
                    let profilePicFile = PFFile(name: "profilepic.jpg", data: profilePicData!)
                    object["profilepic"] = profilePicFile
                    object.saveInBackground(block: { (success, error) in
                        if error == nil {
                            print("profilePic is updated")
                        }
                    })
                    
                }
            }
        }
        
        let commentOwnerQuery = PFQuery(className: "comments")
        commentOwnerQuery.whereKey("username", equalTo: startingUsername!)
        commentOwnerQuery.findObjectsInBackground { (objects, error) in
            if error == nil {
                for object in objects! {
                    
                    let profilePicData = UIImageJPEGRepresentation(self.profilePic.image!, 0.5)
                    let profilePicFile = PFFile(name: "profilepic.jpg", data: profilePicData!)
                    object["profilepic"] = profilePicFile
                    object.saveInBackground(block: { (success, error) in
                        if error == nil {
                            print("profilePic is updated")
                        }
                    })
                    
                }
                
                
            }
        }
        
        
        let notificationQuery = PFQuery(className: "notification")
        notificationQuery.whereKey("by", equalTo: startingUsername!)
        notificationQuery.findObjectsInBackground { (objects, error) in
            if error == nil {
                for object in objects! {
                    
                    let profilePicData = UIImageJPEGRepresentation(self.profilePic.image!, 0.5)
                    let profilePicFile = PFFile(name: "profilepic.jpg", data: profilePicData!)
                    object["profilepic"] = profilePicFile
                    object.saveInBackground(block: { (success, error) in
                        if error == nil {
                            print("profilePic is updated")
                        }
                    })
                    
                }
            }
        }
        
        
    }
    
    
    
    
    
}
