//
//  CheckPostTimes.swift
//  PicTac
//
//  Created by Tanner Luke on 7/9/18.
//  Copyright © 2018 Tanner Luke. All rights reserved.
//

import Foundation
import Parse

public class CheckPostTimes {
    
    var followerArray = [String]()
    var timeArray = [Date?]()
    
    
    func checkTimes(name: String) {
        
        let query = PFQuery(className: "follow")
        query.whereKey("follower", equalTo: name)
        query.findObjectsInBackground { (objects, error) in
            if error == nil {
                self.followerArray.removeAll(keepingCapacity: false)
                for object in objects! {
                    self.followerArray.append(object.object(forKey: "username") as! String)
                }
                self.followerArray.append(name)
                let findPosts = PFQuery(className: "posts")
                findPosts.whereKey("username", containedIn: self.followerArray)
                findPosts.whereKey("time", equalTo: "under")
                findPosts.addDescendingOrder("createdAt")
                findPosts.findObjectsInBackground(block: { (objects, error) in
                    
                    if error == nil {
                        
                        self.timeArray.removeAll(keepingCapacity: false)
                        
                        for object in objects! {
                            
                            self.timeArray.append(object.createdAt)
                            
                        }
                    }
                })
                
            }
        }
        
        
    }
    
    
    
    
    
    
    
    
    
    
    
}
