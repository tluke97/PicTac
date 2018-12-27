//
//  NotificationCell.swift
//  CorkBoard
//
//  Created by Tanner Luke on 12/19/17.
//  Copyright © 2017 CorkBoard Co. All rights reserved.
//

import UIKit
import Parse

class NotificationCell: UITableViewCell {
    
    @IBOutlet weak var profilePic: UIImageView!
    @IBOutlet weak var username: UIButton!
    @IBOutlet weak var date: UILabel!
    @IBOutlet weak var follow: UIButton!
    @IBOutlet weak var ignore: UIButton!
    @IBOutlet weak var info: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        info.textAlignment = .left
        profilePic.frame = CGRect(x: 0, y: 0, width: 45, height: 45)
        profilePic.layer.cornerRadius = profilePic.frame.size.width / 2
        profilePic.clipsToBounds = true
    }

    @IBAction func followButtonClick(_ sender: Any) {
        let object = PFObject(className: "follow")
        object["follower"] = self.username.titleLabel?.text!
        object["following"] = PFUser.current()?.username!
        object.saveInBackground { (success, error) in
            if error == nil {
                self.info.text = "followed you"
                self.ignore.isHidden = true
                self.follow.isHidden = true
                let notification = PFQuery(className: "notification")
                notification.whereKey("to", equalTo: PFUser.current()?.username! as Any)
                notification.whereKey("type", equalTo: "request")
                notification.whereKey("by", equalTo: self.username.titleLabel?.text! as Any)
                notification.findObjectsInBackground(block: { (objects, error) in
                    if error == nil {
                        for object in objects! {
                        object["type"] = "follow"
                        object.saveEventually()
                        }
                    }
                })
            }
        }
    }
    
    @IBAction func ignoreButtonClick(_ sender: Any) {
        let notification = PFQuery(className: "notification")
        notification.whereKey("to", equalTo: PFUser.current()?.username! as Any)
        notification.whereKey("type", equalTo: "request")
        notification.whereKey("by", equalTo: self.username.titleLabel?.text! as Any)
        notification.findObjectsInBackground(block: { (objects, error) in
            if error == nil {
                for object in objects! {
                    object["type"] = "follow"
                    object.deleteEventually()
                }
            }
        })
        self.ignore.isHidden = true
        self.follow.isHidden = true
    }
}
