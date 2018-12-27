//
//  SignInVC.swift
//  CorkBoard
//
//  Created by Tanner Luke on 10/9/17.
//  Copyright © 2017 CorkBoard Co. All rights reserved.
//

import UIKit
import Parse

class SignInVC: UIViewController {

    @IBOutlet weak var corkboardLabel: UILabel!
    @IBOutlet weak var username: UITextField!
    @IBOutlet weak var password: UITextField!
    @IBOutlet weak var signInButton: UIButton!
    @IBOutlet weak var signUpButton: UIButton!
    @IBOutlet weak var resetPassword: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //alignment()
        let tapToEnd = UITapGestureRecognizer(target: self, action: #selector(SignInVC.hideKeyboard(recognizer:)))
        tapToEnd.numberOfTapsRequired = 1
        self.view.isUserInteractionEnabled = true
        self.view.addGestureRecognizer(tapToEnd)
        signInButton.layer.cornerRadius = self.signInButton.frame.size.height / 2
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
        
        
        corkboardLabel.frame = CGRect(x: 10 , y: 80, width: self.view.frame.size.width - 20, height: 50)
        username.frame = CGRect(x: 10, y: corkboardLabel.frame.origin.y + 90, width: self.view.frame.size.width - 20, height: 30)
        password.frame = CGRect(x: 10, y: username.frame.origin.y + 45, width: self.view.frame.size.width - 20, height: 30)
        resetPassword.frame = CGRect(x: 10, y: password.frame.origin.y + 150, width: self.view.frame.size.width - 20 , height: 30)
        signInButton.frame = CGRect(x: self.view.frame.size.width/2 - (self.view.frame.size.width / 6) , y: password.frame.origin.y + 60, width: self.view.frame.size.width / 3, height: 30)
        //let newAccountLabel = UILabel(frame: CGRect(x: <#T##CGFloat#>, y: <#T##CGFloat#>, width: <#T##CGFloat#>, height: <#T##CGFloat#>))
        signUpButton.frame = CGRect(x: self.view.frame.size.width/2 - (self.view.frame.size.width / 6), y: signInButton.frame.origin.y + 50, width: self.view.frame.size.width / 3, height: 30)
    }
    
    @IBAction func signInButtonTapped(_ sender: Any) {
        networkNotification()
        self.view.endEditing(true)
        if username.text!.isEmpty || password.text!.isEmpty {
            let alert = UIAlertController(title: "Missing Information", message: "One or more text fields is empty", preferredStyle: UIAlertControllerStyle.alert)
            let okay = UIAlertAction(title: "Okay", style: UIAlertActionStyle.cancel, handler: nil)
            alert.addAction(okay)
            self.present(alert, animated: true, completion: nil)
        }
        PFUser.logInWithUsername(inBackground: username.text!, password: password.text!) { (user, error) in
            if error == nil {
                UserDefaults.standard.set(user!.username, forKey: "username")
                UserDefaults.standard.set(true, forKey: "animated")
                UserDefaults.standard.set("blue", forKey: "lineColor")
                UserDefaults.standard.set("circle", forKey: "shape")
                UserDefaults.standard.synchronize()
                let appDelegate: AppDelegate = UIApplication.shared.delegate as! AppDelegate
                appDelegate.login()
            }
            else{
                let alert = UIAlertController(title: "Error", message: "\(error!.localizedDescription)", preferredStyle: UIAlertControllerStyle.alert)
                let okay = UIAlertAction(title: "Okay", style: UIAlertActionStyle.cancel, handler: nil)
                alert.addAction(okay)
                self.present(alert, animated: true, completion: nil)
            }
        }
    }
    
    @objc func hideKeyboard(recognizer: UITapGestureRecognizer){
        self.view.endEditing(true)
    }
}
