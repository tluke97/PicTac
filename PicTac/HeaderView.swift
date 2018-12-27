//
//  HeaderView.swift
//  CorkBoard
//
//  Created by Tanner Luke on 10/15/17.
//  Copyright © 2017 CorkBoard Co. All rights reserved.
//

import UIKit
import Parse

class HeaderView: UICollectionReusableView {
    @IBOutlet weak var profilePic: UIImageView!
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var username: UILabel!
    @IBOutlet weak var following: UILabel!
    @IBOutlet weak var followers: UILabel!
    @IBOutlet weak var posts: UILabel!
    @IBOutlet weak var followingTitle: UILabel!
    @IBOutlet weak var followersTitle: UILabel!
    @IBOutlet weak var postsTitle: UILabel!
    @IBOutlet weak var profileButton: UIButton!
    @IBOutlet weak var bio: UITextView!
    @IBOutlet weak var followingStack: UIStackView!
    @IBOutlet weak var followersStack: UIStackView!
    @IBOutlet weak var postStack: UIStackView!
    @IBOutlet weak var line: UIView!
    let generator = UIImpactFeedbackGenerator(style: UIImpactFeedbackStyle.light)
    weak var shapeLayer: CAShapeLayer?
    weak var shapeLayer1: CAShapeLayer?
    
    
    @IBOutlet weak var followingView: UIView!
    
    @IBOutlet weak var checkTextHeight: UITextView!
    
    let grayColor = UIColor(displayP3Red: 239/255, green: 239/255, blue: 241/255, alpha: 1)
    let blueColor = UIColor(displayP3Red: 75/255, green: 239/255, blue: 211/255, alpha: 1)
    var lock: String!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.28) {
            self.animate()
        }
        
        generator.prepare()
        //bio.sizeToFit()
        profilePic.layer.cornerRadius = profilePic.frame.size.width / 2
        profilePic.clipsToBounds = true
        bio.textContainerInset = UIEdgeInsets(top: 5, left: 0, bottom: 5, right: 0)
        bio.textContainer.lineFragmentPadding = 0
        
        
        
    }
    
    
    
    @IBAction func followButtonClick(_ sender: Any) {
        generator.impactOccurred()
        let findLock = PFQuery(className: "_User")
        findLock.whereKey("username", equalTo: self.username.text!.dropFirst())
        findLock.findObjectsInBackground { (objects, error) in
            if error == nil {
                for object in objects! {
                    self.lock = object.object(forKey: "locked") as? String
                    let title = self.profileButton.title(for: UIControlState.normal)
                    if title == "Follow" && self.lock == "no" {
                        let object = PFObject(className: "follow")
                        object["follower"] = PFUser.current()?.username
                        object["following"] = friendName.last!
                        object.saveInBackground(block: { (success, error) in
                            if error == nil {
                                self.profileButton.setTitle("Following", for: UIControlState.normal)
                                self.profileButton.backgroundColor = UIColor(displayP3Red: 75/255, green: 239/255, blue: 211/255, alpha: 1)
                                self.profileButton.setTitleColor(.white, for: UIControlState.normal)
                                let notificationObject = PFObject(className: "notification")
                                notificationObject["by"] = PFUser.current()?.username
                                notificationObject["profilepic"] = PFUser.current()?.object(forKey: "profilepic") as! PFFile
                                notificationObject["to"] = friendName.last
                                notificationObject["owner"] = ""
                                notificationObject["uuid"] = ""
                                notificationObject["type"] = "follow"
                                notificationObject["checked"] = "no"
                                notificationObject.saveInBackground(block: { (success, error) in
                                    if error == nil {
                                        let push = PushNotifications()
                                        push.pushFollowNotification(username: friendName.last!)
                                    }
                                })
                            } else {
                                
                                print(error!.localizedDescription)
                            }
                        })
                    } else if title == "Following" {
                        let query = PFQuery(className: "follow")
                        query.whereKey("follower", equalTo: PFUser.current()!.username!)
                        query.whereKey("following", equalTo: friendName.last!)
                        query.findObjectsInBackground(block: { (objects, error) in
                            if error == nil {
                                for object in objects!  {
                                    object.deleteInBackground(block: { (success, error) in
                                        if error == nil {
                                            self.profileButton.setTitle("Follow", for: UIControlState.normal)
                                                self.profileButton.backgroundColor = .white
                                                self.profileButton.setTitleColor(UIColor(displayP3Red: 75/255, green: 239/255, blue: 211/255, alpha: 1), for: .normal)
                                                self.profileButton.layer.borderColor = UIColor(displayP3Red: 75/255, green: 239/255, blue: 211/255, alpha: 1).cgColor
                                                self.profileButton.layer.borderWidth = 1
                                                let notificationQuery = PFQuery(className: "notification")
                                                notificationQuery.whereKey("to", equalTo: friendName.last!)
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
                            object["following"] = friendName.last!
                            object.saveInBackground(block: { (success, error) in
                                if error == nil {
                                    self.profileButton.setTitle("Requested", for: UIControlState.normal)
                                    self.profileButton.backgroundColor = self.grayColor
                                    self.profileButton.layer.borderWidth = 0
                                    self.profileButton.setTitleColor(UIColor(displayP3Red: 75/255, green: 239/255, blue: 211/255, alpha: 1), for: UIControlState.normal)
                                    let notificationObject = PFObject(className: "notification")
                                    notificationObject["by"] = PFUser.current()?.username
                                    notificationObject["profilepic"] = PFUser.current()?.object(forKey: "profilepic") as! PFFile
                                    notificationObject["to"] = friendName.last
                                    notificationObject["owner"] = ""
                                    notificationObject["uuid"] = ""
                                    notificationObject["type"] = "request"
                                    notificationObject["checked"] = "no"
                                    notificationObject.saveInBackground(block: { (success, error) in
                                        if error == nil {
                                            let push = PushNotifications()
                                            push.pushRequestNotification(username: friendName.last!)
                                        }
                                    })
                                } else {
                                 
                                    print(error!.localizedDescription)
                                }
                            })
                        } else if title == "Requested" && self.lock == "yes" {
                            let query = PFQuery(className: "request")
                            query.whereKey("follower", equalTo: PFUser.current()!.username!)
                            query.whereKey("following", equalTo: friendName.last!)
                            query.findObjectsInBackground(block: { (objects, error) in
                                if error == nil {
                                    for object in objects! {
                                        object.deleteInBackground(block: { (success, error) in
                                            if error == nil {
                                                self.profileButton.setTitle("Follow", for: UIControlState.normal)
                                                self.profileButton.backgroundColor = .white
                                                self.profileButton.layer.borderColor = UIColor(displayP3Red: 75/255, green: 239/255, blue: 211/255, alpha: 1).cgColor
                                                self.profileButton.layer.borderWidth = 1
                                                let notificationQuery = PFQuery(className: "notification")
                                                notificationQuery.whereKey("to", equalTo: friendName.last!)
                                                notificationQuery.whereKey("by", equalTo: PFUser.current()!.username!)
                                                notificationQuery.whereKey("type", equalTo: "request")
                                                notificationQuery.findObjectsInBackground(block: { (objects, error) in
                                                    if error == nil {
                                                        for object in objects! {
                                                            object.deleteEventually()
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
                        }
                    }
                }
            }
       }
    
    
    
    
    
    func animate() {
        
        
        
        self.shapeLayer?.removeFromSuperlayer()
        
        // create whatever path you want
        
        let path = UIBezierPath()
        let path1 = UIBezierPath()
        
        path.move(to: CGPoint(x: 0, y: 68))
        path.addLine(to: CGPoint(x: 15, y: 68))
        path1.move(to: CGPoint(x: 0, y: 68))
        path1.addLine(to: CGPoint(x: 15, y: 68))
        //path.addLine(to: CGPoint(x: 200, y: 240))
        //path.addCurve(to: CGPoint(x: 102, y: 80), controlPoint1: CGPoint(x: 50, y: -100), controlPoint2: CGPoint(x: 100, y: 350))
        path.addArc(withCenter: profilePic.center, radius: 45, startAngle: CGFloat(Double.pi), endAngle: (CGFloat(Double.pi) * 2), clockwise: true)
        path1.addArc(withCenter: profilePic.center, radius: 45, startAngle: CGFloat(Double.pi), endAngle: CGFloat(
        Double.pi * 2), clockwise: false)
        
        path.addLine(to: CGPoint(x: UIScreen.main.bounds.width , y: 68))
        path1.addLine(to: CGPoint(x: UIScreen.main.bounds.width , y: 68))
        
        // create shape layer for that path
        
        let shapeLayer = CAShapeLayer()
        shapeLayer.fillColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0).cgColor
        shapeLayer.strokeColor = blueColor.cgColor
        shapeLayer.lineWidth = 5
        shapeLayer.path = path.cgPath
        
        let shapeLayer1 = CAShapeLayer()
        shapeLayer1.fillColor = UIColor.clear.cgColor
        shapeLayer1.strokeColor = blueColor.cgColor
        shapeLayer1.lineWidth = 5
        shapeLayer1.path = path1.cgPath
        
        
        // animate it
        
        self.layer.addSublayer(shapeLayer)
        self.layer.addSublayer(shapeLayer1)
        let animation = CABasicAnimation(keyPath: "strokeEnd")
        animation.fromValue = 0
        animation.duration = 1.5
        shapeLayer.add(animation, forKey: "MyAnimation")
        shapeLayer1.add(animation, forKey: "MyAnimation")
        
        // save shape layer
        
        self.shapeLayer = shapeLayer
        self.shapeLayer1 = shapeLayer1
    }

}

