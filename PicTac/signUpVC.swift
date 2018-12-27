//
//  signUpVC.swift
//  
//
//  Created by Tanner Luke on 10/9/17.
//

import UIKit
import Parse

class signUpVC: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBOutlet weak var profilePic: UIImageView!
    @IBOutlet weak var newUsername: UITextField!
    @IBOutlet weak var newPassword: UITextField!
    @IBOutlet weak var newPasswordRepeat: UITextField!
    @IBOutlet weak var fullName: UITextField!
    @IBOutlet weak var bio: UITextField!
    @IBOutlet weak var newEmail: UITextField!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var createAccount: UIButton!
    @IBOutlet weak var cancelButton: UIButton!
    var scrollViewHeight: CGFloat = 0
    var keyboard = CGRect()
    var dataCheck = false
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        scrollView.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height)
        scrollView.contentSize.height = self.view.frame.height
        scrollViewHeight = scrollView.frame.size.height
        
        NotificationCenter.default.addObserver(self, selector: #selector(signUpVC.showKeyboard(notification:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(signUpVC.hideKeyboard(notification:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        
        let tapToHide = UITapGestureRecognizer(target: self, action: #selector(signUpVC.hideKeyboardTap(recognizer:)))
        tapToHide.numberOfTapsRequired = 1
        self.view.isUserInteractionEnabled = true
        self.view.addGestureRecognizer(tapToHide)
        
        let profilePicTap = UITapGestureRecognizer(target: self, action: #selector(signUpVC.getProfilePic(recognizer:)))
        profilePicTap.numberOfTapsRequired = 1
        profilePic.isUserInteractionEnabled = true
        profilePic.addGestureRecognizer(profilePicTap)
        
        alignment()
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
    
    func alignment() {
        profilePic.frame = CGRect(x: self.view.frame.size.width/2 - 40, y: 40, width: 80, height: 80)
        newUsername.frame = CGRect(x: 10, y: profilePic.frame.origin.y + 90, width: self.view.frame.size.width - 20, height: 30)
        newEmail.frame = CGRect(x: 10, y: newUsername.frame.origin.y + 40, width: self.view.frame.size.width - 20, height: 30)
        newPassword.frame = CGRect(x: 10, y: newEmail.frame.origin.y + 40, width: self.view.frame.size.width - 20, height: 30)
        newPasswordRepeat.frame = CGRect(x: 10, y: newPassword.frame.origin.y + 40, width: self.view.frame.size.width - 20, height: 30)
        fullName.frame = CGRect(x: 10, y: newPasswordRepeat.frame.origin.y + 40, width: self.view.frame.size.width - 20, height: 30)
        bio.frame = CGRect(x: 10, y: fullName.frame.origin.y + 40, width: self.view.frame.size.width - 20, height: 30)
        createAccount.frame = CGRect(x: 20, y: bio.frame.origin.y + 50, width: self.view.frame.size.width / 4, height: 30)
        cancelButton.frame = CGRect(x: self.view.frame.size.width - self.view.frame.size.width/4 - 20, y: createAccount.frame.origin.y, width: self.view.frame.size.width / 4, height: 30)
        profilePic.layer.cornerRadius = profilePic.frame.size.width / 2
        profilePic.clipsToBounds = true
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
        self.dismiss(animated: true, completion: nil)
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
    
    
    @IBAction func createAccountClicked(_ sender: Any) {
        networkNotification()
        self.view.endEditing(true)
        if (newUsername.text!.isEmpty || newEmail.text!.isEmpty || newPassword.text!.isEmpty || newPasswordRepeat.text!.isEmpty || fullName.text!.isEmpty) {
            let alert = UIAlertController(title: "Missing Information", message: "One or more text fields is empty", preferredStyle: UIAlertControllerStyle.alert)
            let okay = UIAlertAction(title: "Okay", style: UIAlertActionStyle.cancel, handler: nil)
            alert.addAction(okay)
            self.present(alert, animated: true, completion: nil)
            return
        } else {
            dataCheck = true
            }
        if newPassword.text != newPasswordRepeat.text {
            let alert = UIAlertController(title: "Error", message: "Passwords must match", preferredStyle: UIAlertControllerStyle.alert)
            let okay = UIAlertAction(title: "Okay", style: UIAlertActionStyle.cancel, handler: nil)
            alert.addAction(okay)
            self.present(alert, animated: true, completion: nil)
            return
        }
        if fullName.text!.count > 20 {
            let alert = UIAlertController(title: "Error", message: "Passwords must match", preferredStyle: UIAlertControllerStyle.alert)
            let okay = UIAlertAction(title: "Okay", style: UIAlertActionStyle.cancel, handler: nil)
            alert.addAction(okay)
            self.present(alert, animated: true, completion: nil)
            return
        }
        if newUsername.text!.count > 20 {
            let alert = UIAlertController(title: "Error", message: "Too many characters in username", preferredStyle: UIAlertControllerStyle.alert)
            let okay = UIAlertAction(title: "Okay", style: UIAlertActionStyle.cancel, handler: nil)
            alert.addAction(okay)
            self.present(alert, animated: true, completion: nil)
            return
        } else if newUsername.text!.count < 4 {
            let alert = UIAlertController(title: "Error", message: "Username must be at least 4 characters", preferredStyle: UIAlertControllerStyle.alert)
            let okay = UIAlertAction(title: "Okay", style: UIAlertActionStyle.cancel, handler: nil)
            alert.addAction(okay)
            self.present(alert, animated: true, completion: nil)
            return
        }
        if newPassword.text!.count < 5 {
            let alert = UIAlertController(title: "Error", message: "Password must be at least 5 characters", preferredStyle: UIAlertControllerStyle.alert)
            let okay = UIAlertAction(title: "Okay", style: UIAlertActionStyle.cancel, handler: nil)
            alert.addAction(okay)
            self.present(alert, animated: true, completion: nil)
            return
        }
        let user = PFUser()
        user.username = newUsername.text
        user.email = newEmail.text
        user.password = newPassword.text
        user["fullname"] = fullName.text
        user["bio"] = bio.text ?? ""
        user["cellnumber"] = ""
        //user["gender"] = ""
        user["locked"] = "no"
        user["autopin"] = false
        let profilePicData = UIImageJPEGRepresentation(self.profilePic.image!, 0.5)
        let profilePicFile = PFFile(name: "profilePic.png", data: profilePicData!)
        user["profilepic"] = profilePicFile
        if dataCheck == true {
            user.signUpInBackground { (success, error)
            in if success {
                
                //SETTING UP USER DEFAULTS FOR PROFILE
                UserDefaults.standard.set(user.username, forKey: "username")
                UserDefaults.standard.set(self.fullName.text, forKey: "fullname")
                UserDefaults.standard.set(self.bio.text, forKey: "bio")
                UserDefaults.standard.set(profilePicData, forKey: "profilePic")
                
                
                
                
                
                UserDefaults.standard.set(true, forKey: "animated")
                UserDefaults.standard.set("blue", forKey: "lineColor")
                UserDefaults.standard.set("circle", forKey: "shape")
                UserDefaults.standard.synchronize()
                let appDelegate: AppDelegate = UIApplication.shared.delegate as! AppDelegate
                appDelegate.login()
                self.performSegue(withIdentifier: "toTheMain", sender: self)
                
            } else {
                let alert = UIAlertController(title: "Error", message: "\(error!.localizedDescription)", preferredStyle: UIAlertControllerStyle.alert)
                let okay = UIAlertAction(title: "Okay", style: UIAlertActionStyle.cancel, handler: nil)
                alert.addAction(okay)
                self.present(alert, animated: true, completion: nil)
                }
            }
        }
    }
    @IBAction func cancelButtonClicked(_ sender: Any) {
        self.view.endEditing(true)
        self.dismiss(animated: true, completion: nil)
    }
}
