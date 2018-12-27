//
//  CustomProfileVC.swift
//  PicTac
//
//  Created by Tanner Luke on 7/9/18.
//  Copyright © 2018 Tanner Luke. All rights reserved.
//

import UIKit

class CustomProfileVC: UIViewController, UITableViewDelegate {
    @IBOutlet weak var colorView: UIView!
    @IBOutlet weak var lightBlueColor: UIButton!
    @IBOutlet weak var blackColor: UIButton!
    @IBOutlet weak var lightGrayColor: UIButton!
    @IBOutlet weak var darkerGrayColor: UIButton!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var profilePicture: UIImageView!
    @IBOutlet weak var fullName: UILabel!
    @IBOutlet weak var username: UILabel!
    @IBOutlet weak var styleDesignSegment: UISegmentedControl!
    @IBOutlet weak var animationOnOffSegment: UISegmentedControl!
    @IBOutlet weak var chooseColorSegment: UIButton!
    
    weak var shapeLayer: CAShapeLayer?
    weak var shapeLayer1: CAShapeLayer?
    let blueColor = UIColor(displayP3Red: 75/255, green: 239/255, blue: 211/255, alpha: 1)
    
    var userLineType: String?
    var userColor: String?
    var userAnimation: Bool?
    
    var usernameText: String?
    var fullnameText: String?
    var profileImage: UIImage?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        profilePicture.layer.cornerRadius = 40

        
//        UserDefaults.standard.set(true, forKey: "animated")
//        UserDefaults.standard.set("blue", forKey: "lineColor")
//        UserDefaults.standard.set("circle", forKey: "shape")
//        UserDefaults.standard.synchronize()
//
        
        username.text = usernameText!
        fullName.text = fullnameText!
        profilePicture.image = profileImage!
        
        userAnimation = UserDefaults.standard.bool(forKey: "animated")
        userLineType = UserDefaults.standard.string(forKey: "shape")
        userColor = UserDefaults.standard.string(forKey: "lineColor")
        
        
        
        alignment()
        
        //animate()
        
        animateLine(animated: userAnimation!, color: userColor!, shape: userLineType!)
    }
    
    func alignment() {
       // colorView.addSubview(lightBlueColor)
        //colorView.addSubview(lightGrayColor)
        //colorView.addSubview(darkerGrayColor)
        //colorView.addSubview(blackColor)
        colorView.backgroundColor = UIColor.white
        colorView.layer.borderColor = UIColor.lightGray.cgColor
        colorView.layer.borderWidth = 1
        colorView.layer.cornerRadius = 30
        colorView.alpha = 0.0
        lightGrayColor.layer.cornerRadius = 25
        lightBlueColor.layer.cornerRadius = 25
        darkerGrayColor.layer.cornerRadius = 25
        blackColor.layer.cornerRadius = 25
        
        
        
        
        
        /*lightBlueColor.frame = CGRect(x: self.view.frame.size.width/2, y: self.view.frame.size.height/2, width: 1, height: 1)
        
        lightGrayColor.frame = CGRect(x: self.view.frame.size.width/2, y: self.view.frame.size.height/2, width: 1, height: 1)
        
        blackColor.frame = CGRect(x: self.view.frame.size.height/2, y: self.view.frame.size.height/2, width: 1, height: 1)
        
        darkerGrayColor.frame = CGRect(x: self.view.frame.size.height/2, y: self.view.frame.size.height/2, width: 1, height: 1)
        */
        colorView.isHidden = true
    }
    
    func animate() {
        
        UIView.animate(withDuration: 0.8) {
            self.colorView.isHidden = false
            self.colorView.alpha = 1.0
            /*self.lightBlueColor.transform = CGAffineTransform(scaleX: 50, y: 50)
            self.blackColor.transform = CGAffineTransform(scaleX: 50, y: 50)
            self.lightGrayColor.transform = CGAffineTransform(scaleX: 50, y: 50)
            self.darkerGrayColor.transform = CGAffineTransform(scaleX: 50, y: 50)*/
            //self.colorView.transform = CGAffineTransform(scaleX: 200, y: 200)
        }
    }
    
    
    @IBAction func lightBlueClick(_ sender: Any) {
        UserDefaults.standard.removeObject(forKey: "lineColor")
        UserDefaults.standard.set("blue", forKey: "lineColor")
        UserDefaults.standard.synchronize()
        
        self.colorView.isHidden = true
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.reanimate()
        }
        
    }
    
    @IBAction func blackClick(_ sender: Any) {
        UserDefaults.standard.removeObject(forKey: "lineColor")
        UserDefaults.standard.set("black", forKey: "lineColor")
        UserDefaults.standard.synchronize()
        
        self.colorView.isHidden = true
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.reanimate()
        }
    }
    
    @IBAction func darkerGrayClick(_ sender: Any) {
        UserDefaults.standard.removeObject(forKey: "lineColor")
        UserDefaults.standard.set("darkerGray", forKey: "lineColor")
        UserDefaults.standard.synchronize()
        
        self.colorView.isHidden = true
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.reanimate()
        }
    }
    
    @IBAction func lightGrayClick(_ sender: Any) {
        UserDefaults.standard.removeObject(forKey: "lineColor")
        UserDefaults.standard.set("lightGray", forKey: "lineColor")
        UserDefaults.standard.synchronize()
        
        self.colorView.isHidden = true
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.reanimate()
        }
    }
    
    @IBAction func styleChanged(_ sender: Any) {
        
        switch styleDesignSegment.selectedSegmentIndex {
        case 1:
            UserDefaults.standard.removeObject(forKey: "shape")
            UserDefaults.standard.set("half-circle", forKey: "shape")
            UserDefaults.standard.synchronize()
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                self.reanimate()
            }
            
        default:
            UserDefaults.standard.removeObject(forKey: "shape")
            UserDefaults.standard.set("circle", forKey: "shape")
            UserDefaults.standard.synchronize()
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                self.reanimate()
            }
        }
        
    }
    
    @IBAction func animationStateChanged(_ sender: Any) {
        
        switch animationOnOffSegment.selectedSegmentIndex {
        case 1:
            UserDefaults.standard.removeObject(forKey: "animated")
            UserDefaults.standard.set(false, forKey: "animated")
            UserDefaults.standard.synchronize()
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                self.reanimate()
            }
            
        default:
            UserDefaults.standard.removeObject(forKey: "animated")
            UserDefaults.standard.set(true, forKey: "animated")
            UserDefaults.standard.synchronize()
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                self.reanimate()
            }
        }
        
        
    }
    
    @IBAction func chooseColor(_ sender: Any) {
        
        animate()
        
    }
    
    
    func animateLine(animated: Bool, color: String, shape: String) {
        
        
        
        self.shapeLayer?.removeFromSuperlayer()
        self.shapeLayer1?.removeFromSuperlayer()
        
        // create whatever path you want
        
        let path = UIBezierPath()
        let path1 = UIBezierPath()
        
        path.move(to: CGPoint(x: 0, y: 60))
        path.addLine(to: CGPoint(x: 15, y: 60))
        if shape == "circle" {
            path1.move(to: CGPoint(x: 0, y: 60))
            path1.addLine(to: CGPoint(x: 15, y: 60))
        }
        //path.addLine(to: CGPoint(x: 200, y: 240))
        //path.addCurve(to: CGPoint(x: 102, y: 80), controlPoint1: CGPoint(x: 50, y: -100), controlPoint2: CGPoint(x: 100, y: 350))
        path.addArc(withCenter: CGPoint(x: 60, y: 60), radius: 45, startAngle: .pi, endAngle: .pi * 2, clockwise: true)
        if shape == "circle" {
            path1.addArc(withCenter:CGPoint(x: 60, y: 60), radius: 45, startAngle: .pi, endAngle: .pi * 2, clockwise: false)
        }
        path.addLine(to: CGPoint(x: UIScreen.main.bounds.width , y: 60))
        if shape == "circle" {
            path1.addLine(to: CGPoint(x: UIScreen.main.bounds.width , y: 60))
        }
        // create shape layer for that path
        
        let shapeLayer = CAShapeLayer()
        shapeLayer.fillColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0).cgColor
        if color == "black" {
            shapeLayer.strokeColor = UIColor.black.cgColor
        } else if color == "darkerGray" {
            shapeLayer.strokeColor = UIColor.darkGray.cgColor
        } else if color == "lightGray" {
            shapeLayer.strokeColor = UIColor.lightGray.cgColor
        } else {
            shapeLayer.strokeColor = blueColor.cgColor
        }
        shapeLayer.lineWidth = 5
        shapeLayer.path = path.cgPath
        
        let shapeLayer1 = CAShapeLayer()
        shapeLayer1.fillColor = UIColor.clear.cgColor
        if color == "black" {
            shapeLayer1.strokeColor = UIColor.black.cgColor
        } else if color == "darkerGray" {
            shapeLayer1.strokeColor = UIColor.darkGray.cgColor
        } else if color == "lightGray" {
            shapeLayer1.strokeColor = UIColor.lightGray.cgColor
        } else {
            shapeLayer1.strokeColor = blueColor.cgColor
        }
        shapeLayer1.lineWidth = 5
        shapeLayer1.path = path1.cgPath
        
        
        // animate it
        
        self.view.layer.addSublayer(shapeLayer)
        if shape == "circle" {
            self.view.layer.addSublayer(shapeLayer1)
        }
        if animated == true {
            let animation = CABasicAnimation(keyPath: "strokeEnd")
            animation.fromValue = 0
            animation.duration = 1.5
            shapeLayer.add(animation, forKey: "MyAnimation")
            shapeLayer1.add(animation, forKey: "MyAnimation")
        }
        // save shape layer
        
        self.shapeLayer = shapeLayer
        if shape == "circle" {
            self.shapeLayer1 = shapeLayer1
        }
    }
    
    
    func reanimate() {
        
        let getLineColor = UserDefaults.standard.string(forKey: "lineColor")
        let getAnimation = UserDefaults.standard.bool(forKey: "animated")
        let getShape = UserDefaults.standard.string(forKey: "shape")
        
        animateLine(animated: getAnimation, color: getLineColor!, shape: getShape!)
        
        
    }
    
    
    
}
