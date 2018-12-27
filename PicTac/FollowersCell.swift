//
//  FollowersCell.swift
//  CorkBoard
//
//  Created by Tanner Luke on 10/17/17.
//  Copyright © 2017 CorkBoard Co. All rights reserved.
//

import UIKit
import Parse

class FollowersCell: UITableViewCell {
    
    @IBOutlet weak var userProfilePic: UIImageView!
    @IBOutlet weak var followerUsername: UILabel!
    @IBOutlet weak var followButton: UIButton!
    let grayColor = UIColor(displayP3Red: 239/255, green: 239/255, blue: 241/255, alpha: 1)
    let color = UIColor(displayP3Red: 75/255, green: 239/255, blue: 211/255, alpha: 1)
    var lock: String!
    
    let generator = UIImpactFeedbackGenerator(style: .light)
   
    override func awakeFromNib() {
        super.awakeFromNib()
        generator.prepare()
        userProfilePic.layer.cornerRadius = userProfilePic.frame.size.width / 2
        userProfilePic.clipsToBounds = true
    }
    
    @IBAction func followButtonClicked(_ sender: Any) {
        generator.impactOccurred()
        let findLock = PFQuery(className: "_User")
        findLock.whereKey("username", equalTo: self.followerUsername.text!)
        findLock.findObjectsInBackground { (objects, error) in
            if error == nil {
                for object in objects! {
                    self.lock = object.object(forKey: "locked") as? String
                    let title = self.followButton.title(for: UIControlState.normal)
                    if title == "Follow" && self.lock == "no" {
                        let object = PFObject(className: "follow")
                        object["follower"] = PFUser.current()?.username
                        object["following"] = self.followerUsername.text!
                        object.saveInBackground(block: { (success, error) in
                            if error == nil {
                                self.followButton.setTitle("Following", for: UIControlState.normal)
                                self.followButton.backgroundColor = self.color
                                self.followButton.setTitleColor(.white, for: UIControlState.normal)
                                let notificationObject = PFObject(className: "notification")
                                notificationObject["by"] = PFUser.current()?.username
                                notificationObject["profilepic"] = PFUser.current()?.object(forKey: "profilepic") as! PFFile
                                notificationObject["to"] = self.followerUsername.text!
                                notificationObject["owner"] = ""
                                notificationObject["uuid"] = ""
                                notificationObject["type"] = "follow"
                                notificationObject["checked"] = "no"
                                notificationObject.saveInBackground(block: { (success, error) in
                                    if error == nil {
                                        
                                        let push = PushNotifications()
                                        push.pushFollowNotification(username: self.followerUsername.text!)
                                        
                                    }
                                })
                            } else {
                                
                                print(error!.localizedDescription)
                            }
                        })
                    } else if title == "Following" {
                        let query = PFQuery(className: "follow")
                        query.whereKey("follower", equalTo: PFUser.current()!.username!)
                        query.whereKey("following", equalTo: self.followerUsername.text!)
                        query.findObjectsInBackground(block: { (objects, error) in
                            if error == nil {
                                for object in objects!  {
                                    object.deleteInBackground(block: { (success, error) in
                                        if error == nil {
                                            self.followButton.setTitle("Follow", for: UIControlState.normal)
                                            self.followButton.backgroundColor = .white
                                            self.followButton.layer.borderWidth = 1
                                            self.followButton.layer.borderColor = self.color.cgColor
                                            self.followButton.setTitleColor(self.color, for: UIControlState.normal)
                                            let notificationQuery = PFQuery(className: "notification")
                                            notificationQuery.whereKey("to", equalTo: self.followerUsername.text!)
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
                        object["following"] = self.followerUsername.text!
                        object.saveInBackground(block: { (success, error) in
                            if error == nil {
                                self.followButton.setTitle("Requested", for: UIControlState.normal)
                                self.followButton.backgroundColor = self.grayColor
                                self.followButton.setTitleColor(UIColor(displayP3Red: 75/255, green: 239/255, blue: 211/255, alpha: 1), for: UIControlState.normal)
                                self.followButton.layer.borderWidth = 0
                                let notificationObject = PFObject(className: "notification")
                                notificationObject["by"] = PFUser.current()?.username
                                notificationObject["profilepic"] = PFUser.current()?.object(forKey: "profilepic") as! PFFile
                                notificationObject["to"] = self.followerUsername.text!
                                notificationObject["owner"] = ""
                                notificationObject["uuid"] = ""
                                notificationObject["type"] = "request"
                                notificationObject["checked"] = "no"
                                notificationObject.saveInBackground(block: { (success, error) in
                                    if error == nil {
                                        let push = PushNotifications()
                                        push.pushRequestNotification(username: self.followerUsername.text!)
                                    }
                                })
                            } else {
                                print(error!.localizedDescription)
                            }
                        })
                    } else if title == "Requested" && self.lock == "yes" {
                        let query = PFQuery(className: "request")
                        query.whereKey("follower", equalTo: PFUser.current()!.username!)
                        query.whereKey("following", equalTo: self.followerUsername.text!)
                        query.findObjectsInBackground(block: { (objects, error) in
                            if error == nil {
                                for object in objects! {
                                    object.deleteInBackground(block: { (success, error) in
                                        if error == nil {
                                            self.followButton.setTitle("Follow", for: UIControlState.normal)
                                            self.followButton.backgroundColor = .white
                                            self.followButton.layer.borderWidth = 1
                                            self.followButton.layer.borderColor = self.color.cgColor
                                            self.followButton.setTitleColor(self.color, for: .normal)
                                            let notificationQuery = PFQuery(className: "notification")
                                            notificationQuery.whereKey("to", equalTo: self.followerUsername.text!)
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
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}
