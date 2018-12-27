//
//  TabBarViewController.swift
//  CorkBoard
//
//  Created by Tanner Luke on 10/31/17.
//  Copyright © 2017 CorkBoard Co. All rights reserved.
//

import UIKit
import Parse

var dot = UIView()

class TabBarViewController: UITabBarController {
    let screenSize = UIScreen.main.bounds.height

    override func viewDidLoad() {
        super.viewDidLoad()
        self.tabBar.tintColor = UIColor(displayP3Red: 75/255, green: 239/255, blue: 211/255, alpha: 1)
        self.tabBar.isTranslucent = false
        self.tabBar.barTintColor = UIColor(displayP3Red: 255/255, green: 255/255, blue: 255/255, alpha: 1)
        if screenSize == 812 {
            let bottomPadding = view.safeAreaInsets.bottom
            print(bottomPadding)
            dot.frame = CGRect(x: (self.view.frame.size.width/5)*3, y: UIScreen.main.bounds.height - self.tabBar.frame.size.height + 4, width: 7, height: 7)
        } else {
            dot.frame = CGRect(x: (self.view.frame.size.width/5)*3, y: UIScreen.main.bounds.height - self.tabBar.frame.size.height + 38, width: 7, height: 7)
        }
        dot.center.x = self.view.frame.size.width/5*3 + (self.view.frame.size.width/5)/2
        dot.backgroundColor = UIColor(displayP3Red: 75/255, green: 239/255, blue: 211/255, alpha: 1)
        dot.layer.cornerRadius = dot.frame.size.width / 2
        dot.isHidden = true
        self.view.addSubview(dot)
        query()
    }

    func query() {
        let query = PFQuery(className: "notification")
        query.whereKey("to", equalTo: PFUser.current()!.username!)
        query.whereKey("checked", equalTo: "no")
        query.countObjectsInBackground { (count, error) in
            if error == nil {
                if count > 0 {
                   dot.isHidden = false
                } else {
                    dot.isHidden = true
                }
            } else {
                print(error!.localizedDescription)
            }
        }
     }
    
    func placeIcon() {
        dot.isHidden = false
    }
}
