//
//  RequestCell.swift
//  CorkBoard
//
//  Created by Tanner Luke on 4/6/18.
//  Copyright © 2018 CorkBoard Co. All rights reserved.
//

import UIKit
import Parse



class RequestCell: UITableViewCell {
    
    @IBOutlet weak var profilePic: UIImageView!
    @IBOutlet weak var username: UIButton!
    @IBOutlet weak var info: UILabel!
    @IBOutlet weak var date: UILabel!
    @IBOutlet weak var follow: UIButton!
    @IBOutlet weak var ignore: UIButton!
    @IBOutlet weak var buttonStack: UIStackView!
    @IBOutlet weak var followBackButton: UIButton!
    var lock: String!
    var isLocked: String!
    let grayColor = UIColor(displayP3Red: 239/255, green: 239/255, blue: 241/255, alpha: 1)
    
    let color = UIColor(displayP3Red: 75/255, green: 239/255, blue: 211/255, alpha: 1)
    
    let generator = UIImpactFeedbackGenerator(style: .medium)

    override func awakeFromNib() {
        super.awakeFromNib()
        setFollowBackButton()
        generator.prepare()
        followBackButton.isHidden = true
        profilePic.layer.cornerRadius = profilePic.frame.size.width/2
        profilePic.clipsToBounds = true
    }
    
    func setFollowBackButton() {
        let followQuery = PFQuery(className: "follow")
        followQuery.whereKey("follower", equalTo: PFUser.current()!.username!)
        followQuery.whereKey("following", equalTo: username.titleLabel!.text!)
        followQuery.countObjectsInBackground { (count, error) in
            if error == nil {
                if count == 0 {
                    let requestQuery = PFQuery(className: "request")
                    requestQuery.whereKey("follower", equalTo: PFUser.current()!.username!)
                    requestQuery.whereKey("following", equalTo: self.username.titleLabel!.text!)
                    requestQuery.countObjectsInBackground(block: { (count, error) in
                        if error == nil {
                            if count == 0 {
                                self.followBackButton.setTitle("Follow", for: UIControlState())
                                self.followBackButton.backgroundColor = .white
                                self.followBackButton.setTitleColor(UIColor(displayP3Red: 75/255, green: 239/255, blue: 211/255, alpha: 1), for: .normal)
                                self.followBackButton.layer.borderWidth = 1
                                self.followBackButton.layer.borderColor = UIColor(displayP3Red: 75/255, green: 239/255, blue: 211/255, alpha: 1).cgColor
                            } else {
                                self.followBackButton.setTitle("Requested", for: UIControlState.normal)
                                self.followBackButton.backgroundColor = self.grayColor
                                self.followBackButton.layer.borderWidth = 0
                                self.followBackButton.setTitleColor(UIColor(displayP3Red: 75/255, green: 239/255, blue: 211/255, alpha: 1), for: .normal)
                            }
                        }
                    })
                } else {
                    self.followBackButton.setTitle("Following", for: UIControlState())
                    self.followBackButton.backgroundColor = UIColor(displayP3Red: 75/255, green: 239/255, blue: 211/255, alpha: 1)
                    self.followBackButton.setTitleColor(.white, for: UIControlState())
                }
            } else {
                print(error!.localizedDescription)
            }
        }
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    @IBAction func followButtonClick(_ sender: Any) {
        generator.impactOccurred()
        let object = PFObject(className: "follow")
        object["follower"] = self.username.titleLabel?.text!
        object["following"] = PFUser.current()?.username!
        object.saveInBackground { (success, error) in
            if error == nil {
                self.info.text = "followed you"
                self.ignore.isHidden = true
                self.follow.isHidden = true
                self.followBackButton.isHidden = false
                let notification = PFQuery(className: "notification")
                notification.whereKey("to", equalTo: PFUser.current()?.username! as Any)
                notification.whereKey("type", equalTo: "request")
                notification.whereKey("by", equalTo: self.username.titleLabel?.text! as Any)
                notification.findObjectsInBackground(block: { (objects, error) in
                    if error == nil {
                        for object in objects! {
                            object["type"] = "follow"
                            object.saveInBackground(block: { (success, error) in
                                if error == nil {
                                    //let push = PushNotifications()
                                    //guard let name = self.username.titleLabel?.text else {return}
                                    //push.pushFollowNotification(username: name)
                                }
                            })
                       }
                    }
                })
                
                
                let deleteRequest = PFQuery(className: "request")
                deleteRequest.whereKey("following", equalTo: PFUser.current()!.username!)
                deleteRequest.whereKey("follower", equalTo: self.username.titleLabel!.text!)
                deleteRequest.findObjectsInBackground(block: { (objects, error) in
                    if error == nil {
                        for object in objects! {
                            object.deleteEventually()
                        }
                    }
                })
            
                let isUserFollowing = PFQuery(className: "follow")
                isUserFollowing.whereKey("follower", equalTo: PFUser.current()!.username!)
                isUserFollowing.whereKey("following", equalTo: self.username.titleLabel!.text!)
                isUserFollowing.countObjectsInBackground(block: { (count, error) in
                    if error == nil {
                        
                        if count != 0 {
                            
                            
                            
                        } else {
                        
                            NotificationCenter.default.post(name: NSNotification.Name("reloadTableCell"), object: nil)
                        }
                        
                    } else {
                        print(error!.localizedDescription)
                    }
                })
                
                
                
                
                
                
                let findLock = PFQuery(className: "_User")
                findLock.whereKey("username", equalTo: self.username.titleLabel!.text!)
                findLock.findObjectsInBackground { (objects, error) in
                    if error == nil {
                        for object in objects! {
                            self.isLocked = object.object(forKey: "locked") as? String
                            let title = self.followBackButton.title(for: UIControlState.normal)
                            if title == "Follow" && self.isLocked == "no" {
                                let object = PFObject(className: "follow")
                                object["follower"] = PFUser.current()?.username
                                object["following"] = self.username.titleLabel!.text!
                                object.saveInBackground(block: { (success, error) in
                                    if error == nil {
                                        self.followBackButton.setTitle("Following", for: UIControlState.normal)
                                        self.followBackButton.backgroundColor = self.color
                                        self.followBackButton.setTitleColor(.white, for: UIControlState.normal)
                                        let notificationObject = PFObject(className: "notification")
                                        notificationObject["by"] = PFUser.current()?.username
                                        notificationObject["profilepic"] = PFUser.current()?.object(forKey: "profilepic") as! PFFile
                                        notificationObject["to"] = self.username.titleLabel!.text!
                                        notificationObject["owner"] = ""
                                        notificationObject["uuid"] = ""
                                        notificationObject["type"] = "follow"
                                        notificationObject["checked"] = "no"
                                        notificationObject.saveInBackground(block: { (success, error) in
                                            if error == nil {
                                                
                                                let push = PushNotifications()
                                                push.pushFollowNotification(username: self.username.titleLabel!.text!)
                                                
                                            }
                                        })
                                    } else {
                                        
                                        print(error!.localizedDescription)
                                    }
                                })
                            } else if title == "Following" {
                                let query = PFQuery(className: "follow")
                                query.whereKey("follower", equalTo: PFUser.current()!.username!)
                                query.whereKey("following", equalTo: self.username.titleLabel!.text!)
                                query.findObjectsInBackground(block: { (objects, error) in
                                    if error == nil {
                                        for object in objects!  {
                                            object.deleteInBackground(block: { (success, error) in
                                                if error == nil {
                                                    self.followBackButton.setTitle("Follow", for: UIControlState.normal)
                                                    self.followBackButton.backgroundColor = .white
                                                    self.followBackButton.layer.borderWidth = 1
                                                    self.followBackButton.layer.borderColor = self.color.cgColor
                                                    self.followBackButton.setTitleColor(self.color, for: UIControlState.normal)
                                                    let notificationQuery = PFQuery(className: "notification")
                                                    notificationQuery.whereKey("to", equalTo: self.username.titleLabel!.text!)
                                                    notificationQuery.whereKey("by", equalTo: PFUser.current()!.username!)
                                                    notificationQuery.whereKey("type", equalTo: "follow")
                                                    notificationQuery.findObjectsInBackground(block: { (objects, error) in
                                                        if error == nil {
                                                            for object in objects! {
                                                                object.deleteEventually()
                                                            }
                                                        }
                                                    })
                                                } else {
                                                    print(error!.localizedDescription)
                                                }
                                            })
                                        }
                                    } else {
                                        print(error!.localizedDescription)
                                    }
                                })
                            } else if title == "Follow" && self.isLocked == "yes" {
                                let object = PFObject(className: "request")
                                object["follower"] = PFUser.current()?.username
                                object["following"] = self.username.titleLabel!.text!
                                object.saveInBackground(block: { (success, error) in
                                    if error == nil {
                                        self.followBackButton.setTitle("Requested", for: UIControlState.normal)
                                        self.followBackButton.backgroundColor = self.grayColor
                                        self.followBackButton.setTitleColor(UIColor(displayP3Red: 75/255, green: 239/255, blue: 211/255, alpha: 1), for: UIControlState.normal)
                                        self.followBackButton.layer.borderWidth = 0
                                        let notificationObject = PFObject(className: "notification")
                                        notificationObject["by"] = PFUser.current()?.username
                                        notificationObject["profilepic"] = PFUser.current()?.object(forKey: "profilepic") as! PFFile
                                        notificationObject["to"] = self.username.titleLabel!.text!
                                        notificationObject["owner"] = ""
                                        notificationObject["uuid"] = ""
                                        notificationObject["type"] = "request"
                                        notificationObject["checked"] = "no"
                                        notificationObject.saveInBackground(block: { (success, error) in
                                            if error == nil {
                                                let push = PushNotifications()
                                                push.pushRequestNotification(username: self.username.titleLabel!.text!)
                                            }
                                        })
                                    } else {
                                        print(error!.localizedDescription)
                                    }
                                })
                            } else if title == "Requested" && self.isLocked == "yes" {
                                let query = PFQuery(className: "request")
                                query.whereKey("follower", equalTo: PFUser.current()!.username!)
                                query.whereKey("following", equalTo: self.username.titleLabel!.text!)
                                query.findObjectsInBackground(block: { (objects, error) in
                                    if error == nil {
                                        for object in objects! {
                                            object.deleteInBackground(block: { (success, error) in
                                                if error == nil {
                                                    self.followBackButton.setTitle("Follow", for: UIControlState.normal)
                                                    self.followBackButton.backgroundColor = .white
                                                    self.followBackButton.layer.borderWidth = 1
                                                    self.followBackButton.layer.borderColor = self.color.cgColor
                                                    self.followBackButton.setTitleColor(self.color, for: .normal)
                                                    let notificationQuery = PFQuery(className: "notification")
                                                    notificationQuery.whereKey("to", equalTo: self.username.titleLabel!.text!)
                                                    notificationQuery.whereKey("by", equalTo: PFUser.current()!.username!)
                                                    notificationQuery.whereKey("type", equalTo: "request")
                                                    notificationQuery.findObjectsInBackground(block: { (objects, error) in
                                                        if error == nil {
                                                            for object in objects! {
                                                                object.deleteEventually()
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
                    }
                }
                
                
                
                
                
                
                
                
                
                
            
            
            }
            
        }
    }

    @IBAction func ignoreButtonClick(_ sender: Any) {
        generator.impactOccurred()
        let notification = PFQuery(className: "notification")
        notification.whereKey("to", equalTo: PFUser.current()?.username! as Any)
        notification.whereKey("type", equalTo: "request")
        notification.whereKey("by", equalTo: self.username.titleLabel?.text! as Any)
        notification.findObjectsInBackground(block: { (objects, error) in
            if error == nil {
                for object in objects! {
                    object["type"] = "follow"
                    object.deleteInBackground(block: { (success, error) in
                        if error == nil {
                            NotificationCenter.default.post(name: NSNotification.Name("reloadTableCell"), object: nil)
                        }
                    })
                }
            }
        })
        self.ignore.isHidden = true
        self.follow.isHidden = true
        
    }
    
    @IBAction func followBackClick(_ sender: Any) {
        generator.impactOccurred()
        let findLock = PFQuery(className: "_User")
        findLock.whereKey("username", equalTo: self.username.titleLabel!.text!)
        findLock.findObjectsInBackground { (objects, error) in
            if error == nil {
                for object in objects! {
                    self.lock = object.object(forKey: "locked") as? String
                    let title = self.followBackButton.title(for: UIControlState.normal)
                    if title == "Follow" && self.lock == "no" {
                        let object = PFObject(className: "follow")
                        object["follower"] = PFUser.current()?.username
                        object["following"] = self.username.titleLabel?.text
                        object.saveInBackground(block: { (success, error) in
                            if error == nil {
                                self.followBackButton.setTitle("Following", for: UIControlState.normal)
                                self.followBackButton.backgroundColor = UIColor(displayP3Red: 75/255, green: 239/255, blue: 211/255, alpha: 1)
                                self.followBackButton.setTitleColor(.white, for: UIControlState.normal)
                                let notificationObject = PFObject(className: "notification")
                                notificationObject["by"] = PFUser.current()?.username
                                notificationObject["profilepic"] = PFUser.current()?.object(forKey: "profilepic") as! PFFile
                                notificationObject["to"] = self.username.titleLabel?.text
                                notificationObject["owner"] = ""
                                notificationObject["uuid"] = ""
                                notificationObject["type"] = "follow"
                                notificationObject["checked"] = "no"
                                notificationObject.saveInBackground(block: { (success, error) in
                                    if error == nil {
                                        let push = PushNotifications()
                                        guard let name = friendName.last else {return}
                                        push.pushFollowNotification(username: name)
                                        NotificationCenter.default.post(name: NSNotification.Name("reloadTableCell"), object: nil)
                                    }
                                })
                            }
                            else{
                                print(error!.localizedDescription)
                            }
                        })
                    } else if title == "Following" {
                        let query = PFQuery(className: "follow")
                        query.whereKey("follower", equalTo: PFUser.current()!.username!)
                        query.whereKey("following", equalTo: self.username.titleLabel!.text!)
                        query.findObjectsInBackground(block: { (objects, error) in
                            if error == nil {
                                for object in objects!  {
                                    object.deleteInBackground(block: { (success, error) in
                                        if error == nil {
                                            self.followBackButton.setTitle("Follow", for: UIControlState.normal)
                                            self.followBackButton.backgroundColor = .white
                                            self.followBackButton.setTitleColor(UIColor(displayP3Red: 75/255, green: 239/255, blue: 211/255, alpha: 1), for: .normal)
                                            self.followBackButton.layer.borderColor = UIColor(displayP3Red: 75/255, green: 239/255, blue: 211/255, alpha: 1).cgColor
                                            self.followBackButton.layer.borderWidth = 1
                                            let notificationQuery = PFQuery(className: "notification")
                                            notificationQuery.whereKey("to", equalTo: self.username.titleLabel!.text!)
                                            notificationQuery.whereKey("by", equalTo: PFUser.current()!.username!)
                                            notificationQuery.whereKey("type", equalTo: "follow")
                                            notificationQuery.findObjectsInBackground(block: { (objects, error) in
                                                if error == nil {
                                                    for object in objects! {
                                                        object.deleteEventually()
                                                    }
                                                }
                                            })
                                        } else {
                                            print(error!.localizedDescription)
                                        }
                                    })
                                }
                            } else {
                                print(error!.localizedDescription)
                            }
                        })
                    } else if title == "Follow" && self.lock == "yes" {
                        let object = PFObject(className: "request")
                        object["follower"] = PFUser.current()?.username
                        object["following"] = self.username.titleLabel!.text!
                        object.saveInBackground(block: { (success, error) in
                            if error == nil {
                                self.followBackButton.setTitle("Requested", for: UIControlState.normal)
                                self.followBackButton.backgroundColor = self.grayColor
                                self.followBackButton.layer.borderWidth = 0
                                self.followBackButton.setTitleColor(UIColor(displayP3Red: 75/255, green: 239/255, blue: 211/255, alpha: 1), for: UIControlState.normal)
                                let notificationObject = PFObject(className: "notification")
                                notificationObject["by"] = PFUser.current()?.username
                                notificationObject["profilepic"] = PFUser.current()?.object(forKey: "profilepic") as! PFFile
                                notificationObject["to"] = self.username.titleLabel!.text!
                                notificationObject["owner"] = ""
                                notificationObject["uuid"] = ""
                                notificationObject["type"] = "request"
                                notificationObject["checked"] = "no"
                                notificationObject.saveInBackground(block: { (success, error) in
                                    if error == nil {
                                        let push = PushNotifications()
                                        guard let name = friendName.last else { return }
                                        push.pushRequestNotification(username: name)
                                        NotificationCenter.default.post(name: NSNotification.Name("reloadTableCell"), object: nil)
                                        
                                    }
                                })
                            } else {
                                print(error!.localizedDescription)
                            }
                        })
                    } else if title == "Requested" && self.lock == "yes" {
                        let query = PFQuery(className: "request")
                        query.whereKey("follower", equalTo: PFUser.current()!.username!)
                        query.whereKey("following", equalTo: self.username.titleLabel!.text!)
                        query.findObjectsInBackground(block: { (objects, error) in
                            if error == nil {
                                for object in objects! {
                                    object.deleteInBackground(block: { (success, error) in
                                        if error == nil {
                                            self.followBackButton.setTitle("Follow", for: UIControlState.normal)
                                            self.followBackButton.backgroundColor = .white
                                            self.followBackButton.layer.borderColor = UIColor(displayP3Red: 75/255, green: 239/255, blue: 211/255, alpha: 1).cgColor
                                            self.followBackButton.layer.borderWidth = 1
                                            let notificationQuery = PFQuery(className: "notification")
                                            notificationQuery.whereKey("to", equalTo: self.username.titleLabel!.text!)
                                            notificationQuery.whereKey("by", equalTo: PFUser.current()!.username!)
                                            notificationQuery.whereKey("type", equalTo: "request")
                                            notificationQuery.findObjectsInBackground(block: { (objects, error) in
                                                if error == nil {
                                                    for object in objects! {
                                                        object.deleteEventually()
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
            }
        }
    }
}
