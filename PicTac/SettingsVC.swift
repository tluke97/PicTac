//
//  SettingsVC.swift
//  CorkBoard
//
//  Created by Tanner Luke on 1/26/18.
//  Copyright © 2018 CorkBoard Co. All rights reserved.
//

import UIKit
import Parse

class SettingsVC: UITableViewController {

    @IBOutlet weak var privateButton: UISwitch!
    @IBOutlet weak var autoPinSwitch: UISwitch!
    var autoPin: Bool!
    var lock: String!
    
    var username: String?
    var fullName: String?
    var profilePic: UIImage?
    
    var canDeleteUser: Bool!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        tableView.isUserInteractionEnabled = true
        
        let findPrivate = PFQuery(className: "_User")
        findPrivate.whereKey("username", equalTo: PFUser.current()!.username!)
        findPrivate.findObjectsInBackground { (objects, error) in
            if error == nil {
                
                for object in objects! {
                    
                    self.lock = object.object(forKey: "locked") as? String
                    
                    if self.lock == "no" {
                        self.privateButton.setOn(false, animated: false)
                    } else {
                        
                        self.privateButton.setOn(true, animated: false)
                        
                    }
                    
                    
                }
                
            }
        }
        
        let findAutoPin = PFQuery(className: "_User")
        findAutoPin.whereKey("username", equalTo: PFUser.current()!.username!)
        findAutoPin.findObjectsInBackground { (objects, error) in
            if error == nil {
                for object in objects! {
                    
                    self.autoPin = object.object(forKey: "autopin") as? Bool
                    
                    if self.autoPin == true {
                        self.autoPinSwitch.setOn(true, animated: false)
                    } else if self.autoPin == false {
                        
                        self.autoPinSwitch.setOn(false, animated: false)
                        
                    }
                    
                }
            }
        }
        

        tableView.tableFooterView = UIView()
        
    }
/*
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
    
  */
    @IBAction func privateSwitch(_ sender: UISwitch) {
        if sender.isOn == true {
            let findUserQuery = PFQuery(className: "_User")
            findUserQuery.whereKey("username", equalTo: PFUser.current()!.username!)
            findUserQuery.findObjectsInBackground(block: { (objects, error) in
                if error == nil {
                    
                    for object in objects! {
                        
                        object["locked"] = "yes"
                        
                        object.saveInBackground(block: { (success, error) in
                            if error == nil {
                                
                                let findPosts = PFQuery(className: "posts")
                                findPosts.whereKey("username", equalTo: PFUser.current()!.username!)
                                findPosts.findObjectsInBackground(block: { (objects, error) in
                                    if error == nil {
                                        for object in objects! {
                                            
                                            object["lock"] = "yes"
                                            
                                            object.saveInBackground(block: { (success, error) in
                                                if error != nil {
                                                    print(error!.localizedDescription)
                                                }
                                            })
                                            
                                        }
                                    } else {
                                        print(error!.localizedDescription)
                                    }
                                })
                                
                                
                                
                                
                            } else {
                                print(error!.localizedDescription)
                            }
                        })
                    }
                    
                }
            })
        } else if sender.isOn == false {
            let findUserQuery = PFQuery(className: "_User")
            findUserQuery.whereKey("username", equalTo: PFUser.current()!.username!)
            findUserQuery.findObjectsInBackground(block: { (objects, error) in
                if error == nil {
                    
                    for object in objects! {
                        
                        object["locked"] = "no"
                        
                        object.saveInBackground(block: { (success, error) in
                            if error == nil {
                                
                                let findPosts = PFQuery(className: "posts")
                                findPosts.whereKey("username", equalTo: PFUser.current()!.username!)
                                findPosts.findObjectsInBackground(block: { (objects, error) in
                                    if error == nil {
                                        for object in objects! {
                                            object["lock"] = "no"
                                            object.saveInBackground(block: { (success, error) in
                                                if error != nil {
                                                    print(error!.localizedDescription)
                                                }
                                            })
                                        }
                                    }
                                })
                                
                                
                            } else {
                                print(error!.localizedDescription)
                            }
                        })
                    }
                    
                }
            })
        }
    }
    
    
    @IBAction func autoPinOnOff(_ sender: Any) {
        
        if self.autoPinSwitch.isOn == true {
            
            let changeToOn = PFQuery(className: "_User")
            changeToOn.findObjectsInBackground { (objects, error) in
                if error == nil {
                    
                    for object in objects! {
                        
                        object["autopin"] = true
                        
                        object.saveEventually()
                        
                    }
                    
                }
            }
            
        } else {
            
            let changeToOff = PFQuery(className: "_User")
            changeToOff.whereKey("username", equalTo: PFUser.current()!.username!)
            changeToOff.findObjectsInBackground { (objects, error) in
                if error == nil {
                    
                    for object in objects! {
                        
                        object["autopin"] = false
                        
                        object.saveEventually()
                        
                    }
                    
                }
            }
            
        }
        
    }
    
    
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 0 {
        
        
        
         
           //let edit = self.storyboard?.instantiateViewController(withIdentifier: "EditVC") as! EditVC
            
           //self.navigationController?.present(edit, animated: true, completion: nil)
            //self.navigationController?.pushViewController(edit, animated: true)
            
            
            self.performSegue(withIdentifier: "Edit", sender: self)
            
        } else if indexPath.row == 3 {
            
            let custom = self.storyboard?.instantiateViewController(withIdentifier: "CustomProfileVC") as! CustomProfileVC
            custom.fullnameText = self.fullName
            custom.usernameText = self.username
            custom.profileImage = self.profilePic
            self.navigationController?.pushViewController(custom, animated: true)
            
           
            
        } else if indexPath.row == 4 {
            
            alert(title: "Logout", message: "Are you sure you want to log out?")
            
        } else if indexPath.row == 5 {
            
            deleteAlert(title: "Are you sure?", message: "By clicking yes, your data will be deleted and will not be able to be recovered.")
            
        }
        
        
        
    }
    
    func deleteAlert(title: String, message: String) {
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
        let cancel = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel, handler: nil)
        let delete = UIAlertAction(title: "Delete", style: UIAlertActionStyle.destructive) { (alert: UIAlertAction!) in
            print("deleting user")
            
            let followerQuery = PFQuery(className: "follow")
            followerQuery.whereKey("following", equalTo: PFUser.current()!.username!)
            followerQuery.findObjectsInBackground(block: { (objects, error) in
                if error == nil {
                    
                    for object in objects! {
                        
                        object.deleteInBackground(block: { (success, error) in
                            if error == nil {
                                print("deleted")
                            }
                        })
                        
                    }
                    
                }
            })
            
            let followedQuery = PFQuery(className: "follow")
            followedQuery.whereKey("follower", equalTo: PFUser.current()!.username!)
            followedQuery.findObjectsInBackground(block: { (objects, error) in
                if error == nil {
                    
                    for object in objects! {
                        
                        object.deleteInBackground(block: { (success, error) in
                            if error == nil {
                                
                                print("followers deleted")
                                
                            }
                        })
                        
                    }
                    
                }
            })
            
            let commentQuery = PFQuery(className: "comments")
            commentQuery.whereKey("username", equalTo: PFUser.current()!.username!)
            commentQuery.findObjectsInBackground(block: { (objects, error) in
                if error == nil {
                    
                    for object in objects! {
                        
                        object.deleteInBackground(block: { (success, error) in
                            if error == nil {
                                print("comments deleted")
                            }
                        })
                        
                    }
                    
                    
                }
            })
            
            let likeQuery = PFQuery(className: "likes")
            likeQuery.whereKey("by", equalTo: PFUser.current()!.username!)
            likeQuery.findObjectsInBackground(block: { (objects, error) in
                if error == nil {
                    
                    for object in objects! {
                        
                        object.deleteInBackground(block: { (success, error) in
                            if error == nil {
                                
                                print("likes deleted")
                                
                            }
                        })
                        
                    }
                    
                }
            })
            
            let notificationToQuery = PFQuery(className: "notification")
            notificationToQuery.whereKey("to", equalTo: PFUser.current()!.username!)
            notificationToQuery.findObjectsInBackground(block: { (objects, error) in
                if error == nil {
                    
                    for object in objects! {
                        
                        object.deleteInBackground(block: { (success, error) in
                            if error == nil {
                                print("notifications to deleted")
                            }
                        })
                        
                    }
                    
                }
            })
            
            let notificationByQuery = PFQuery(className: "notification")
            notificationByQuery.whereKey("by", equalTo: PFUser.current()!.username!)
            notificationByQuery.findObjectsInBackground(block: { (objects, error) in
                if error == nil {
                    
                    for object in objects! {
                        
                        object.deleteInBackground(block: { (success, error) in
                            if error == nil {
                                print("notifications by deleted")
                            }
                        })
                        
                    }
                    
                }
            })
            
            let postQuery = PFQuery(className: "posts")
            postQuery.whereKey("username", equalTo: PFUser.current()!.username!)
            postQuery.findObjectsInBackground(block: { (objects, error) in
                if error == nil {
                    
                    for object in objects! {
                        
                        object.deleteInBackground(block: { (success, error) in
                            if error == nil {
                                print("posts deleted")
                            }
                        })
                        
                        
                    }
                    
                    
                    
                    
                }
            })
            
            let requestToQuery = PFQuery(className: "request")
            requestToQuery.whereKey("following", equalTo: PFUser.current()!.username!)
            requestToQuery.findObjectsInBackground(block: { (objects, error) in
                if error == nil {
                    for object in objects! {
                        
                        object.deleteInBackground(block: { (success, error) in
                            if error == nil {
                                print("requests to deleted")
                            }
                        })
                        
                    }
                }
            })
            
            let requestByQuery = PFQuery(className: "request")
            requestByQuery.whereKey("follower", equalTo: PFUser.current()!.username!)
            requestByQuery.findObjectsInBackground(block: { (objects, error) in
                if error == nil {
                    
                    for object in objects! {
                        object.deleteInBackground(block: { (success, error) in
                            print("requests by are deleted")
                        })
                    }
                    
                }
            })
            
            
            
            
            if PFUser.current() != nil {
                PFUser.current()?.deleteInBackground(block: { (success, error) in
                    if error == nil {
                        
                        PFUser.logOutInBackground { (error) in
                            if error == nil {
                                UserDefaults.standard.removeObject(forKey: "username")
                                
                                
                                UserDefaults.standard.synchronize()
                                
                                PFUser.enableAutomaticUser()
                                
                                let signIn = self.storyboard?.instantiateViewController(withIdentifier: "SignInVC") as! SignInVC
                                let appDelegate: AppDelegate = UIApplication.shared.delegate as! AppDelegate
                                appDelegate.window?.rootViewController = signIn
                                
                                
                                
                                
                            }
                        }
                        
                    }
                })
            }
            
            
            
            
            
            
            
            
        }
        alert.addAction(cancel)
        alert.addAction(delete)
        present(alert, animated: true, completion: nil)
    }
    
    func alert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
        let ok = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel, handler: nil)
        let logout = UIAlertAction(title: "Logout", style: UIAlertActionStyle.destructive) { (alert: UIAlertAction!) in
            print("logout")
            
            PFUser.logOutInBackground { (error) in
                if error == nil {
                    UserDefaults.standard.removeObject(forKey: "username")
                    
                    
                    UserDefaults.standard.synchronize()
                    
                    PFUser.enableAutomaticUser()
                    
                    let signIn = self.storyboard?.instantiateViewController(withIdentifier: "SignInVC") as! SignInVC
                    let appDelegate: AppDelegate = UIApplication.shared.delegate as! AppDelegate
                    appDelegate.window?.rootViewController = signIn
                    
                    
                    
                    
                }
            }
            
            
        }
        alert.addAction(ok)
        alert.addAction(logout)
        present(alert, animated: true, completion: nil)
    
    
    }
    
}
