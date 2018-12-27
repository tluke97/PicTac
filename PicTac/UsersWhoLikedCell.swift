//
//  UsersWhoLikedCell.swift
//  CorkBoard
//
//  Created by Tanner Luke on 1/17/18.
//  Copyright © 2018 CorkBoard Co. All rights reserved.
//

import UIKit
import Parse

class UsersWhoLikedCell: UITableViewCell {
    
    @IBOutlet weak var profilePic: UIImageView!
    @IBOutlet weak var username: UILabel!
    @IBOutlet weak var followButton: UIButton!
    var lock: String!
    let blueGreenColor = UIColor(displayP3Red: 75/255, green: 239/255, blue: 211/255, alpha: 1)
    let grayColor = UIColor(displayP3Red: 239/255, green: 239/255, blue: 241/255, alpha: 1)
    
    override func awakeFromNib() {
        super.awakeFromNib()
        profilePic.layer.cornerRadius = profilePic.frame.size.width / 2
        profilePic.clipsToBounds = true
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
   
  
    @IBAction func followButton(_ sender: Any) {
        let push = PushNotifications()
        let findLock = PFQuery(className: "_User")
        findLock.whereKey("username", equalTo: self.username.text!)
        findLock.findObjectsInBackground { (objects, error) in
            if error == nil {
                for object in objects! {
                    self.lock = object.object(forKey: "locked") as? String
                    let title = self.followButton.title(for: UIControlState.normal)
                    if title == "Follow" && self.lock == "no" {
                        let object = PFObject(className: "follow")
                        object["follower"] = PFUser.current()?.username
                        object["following"] = self.username.text!
                        object.saveInBackground(block: { (success, error) in
                            if error == nil {
                                self.followButton.setTitle("Following", for: UIControlState.normal)
                                self.followButton.backgroundColor = self.blueGreenColor
                                self.followButton.setTitleColor(.white, for: UIControlState.normal)
                                let notificationObject = PFObject(className: "notification")
                                notificationObject["by"] = PFUser.current()?.username
                                notificationObject["profilepic"] = PFUser.current()?.object(forKey: "profilepic") as! PFFile
                                notificationObject["to"] = self.username.text!
                                notificationObject["owner"] = ""
                                notificationObject["uuid"] = ""
                                notificationObject["type"] = "follow"
                                notificationObject["checked"] = "no"
                                notificationObject.saveInBackground(block: { (success, error) in
                                    if error == nil {
                                        guard let name = self.username.text else {return}
                                        push.pushFollowNotification(username: name)
                                    }
                                })
                            } else {
                                print(error!.localizedDescription)
                            }
                        })
                    } else if title == "Following" {
                        let query = PFQuery(className: "follow")
                        query.whereKey("follower", equalTo: PFUser.current()!.username!)
                        query.whereKey("following", equalTo: self.username.text!)
                        query.findObjectsInBackground(block: { (objects, error) in
                            if error == nil {
                                for object in objects!  {
                                    object.deleteInBackground(block: { (success, error) in
                                        if error == nil {
                                            self.followButton.setTitle("Follow", for: UIControlState.normal)
                                            self.followButton.backgroundColor = .white
                                            self.followButton.setTitleColor(self.blueGreenColor, for: .normal)
                                            self.followButton.layer.borderColor = self.blueGreenColor.cgColor
                                            self.followButton.layer.borderWidth = 1
                                            let notificationQuery = PFQuery(className: "notification")
                                            notificationQuery.whereKey("to", equalTo: self.username.text!)
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
                        object["following"] = self.username.text!
                        object.saveInBackground(block: { (success, error) in
                            if error == nil {
                                self.followButton.setTitle("Requested", for: UIControlState.normal)
                                self.followButton.backgroundColor = self.grayColor
                                self.followButton.layer.borderWidth = 0
                                self.followButton.setTitleColor(self.blueGreenColor, for: .normal)
                                let notificationObject = PFObject(className: "notification")
                                notificationObject["by"] = PFUser.current()?.username
                                notificationObject["profilepic"] = PFUser.current()?.object(forKey: "profilepic") as! PFFile
                                notificationObject["to"] = self.username.text!
                                notificationObject["owner"] = ""
                                notificationObject["uuid"] = ""
                                notificationObject["type"] = "request"
                                notificationObject["checked"] = "no"
                                notificationObject.saveInBackground(block: { (success, error) in
                                    if error == nil {
                                        guard let name = self.username.text else {return}
                                        push.pushRequestNotification(username: name)
                                    }
                                })
                            } else {
                                print(error!.localizedDescription)
                            }
                        })
                    } else if title == "Requested" && self.lock == "yes" {
                        let query = PFQuery(className: "request")
                        query.whereKey("follower", equalTo: PFUser.current()!.username!)
                        query.whereKey("following", equalTo: self.username.text!)
                        query.findObjectsInBackground(block: { (objects, error) in
                            if error == nil {
                                for object in objects! {
                                    object.deleteInBackground(block: { (success, error) in
                                        if error == nil {
                                            self.followButton.setTitle("Requested", for: UIControlState.normal)
                                            self.followButton.backgroundColor = self.grayColor
                                            self.followButton.layer.borderWidth = 0
                                            self.followButton.setTitleColor(self.blueGreenColor, for: .normal)
                                            let notificationQuery = PFQuery(className: "notification")
                                            notificationQuery.whereKey("to", equalTo: self.username.text!)
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
