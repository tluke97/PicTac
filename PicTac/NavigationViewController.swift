//
//  NavigationViewController.swift
//  CorkBoard
//
//  Created by Tanner Luke on 10/31/17.
//  Copyright © 2017 CorkBoard Co. All rights reserved.
//

import UIKit

class NavigationViewController: UINavigationController {

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationBar.titleTextAttributes = [NSAttributedStringKey.foregroundColor: UIColor.white ]
        self.navigationBar.tintColor = .white
        self.navigationBar.barTintColor = UIColor(displayP3Red: 75/255, green: 239/255, blue: 211/255, alpha: 1)
        self.navigationBar.isTranslucent = false
     }
   
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return UIStatusBarStyle.lightContent
    }
}
