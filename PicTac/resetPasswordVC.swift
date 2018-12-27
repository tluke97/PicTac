//
//  resetPasswordVC.swift
//  CorkBoard
//
//  Created by Tanner Luke on 10/9/17.
//  Copyright © 2017 CorkBoard Co. All rights reserved.
//

import UIKit
import Parse

class resetPasswordVC: UIViewController {
    
    @IBOutlet weak var emailReset: UITextField!
    @IBOutlet weak var resetButton: UIButton!
    @IBOutlet weak var cancelReset: UIButton!
    
    override func viewDidLoad() {
       super.viewDidLoad()
        networkNotification()
        alignment()
    }
    
    func alignment() {
        emailReset.frame = CGRect(x: 10, y: 120, width: self.view.frame.size.width - 20, height: 30)
        resetButton.frame = CGRect(x: 20, y: emailReset.frame.origin.y + 60, width: self.view.frame.size.width/4, height: 30)
        cancelReset.frame = CGRect(x: self.view.frame.size.width - self.view.frame.size.width/4 - 20, y: resetButton.frame.origin.y, width: self.view.frame.size.width/4 , height: 30)
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
    
    
    @IBAction func resetButtonTapped(_ sender: Any) {
        self.view.endEditing(true)
        if (emailReset.text?.isEmpty)! {
            let alert = UIAlertController(title: "Missing Information", message: "Email field is empty", preferredStyle: UIAlertControllerStyle.alert)
            let okay = UIAlertAction(title: "Okay", style: UIAlertActionStyle.cancel, handler: nil)
            alert.addAction(okay)
            self.present(alert, animated: true, completion: nil)
        }
        PFUser.requestPasswordResetForEmail(inBackground: emailReset.text!) { (success, error) in
            if success {
                let alert = UIAlertController(title: "Password Reset", message: "Email has been sent to \(self.emailReset.text ?? "your email")", preferredStyle: UIAlertControllerStyle.alert)
                let okay = UIAlertAction(title: "Okay", style: UIAlertActionStyle.default, handler: { (UIAlertAction) in
                    self.dismiss(animated: true, completion: nil)
                })
                alert.addAction(okay)
                self.present(alert, animated: true, completion: nil)
            }
            else {
                print(error?.localizedDescription as Any)
            }
        }
    }
    
    @IBAction func cancelButtonClicked(_ sender: Any) {
        self.view.endEditing(true)
        self.dismiss(animated: true, completion: nil)
    }
}
