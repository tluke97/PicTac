//
//  PushNotification.swift
//  PicTac
//
//  Created by Tanner Luke on 6/20/18.
//  Copyright © 2018 Tanner Luke. All rights reserved.
//

import Foundation
import Parse

public class PushNotifications {
    
    func pushLikeNotification(username: String) {
        
        let notificationTo = PFQuery(className: "_User")
        notificationTo.whereKey("username", equalTo: username)
        notificationTo.findObjectsInBackground { (objects, error) in
            if error == nil {
                print(objects!)
                for object in objects! {
                    let sendingTo = object.objectId!
                    let text = "\(PFUser.current()!.username!) followed you, or whatever you want to say here";
                    let data = [
                        "badge" : "Increment",
                        "alert" : text,
                        ]
                    let request: [String : Any] = [
                        "likeFrom" : PFUser.current()!.username!,
                        "data" : data,
                        "sendTo" : sendingTo
                    ]
                    //let cloudParams : [AnyHashable:String] = [:]
                    PFCloud.callFunction(inBackground: "likePush", withParameters: request as [NSObject : AnyObject], block: {
                        (result: Any?, error: Error?) -> Void in
                        if error != nil {
                            if let descrip = error?.localizedDescription{
                                print(descrip)
                            }
                        }else{
                            print(result as! String)
                        }
                    })
                }
            } else {
                print(error!.localizedDescription)
            }
        }
    
    }
    
    
    func pushTagNotification(username: String) {
        
        let notificationTo = PFQuery(className: "_User")
        notificationTo.whereKey("username", equalTo: username)
        notificationTo.findObjectsInBackground { (objects, error) in
            if error == nil {
                print(objects!)
                for object in objects! {
                    let sendingTo = object.objectId!
                    let text = "\(PFUser.current()!.username!) followed you, or whatever you want to say here";
                    let data = [
                        "badge" : "Increment",
                        "alert" : text,
                        ]
                    let request: [String : Any] = [
                        "notificationFrom" : PFUser.current()!.username!,
                        "data" : data,
                        "sendTo" : sendingTo
                    ]
                    //let cloudParams : [AnyHashable:String] = [:]
                    PFCloud.callFunction(inBackground: "tagPush", withParameters: request as [NSObject : AnyObject], block: {
                        (result: Any?, error: Error?) -> Void in
                        if error != nil {
                            if let descrip = error?.localizedDescription{
                                print(descrip)
                            }
                        }else{
                            print(result as! String)
                        }
                    })
                }
            } else {
                print(error!.localizedDescription)
            }
        }
        
    }
    
    
    func pushCommentNotification(username: String) {
        
        let notificationTo = PFQuery(className: "_User")
        notificationTo.whereKey("username", equalTo: username)
        notificationTo.findObjectsInBackground { (objects, error) in
            if error == nil {
                print(objects!)
                for object in objects! {
                    let sendingTo = object.objectId!
                    let text = "\(PFUser.current()!.username!) followed you, or whatever you want to say here";
                    let data = [
                        "badge" : "Increment",
                        "alert" : text,
                        ]
                    let request: [String : Any] = [
                        "notificationFrom" : PFUser.current()!.username!,
                        "data" : data,
                        "sendTo" : sendingTo
                    ]
                    //let cloudParams : [AnyHashable:String] = [:]
                    PFCloud.callFunction(inBackground: "commentPush", withParameters: request as [NSObject : AnyObject], block: {
                        (result: Any?, error: Error?) -> Void in
                        if error != nil {
                            if let descrip = error?.localizedDescription{
                                print(descrip)
                            }
                        }else{
                            print(result as! String)
                        }
                    })
                }
            } else {
                print(error!.localizedDescription)
            }
        }
        
    }
    
    
    func pushFollowNotification(username: String) {
        
        let notificationTo = PFQuery(className: "_User")
        notificationTo.whereKey("username", equalTo: username)
        notificationTo.findObjectsInBackground { (objects, error) in
            if error == nil {
                print(objects!)
                for object in objects! {
                    let sendingTo = object.objectId!
                    let text = "\(PFUser.current()!.username!) followed you, or whatever you want to say here";
                    let data = [
                        "badge" : "Increment",
                        "alert" : text,
                        ]
                    let request: [String : Any] = [
                        "notificationFrom" : PFUser.current()!.username!,
                        "data" : data,
                        "sendTo" : sendingTo
                    ]
                    //let cloudParams : [AnyHashable:String] = [:]
                    PFCloud.callFunction(inBackground: "followPush", withParameters: request as [NSObject : AnyObject], block: {
                        (result: Any?, error: Error?) -> Void in
                        if error != nil {
                            if let descrip = error?.localizedDescription{
                                print(descrip)
                            }
                        }else{
                            print(result as! String)
                        }
                    })
                }
            } else {
                print(error!.localizedDescription)
            }
        }
        
    }
    
    
    
    func pushRequestNotification(username: String) {
        
        let notificationTo = PFQuery(className: "_User")
        notificationTo.whereKey("username", equalTo: username)
        notificationTo.findObjectsInBackground { (objects, error) in
            if error == nil {
                print(objects!)
                for object in objects! {
                    let sendingTo = object.objectId!
                    let text = "\(PFUser.current()!.username!) followed you, or whatever you want to say here";
                    let data = [
                        "badge" : "Increment",
                        "alert" : text,
                        ]
                    let request: [String : Any] = [
                        "notificationFrom" : PFUser.current()!.username!,
                        "data" : data,
                        "sendTo" : sendingTo
                    ]
                    //let cloudParams : [AnyHashable:String] = [:]
                    PFCloud.callFunction(inBackground: "requestPush", withParameters: request as [NSObject : AnyObject], block: {
                        (result: Any?, error: Error?) -> Void in
                        if error != nil {
                            if let descrip = error?.localizedDescription{
                                print(descrip)
                            }
                        }else{
                            print(result as! String)
                        }
                    })
                }
            } else {
                print(error!.localizedDescription)
            }
        }
        
    }
    
    
    func pushScreenshotNotification(username: String) {
        
        let notificationTo = PFQuery(className: "_User")
        notificationTo.whereKey("username", equalTo: username)
        notificationTo.findObjectsInBackground { (objects, error) in
            if error == nil {
                print(objects!)
                for object in objects! {
                    let sendingTo = object.objectId!
                    let text = "\(PFUser.current()!.username!) followed you, or whatever you want to say here";
                    let data = [
                        "badge" : "Increment",
                        "alert" : text,
                        ]
                    let request: [String : Any] = [
                        "notificationFrom" : PFUser.current()!.username!,
                        "data" : data,
                        "sendTo" : sendingTo
                    ]
                    //let cloudParams : [AnyHashable:String] = [:]
                    PFCloud.callFunction(inBackground: "screenshotPush", withParameters: request as [NSObject : AnyObject], block: {
                        (result: Any?, error: Error?) -> Void in
                        if error != nil {
                            if let descrip = error?.localizedDescription{
                                print(descrip)
                            }
                        }else{
                            print(result as! String)
                        }
                    })
                }
            } else {
                print(error!.localizedDescription)
            }
        }
        
    }
    
    
    
}
