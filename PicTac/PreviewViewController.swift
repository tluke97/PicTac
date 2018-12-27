//
//  PreviewViewController.swift
//  CorkBoard
//
//  Created by Tanner Luke on 11/1/17.
//  Copyright © 2017 CorkBoard Co. All rights reserved.
//

import UIKit
import Parse
import CoreGraphics

class PreviewViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIScrollViewDelegate, UITextViewDelegate, UIGestureRecognizerDelegate {
    
    @IBOutlet weak var scrollView: UIScrollView!{
        didSet{
            scrollView.delegate = self
            scrollView.minimumZoomScale = 1.0
            scrollView.maximumZoomScale = 4.0
        }
    }
    @IBOutlet weak var drawView: UIImageView!
    @IBOutlet weak var cropView: UIView!
    @IBOutlet weak var changeFontButton: UIButton!
    @IBOutlet weak var backBtn: UIButton!
    @IBOutlet weak var textField: UILabel!
    @IBOutlet weak var titleText: UITextView!
    @IBOutlet weak var postButton: UIButton!
    @IBOutlet weak var photo: UIImageView!
    @IBOutlet weak var drawButton: UIButton!
    @IBOutlet weak var clearButton: UIButton!
    @IBOutlet weak var cropButton: UIButton!
    @IBOutlet weak var newTextButton: UIButton!
    @IBOutlet weak var redButton: UIButton!
    @IBOutlet weak var orangeButton: UIButton!
    @IBOutlet weak var yellowButton: UIButton!
    @IBOutlet weak var greenButton: UIButton!
    @IBOutlet weak var blueButton: UIButton!
    @IBOutlet weak var purpleButton: UIButton!
    @IBOutlet weak var whiteButton: UIButton!
    @IBOutlet weak var blackButton: UIButton!
    @IBOutlet weak var whiteTextButton: UIButton!
    @IBOutlet weak var blackTextButton: UIButton!
    @IBOutlet weak var textColorPickerButton: UIButton!
    @IBOutlet weak var redTextButton: UIButton!
    @IBOutlet weak var orangeTextButton: UIButton!
    @IBOutlet weak var yellowTextButton: UIButton!
    @IBOutlet weak var blueTextButton: UIButton!
    @IBOutlet weak var purpleTextButton: UIButton!
    @IBOutlet weak var greenTextButton: UIButton!
    @IBOutlet weak var colorPickerButton: UIButton!
    var textColor: UIColor!
    var lineColor: UIColor!
    var lineWidth: CGFloat!
    var path: UIBezierPath!
    var touchPoint: CGPoint!
    var startingPoint: CGPoint!
    var allowDrawing: Bool!
    var lastPoint = CGPoint.zero
    var brushWidth: CGFloat = 5.0
    var opacity: CGFloat = 1.0
    var swiped = false
    var drawColor: CGColor! = UIColor.black.cgColor
    let optima = UIFont(name: "Optima", size: 40)
    let choko = UIFont(name: "Choko", size: 40)
    let threeD = UIFont(name: "Pixellari", size: 40)
    let typeKeys = UIFont(name: "Type Keys Filled", size: 40)
    let stayClassy = UIFont(name: "Stay Classy SLDT", size: 40)
    let littleDays = UIFont(name: "Little Days Alt", size: 40)
    var fromBackCamera: Bool!
    var whichCamera: Bool!
    var fromCrop: Bool!
    var tapToHide: UITapGestureRecognizer!
    var commentY: CGFloat = 0
    var imageCommentY: CGFloat = 0
    var commentHeight: CGFloat = 0
    var imageCommentHeight: CGFloat = 0
    var keyboard = CGRect()
    var rotationAngle: CGFloat = 0
    var pinchX: CGFloat = 1
    var pinchY: CGFloat = 0
    var isItLocked = "yes"
    var image: UIImage!
    var croppedImage: UIImage!
    var cgiImage: CGImage?
    var translationX: CGFloat!
    var translationY: CGFloat!
    var autoPin: Bool?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        _ = networkNotification()
        cropButton.isHidden = false
        clearButton.isHidden = true
        scrollView.isUserInteractionEnabled = false
        textField.isHidden = true
        colorAlignment()
        hideTextColors()
        //titleText.frame.size.height = 48
        textColorPickerButton.isHidden = true
        postButton.frame.size.height = 20
        postButton.frame.size.width = 20
        postButton.frame.origin.y = self.view.frame.size.height
        postButton.frame.origin.x = self.view.frame.size.width
        drawView.frame = CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: self.view.frame.size.height)
        translationY = self.view.frame.size.height/2
        translationX = self.view.frame.size.width/2
        photo.isUserInteractionEnabled = true
        changeFontButton.layer.cornerRadius = changeFontButton.frame.size.width / 2
        self.titleText.isHidden = true
        self.photo.clipsToBounds = true
        self.photo.isMultipleTouchEnabled = false
        textColor = .white
        lineColor = .black
        lineWidth = 5
        allowDrawing = false
        if fromCrop == true {
            photo.image = croppedImage
        } else {
        photo.image = self.image
        }
        textField.font = optima
        titleText.font = optima
        titleText.textContainerInset = UIEdgeInsets.zero
        titleText.textContainer.lineFragmentPadding = 0
        drawView.isUserInteractionEnabled = true
        whichCamera = fromBackCamera
        //titleText.backgroundColor = .clear
        //titleText.textColor = .white
        titleText.textColor = .black
        photo.frame = CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: self.view.frame.size.height)
        NotificationCenter.default.addObserver(self, selector: #selector(PreviewViewController.showKeyboard(notification:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        scrollView.delegate = self
        scrollView.frame = CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: self.view.frame.size.height)
        photo.frame = CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: self.view.frame.size.height)
        photo.isUserInteractionEnabled = true
        scrollView.addSubview(photo)
        photo.contentMode = .scaleAspectFit
        self.photo.clipsToBounds = true
        tapToHide = UITapGestureRecognizer(target: self, action: #selector(PreviewViewController.tapToShow(recognizer:)))
        tapToHide.numberOfTapsRequired = 1
        self.view.isUserInteractionEnabled = true
        self.view.addGestureRecognizer(tapToHide)
        textField.isUserInteractionEnabled = true
        textField.isMultipleTouchEnabled = true
        let gestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(handlePan))
        gestureRecognizer.delegate = self
        textField.addGestureRecognizer(gestureRecognizer)
        let pinchGesture = UIPinchGestureRecognizer(target: self, action:#selector(pinchRecognized(pinch:)))
        pinchGesture.delegate = self
        textField.addGestureRecognizer(pinchGesture)
        let rotate = UIRotationGestureRecognizer.init(target: self, action: #selector(handleRotate(recognizer:)))
        rotate.delegate = self
        textField.addGestureRecognizer(rotate)
        titleText.delegate = self
        let findPrivate = PFQuery(className: "_User")
        findPrivate.whereKey("username", equalTo: PFUser.current()!.username!)
        findPrivate.findObjectsInBackground { (objects, error) in
            if error == nil {
                for object in objects! {
                    self.isItLocked = object.object(forKey: "locked") as! String
                }
            }
        }
        textField.text = ""
        getAutoPin()
    }
    
    
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        UIView.animate(withDuration: 0.4) {
            self.postButton.frame = CGRect(x: self.view.frame.size.width - 75, y: self.view.frame.size.height - 80, width: 60, height: 60)
        }
    }
    
    func networkNotification() -> Bool {
        var canPost: Bool?
        if Reachability.isConnectedToNetwork() {
            canPost = true
            print("connected")
        } else {
            canPost = false
            let alert = UIAlertController(title: "Network Error", message: "Sorry, but there appears to be an error with your internet connection. Please try again later.", preferredStyle: .alert)
            let okay = UIAlertAction(title: "Okay", style: UIAlertActionStyle.cancel, handler: nil)
            alert.addAction(okay)
            present(alert, animated: true, completion: nil)
        }
        return canPost!
    }
    
    
    @objc func handlePan(_ gestureRecognizer: UIPanGestureRecognizer) {
        if gestureRecognizer.state == .began || gestureRecognizer.state == .changed {
            let translation = gestureRecognizer.translation(in: self.view)
            gestureRecognizer.view!.center = CGPoint(x: gestureRecognizer.view!.center.x + translation.x, y: gestureRecognizer.view!.center.y + translation.y)
            translationX = (gestureRecognizer.view?.center.x)!
            translationY = gestureRecognizer.view!.center.y
            gestureRecognizer.setTranslation(CGPoint.zero, in: self.view)
        }
    }
    
    @objc func pinchRecognized(pinch: UIPinchGestureRecognizer) {
        if let view = pinch.view {
            view.transform = view.transform.scaledBy(x: pinch.scale, y: pinch.scale)
            pinchX = pinchX * pinch.scale
            pinch.scale = 1
        }
    }
    
    @objc func handleRotate(recognizer : UIRotationGestureRecognizer) {
        if let view = recognizer.view {
            view.transform = view.transform.rotated(by: recognizer.rotation)
            rotationAngle = rotationAngle + recognizer.rotation
            recognizer.rotation = 0
        }
    }
    
    func gestureRecognizer(_: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith shouldRecognizeSimultaneouslyWithGestureRecognizer:UIGestureRecognizer) -> Bool {
        return true
    }
    
    func getAutoPin() {
        let getAutoQuery = PFQuery(className: "_User")
        getAutoQuery.whereKey("username", equalTo: PFUser.current()!.username!)
        getAutoQuery.findObjectsInBackground { (objects, error) in
            if error == nil {
                
                for object in objects! {
                    
                    self.autoPin = object.object(forKey: "autopin") as? Bool
                    
                }
                
            } else {
                
                print(error!.localizedDescription)
            }
        }
    }
    
    func alignment(notification: NSNotification) {
        keyboard = ((notification.userInfo?[UIKeyboardFrameEndUserInfoKey]! as AnyObject).cgRectValue)!
        //textField.frame = CGRect(x: 0, y: self.view.frame.size.height - self.textField.frame.size.height + commentHeight - keyboard.height, width: self.view.frame.size.width, height: 30)
        titleText.frame = CGRect(x: 0, y: self.view.frame.size.height - self.titleText.frame.size.height + commentHeight - keyboard.height, width: self.view.frame.size.width, height: 30)
        
    }
    
    func colorAlignment() {
        drawButton.frame = CGRect(x: self.view.frame.size.width-55, y: 15, width: 40, height: 40)
        clearButton.frame = CGRect(x: self.view.frame.size.width-55, y: drawButton.frame.origin.y + 45, width: 40, height: 40)
        cropButton.frame = CGRect(x: self.view.frame.size.width-55, y: drawButton.frame.origin.y + 45, width: 40, height: 40)
        colorPickerButton.frame = CGRect(x: self.view.frame.size.width-55, y: cropButton.frame.origin.y + 45, width: 40, height: 40)
        blackButton.frame = colorPickerButton.frame
        whiteButton.frame = colorPickerButton.frame
        redButton.frame = colorPickerButton.frame
        orangeButton.frame = colorPickerButton.frame
        yellowButton.frame = colorPickerButton.frame
        greenButton.frame = colorPickerButton.frame
        blueButton.frame = colorPickerButton.frame
        purpleButton.frame = colorPickerButton.frame
        textColorPickerButton.frame = CGRect(x: self.view.frame.size.width-55, y: 15, width: 40, height: 40)
        changeFontButton.frame = CGRect(x: textColorPickerButton.frame.origin.x, y: textColorPickerButton.frame.origin.y + 45, width: 40, height: 40)
        blackTextButton.frame = textColorPickerButton.frame
        whiteTextButton.frame = textColorPickerButton.frame
        yellowTextButton.frame = textColorPickerButton.frame
        orangeTextButton.frame = textColorPickerButton.frame
        redTextButton.frame = textColorPickerButton.frame
        purpleTextButton.frame = textColorPickerButton.frame
        blueTextButton.frame = textColorPickerButton.frame
        greenTextButton.frame = textColorPickerButton.frame
        changeFontButton.frame = CGRect(x: textColorPickerButton.frame.origin.x - 55, y: textColorPickerButton.frame.origin.y, width: 40, height: 40)
        changeFontButton.isHidden = true
        textColorPickerButton.isHidden = true
        hideTextColors()
        hideColors()
        colorPickerButton.isHidden = true
    }
    
    func textViewDidChange(_ textView: UITextView) {
        
        if (titleText.contentSize.height > titleText.bounds.size.height && titleText.bounds.height < 350)  {
            
            let difference = textView.contentSize.height - textView.frame.size.height
            print(difference)
            textView.frame.origin.y = textView.frame.origin.y - difference //- 5
            textView.frame.size.height = textView.contentSize.height + 1  //+ 15
            
            
        
       }
        else if textView.contentSize.height < textView.bounds.size.height {
            print("this one")
            /*
            if textView.contentSize.height > textView.frame.size.height {
                let difference = textView.contentSize.height - textView.frame.size.height
                print(difference)
                textView.frame.origin.y = textView.frame.origin.y - difference - 5
                textView.frame.size.height = textView.contentSize.height + 5
            }
            */
            let difference = textView.frame.size.height - textView.contentSize.height
            textView.frame.origin.y = textView.frame.origin.y + difference
            textView.frame.size.height = textView.contentSize.height
            
        
        }
        
       
        
    
    }
    
    @IBAction func allowDraw(_ sender: Any) {
        if allowDrawing == false {
            allowDrawing = true
            clearButton.isHidden = false
            cropButton.isHidden = true
            colorPickerButton.isHidden = false
            let doNothing = UITapGestureRecognizer(target: self, action: #selector(PreviewViewController.doNothing(recognizer:)))
            doNothing.numberOfTapsRequired = 1
            self.view.addGestureRecognizer(doNothing)
        } else {
            UIView.animate(withDuration: 0.4, animations: {
                self.blackButton.frame = self.colorPickerButton.frame
                self.whiteButton.frame = self.colorPickerButton.frame
                self.redButton.frame = self.colorPickerButton.frame
                self.orangeButton.frame = self.colorPickerButton.frame
                self.yellowButton.frame = self.colorPickerButton.frame
                self.greenButton.frame = self.colorPickerButton.frame
                self.blueButton.frame = self.colorPickerButton.frame
                self.purpleButton.frame = self.colorPickerButton.frame
            })
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                self.hideColors()
                self.colorPickerButton.isHidden = true
            }
            allowDrawing = false
            clearButton.isHidden = true
            cropButton.isHidden = false
            if self.textField.text == "" {
                let tapToHide = UITapGestureRecognizer(target: self, action: #selector(PreviewViewController.tapToShow(recognizer:)))
                tapToHide.numberOfTapsRequired = 1
                self.view.isUserInteractionEnabled = true
                self.view.addGestureRecognizer(tapToHide)
            } else {
                let tapToHide = UITapGestureRecognizer(target: self, action: #selector(PreviewViewController.tapToShow(recognizer:)))
                tapToHide.numberOfTapsRequired = 1
                self.textField.isUserInteractionEnabled = true
                self.textField.addGestureRecognizer(tapToHide)
            }
        }
    }
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return photo
    }
    
    @objc func hideTap(recognizer: UITapGestureRecognizer) {
        let comment = titleText.text
        textField.text = comment
        self.textField.translatesAutoresizingMaskIntoConstraints = true
        if titleText.text == "" {
            titleText.isHidden = true
            textField.isHidden = true
        } else {
            titleText.isHidden = true
            textField.isHidden = false
        }
        self.clearButton.isHidden = false
        self.backBtn.isHidden = false
        self.cropButton.isHidden = false
        self.drawButton.isHidden = false
        self.colorPickerButton.isHidden = true
        self.textColorPickerButton.isHidden = true
        self.changeFontButton.isHidden = true
        hideTextColors()
        for subview in self.drawView.subviews {
            if subview is UIVisualEffectView {
                subview.removeFromSuperview()
                //self.drawView.isHidden = false
            }
        }
        self.view.endEditing(true)
        self.textField.sizeToFit()
        UIView.animate(withDuration: 0.5) {
            self.textField.transform = self.textField.transform.rotated(by: self.rotationAngle)
            self.textField.transform = self.textField.transform.scaledBy(x: self.pinchX, y: self.pinchX)
            self.textField.center = CGPoint(x: self.translationX, y: self.translationY)
        }
        
        if textField.text == "" {
            let tapToHide = UITapGestureRecognizer(target: self, action: #selector(PreviewViewController.tapToShow(recognizer:)))
            tapToHide.numberOfTapsRequired = 1
            self.view.isUserInteractionEnabled = true
            self.view.addGestureRecognizer(tapToHide)
        } else {
            let tapToHide = UITapGestureRecognizer(target: self, action: #selector(PreviewViewController.tapToShow(recognizer:)))
            tapToHide.numberOfTapsRequired = 1
            self.textField.isUserInteractionEnabled = true
            self.textField.addGestureRecognizer(tapToHide)
            let doNothing = UITapGestureRecognizer(target: self, action: #selector(PreviewViewController.doNothing(recognizer:)))
            doNothing.numberOfTapsRequired = 1
            self.view.addGestureRecognizer(doNothing)
        }
    }
    
    @objc func tapToShow(recognizer: UITapGestureRecognizer) {
        self.view.bringSubview(toFront: textField)
        UIView.animate(withDuration: 0.4) {
            let blurEffect = UIBlurEffect(style: UIBlurEffectStyle.dark)
            let blurredEffectView = UIVisualEffectView(effect: blurEffect)
            blurredEffectView.frame = self.photo.bounds
            self.drawView.addSubview(blurredEffectView)
            //self.drawView.isHidden = true
        }
        self.changeFontButton.isHidden = false
        self.clearButton.isHidden = true
        self.backBtn.isHidden = true
        self.cropButton.isHidden = true
        self.colorPickerButton.isHidden = true
        self.drawButton.isHidden = true
        self.textColorPickerButton.isHidden = false
        self.textField.transform = textField.transform.rotated(by: -rotationAngle)
        self.textField.transform = textField.transform.scaledBy(x: 1/pinchX, y: 1/pinchX)
        self.textField.center = CGPoint(x: self.textField.center.x - translationX, y: self.textField.center.y - translationY)
        self.textField.text = ""
        self.titleText.isHidden = false
        self.titleText.becomeFirstResponder()
        self.textField.isHidden = true
        if titleText.isHidden == false {
            let hide = UITapGestureRecognizer(target: self, action: #selector(PreviewViewController.hideTap(recognizer:)))
            hide.numberOfTapsRequired = 1
            self.view.isUserInteractionEnabled = true
            self.view.addGestureRecognizer(hide)
        }
    }
    
    @objc func  doNothing(recognizer: UITapGestureRecognizer) {
        print("doNothingFunction")
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        swiped = false
        if let touch = touches.first {
            lastPoint = touch.location(in: self.drawView)
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        swiped = true
        if let touch = touches.first {
            let currentPoint = touch.location(in: drawView)
            drawLineFrom(fromPoint: lastPoint, toPoint: currentPoint)
            lastPoint = currentPoint
        }
    }
    
    func drawShapeLayer() {
        if allowDrawing == true {
            let shapeLayer = CAShapeLayer()
            shapeLayer.path = path.cgPath
            shapeLayer.strokeColor = lineColor.cgColor
            shapeLayer.lineWidth = lineWidth
            shapeLayer.fillColor = nil
            self.drawView.layer.addSublayer(shapeLayer)
            self.drawView.setNeedsDisplay()
        }
    }
    
    func changeType() {
        if titleText.text.isEmpty == false && textField.text?.isEmpty == false {
            textField.text = ""
        } else {
            print("empty")
        }
    }
    
    func drawLineFrom(fromPoint: CGPoint, toPoint: CGPoint) {
        if allowDrawing == true {
            UIGraphicsBeginImageContextWithOptions(view.frame.size, false, 1.0)
            let context = UIGraphicsGetCurrentContext()
            let tempRect = CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: self.view.frame.size.height)
            drawView.image?.draw(in: tempRect)
            context?.move(to: fromPoint)
            context?.addLine(to: toPoint)
            context?.setLineCap(.round)
            context?.setLineWidth(brushWidth)
            context?.setStrokeColor(drawColor)
            context?.setBlendMode(.normal)
            context?.strokePath()
            drawView.image = UIGraphicsGetImageFromCurrentImageContext()
            view.alpha = opacity
            UIGraphicsEndImageContext()
        }
    }
    
    func clearCanvas() {
        drawView.image = nil
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        self.tabBarController?.selectedIndex = 3
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        if !swiped {
            drawLineFrom(fromPoint: lastPoint, toPoint: lastPoint)
        }
        let mainRect = CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: self.view.frame.size.height)
        UIGraphicsBeginImageContext(drawView.frame.size)
        drawView.image?.draw(in: mainRect, blendMode: .normal, alpha: opacity)
        UIGraphicsEndImageContext()
    }
    
    @IBAction func cancelButtonClicked(_ sender: Any) {
        dismiss(animated: true, completion: nil)
        self.titleText.text = ""
        self.textField.text = ""
    }
    
    @IBAction func goToCrop(_ sender: Any) {
        if scrollView.isUserInteractionEnabled == false {
            scrollView.isUserInteractionEnabled = true
            drawButton.isHidden = true
            postButton.isHidden = true
            drawView.isHidden = true
        } else {
            drawView.isHidden = false
            cropButton.isHidden = true
            postButton.isHidden = true
            var renderedImage: UIImage!
            UIGraphicsBeginImageContextWithOptions(self.view.frame.size, false, 0)
            if let ctx = UIGraphicsGetCurrentContext() {
                self.photo.layer.render(in: ctx)
                renderedImage = UIGraphicsGetImageFromCurrentImageContext()
                UIGraphicsEndImageContext()
            }
            self.photo.image = nil
            self.photo.image = renderedImage
            cropButton.isHidden = false
            postButton.isHidden = false
            scrollView.isUserInteractionEnabled = false
            drawButton.isHidden = false
        }
    }
    
    @IBAction func saveButtonClick(_ sender: Any) {
        
        let canPost = networkNotification()
        
        if canPost == true {
            
            updateIndexes()
            
            self.view.endEditing(true)
            changeFontButton.isHidden = true
            cropButton.isHidden = true
            postButton.isHidden = true
            clearButton.isHidden = true
            drawButton.isHidden = true
            backBtn.isHidden = true
            hideColors()
            colorPickerButton.isHidden = true
            titleText.isHidden = true
            let object = PFObject(className: "posts")
            object["username"] = PFUser.current()!.username
            object["profilepic"] = PFUser.current()!.value(forKey: "profilepic") as! PFFile
            object["likes"] = 0
            object["index"] = 0
            object["pinned"] = autoPin
            object["time"] = "under"
            object["mediatype"] = "photo"
            object["lock"] = isItLocked
            let uuid = NSUUID().uuidString
            
            object["uuid"] = "\(String(describing: PFUser.current()!.username)) \(uuid)"
            
            let placeHolderImage = UIImagePNGRepresentation(#imageLiteral(resourceName: "PinButton.png"))
            object["photoLayer"] = PFFile(name: "PlaceHolder.png", data: placeHolderImage!)
            if titleText.text!.isEmpty {
                object["title"] = ""
            } else {
                object["title"] = titleText.text!.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
            }
            UIGraphicsBeginImageContextWithOptions(self.view.frame.size, false, 0)
            if let ctx = UIGraphicsGetCurrentContext() {
                self.view.layer.render(in: ctx)
                let renderedImage = UIGraphicsGetImageFromCurrentImageContext()
                UIGraphicsEndImageContext()
                let pictureData = UIImageJPEGRepresentation(renderedImage!, 0.5)
                let picFile = PFFile(name: "picturetopost.jpg", data: pictureData!)
                object["media"] = picFile
            }
            let words: [String] = titleText.text!.components(separatedBy: NSCharacterSet.whitespacesAndNewlines)
            for var word in words {
                if word.hasPrefix("#") {
                    word = word.trimmingCharacters(in: NSCharacterSet.punctuationCharacters)
                    word = word.trimmingCharacters(in: NSCharacterSet.symbols)
                    let hashtagObject = PFObject(className: "hashtag")
                    hashtagObject["to"] = "\(String(describing: PFUser.current()!.username)) \(uuid)"
                    hashtagObject["by"] = PFUser.current()?.username
                    hashtagObject["hashtag"] = word.lowercased()
                    hashtagObject["comment"] = titleText.text
                    hashtagObject.saveInBackground(block: { (success, error) in
                        if error == nil {
                            print("#\(word) created")
                        }
                        else {
                           
                            print(error!.localizedDescription)
                        }
                    })
                }
            }
            object.saveInBackground { (success, error) in
                if error == nil {
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: "uploaded"), object: nil)
                    self.viewDidLoad()
                    self.titleText.text = ""
                } else {
                  
                    print(error!.localizedDescription)
                }
            }
            
            
            self.performSegue(withIdentifier: "picPosted", sender: self)
        }
    }
    
    func updateIndexes() {
        let query = PFQuery(className: "posts")
        query.whereKey("username", equalTo: PFUser.current()!.username!)
        query.findObjectsInBackground { (objects, error) in
            if error == nil {
                
                for object in objects! {
                    var addTo = object.object(forKey: "index") as! Int

                    addTo = addTo + 1

                    object["index"] = addTo

                    object.saveInBackground(block: { (success, error) in
                        if error == nil {

                            print("updated")

                        }
                    })
                }
            } else {
               
                print(error!.localizedDescription)
            }
        }
    }
    
    func hideColors() {
        redButton.isHidden = true
        orangeButton.isHidden = true
        yellowButton.isHidden = true
        greenButton.isHidden = true
        blueButton.isHidden = true
        purpleButton.isHidden = true
        whiteButton.isHidden = true
        blackButton.isHidden = true
    }
    
    func showColors() {
        redButton.isHidden = false
        orangeButton.isHidden = false
        yellowButton.isHidden = false
        greenButton.isHidden = false
        blueButton.isHidden = false
        purpleButton.isHidden = false
        whiteButton.isHidden = false
        blackButton.isHidden = false
    }
    
    func hideTextColors() {
        redTextButton.isHidden = true
        orangeTextButton.isHidden = true
        yellowTextButton.isHidden = true
        greenTextButton.isHidden = true
        blueTextButton.isHidden = true
        purpleTextButton.isHidden = true
        whiteTextButton.isHidden = true
        blackTextButton.isHidden = true
    }
    
    func showTextColors() {
        redTextButton.isHidden = false
        orangeTextButton.isHidden = false
        yellowTextButton.isHidden = false
        greenTextButton.isHidden = false
        blueTextButton.isHidden = false
        purpleTextButton.isHidden = false
        whiteTextButton.isHidden = false
        blackTextButton.isHidden = false
    }
        
    @IBAction func changeFont(_ sender: Any) {
        
        
       
        if textField.font == optima || titleText.font == optima {
            
            textField.font = choko
            titleText.font = choko
        }
        else if textField.font == choko || titleText.font == choko {
            textField.font = threeD
            titleText.font = threeD
        }
        else if textField.font == threeD || titleText.font == threeD {
            textField.font = typeKeys
            titleText.font = typeKeys
        }
        else if textField.font == typeKeys || titleText.font == typeKeys {
            textField.font = stayClassy
            titleText.font = stayClassy
        }
        else if textField.font == stayClassy || titleText.font == stayClassy {
            textField.font = littleDays
            titleText.font = littleDays
        } else {
            textField.font = optima
            titleText.font = optima
        }
        
        if titleText.contentSize.height > titleText.frame.size.height {
            let difference = titleText.contentSize.height - titleText.frame.size.height
            print(difference)
            titleText.frame.origin.y = titleText.frame.origin.y - difference - 5
            titleText.frame.size.height = titleText.contentSize.height + 5
        } else if titleText.contentSize.height < titleText.bounds.size.height {
           
            
            //if titleText.contentSize.height > titleText.frame.size.height {
                print("running")
                let difference = titleText.contentSize.height - titleText.frame.size.height
                print(difference)
                titleText.frame.origin.y = titleText.frame.origin.y - difference - 5
                titleText.frame.size.height = titleText.contentSize.height + 5
            //}
        }
    }
    
    @IBAction func draw(_ sender: Any) {
        clearCanvas()
    }
        
        
    @IBAction func Red(_ sender: Any) {
        if allowDrawing == true {
            let red = UIColor(displayP3Red: 250/255, green: 20/255, blue: 35/255, alpha: 1)
            drawColor = red.cgColor
        } else {
            textField.textColor = UIColor(displayP3Red: 250/255, green: 20/255, blue: 35/255, alpha: 1)
            titleText.textColor = UIColor(displayP3Red: 250/255, green: 20/255, blue: 35/255, alpha: 1)
        }
    }
        
    @IBAction func BlackButton(_ sender: Any) {
        if allowDrawing == true {
            drawColor = UIColor.black.cgColor
        } else {
            textField.textColor = .black
            titleText.textColor = .black
        }
    }
        
    @IBAction func White(_ sender: Any) {
        if allowDrawing == true {
            drawColor = UIColor.white.cgColor
        } else {
            titleText.textColor = .white
            textField.textColor = .white
        }
    }
    
    @IBAction func Purple(_ sender: Any) {
        if allowDrawing == true {
            let purple = UIColor(displayP3Red: 177/255, green: 12/255, blue: 251/255, alpha: 1)
            drawColor = purple.cgColor
        } else {
            titleText.textColor = UIColor(displayP3Red: 177/255, green: 12/255, blue: 251/255, alpha: 1)
            textField.textColor = UIColor(displayP3Red: 177/255, green: 12/255, blue: 251/255, alpha: 1)
        }
    }
        
    @IBAction func Blue(_ sender: Any) {
        if allowDrawing == true {
            let blue = UIColor(displayP3Red: 72/255, green: 116/255, blue: 255/255, alpha: 1)
            drawColor = blue.cgColor
        } else {
            textField.textColor = UIColor(displayP3Red: 72/255, green: 116/255, blue: 255/255, alpha: 1)
            titleText.textColor = UIColor(displayP3Red: 72/255, green: 116/255, blue: 255/255, alpha: 1)
        }
    }
        
    @IBAction func Green(_ sender: Any) {
        if allowDrawing == true {
            let green = UIColor(displayP3Red: 43/255, green: 212/255, blue: 5/255, alpha: 1)
            drawColor = green.cgColor
        } else {
            titleText.textColor = UIColor(displayP3Red: 43/255, green: 212/255, blue: 5/255, alpha: 1)
            textField.textColor = UIColor(displayP3Red: 43/255, green: 212/255, blue: 5/255, alpha: 1)
        }
    }
    
    @IBAction func Yellow(_ sender: Any) {
        if allowDrawing == true {
            let yellow = UIColor(displayP3Red: 255/255, green: 233/255, blue: 64/255, alpha: 1)
            drawColor = yellow.cgColor
        } else {
            titleText.textColor = UIColor(displayP3Red: 255/255, green: 233/255, blue: 64/255, alpha: 1)
            textField.textColor = UIColor(displayP3Red: 255/255, green: 233/255, blue: 64/255, alpha: 1)
        }
    }

    @IBAction func Orange(_ sender: Any) {
        if allowDrawing == true {
            let orange = UIColor(displayP3Red: 255/255, green: 162/255, blue: 46/255, alpha: 1)
            drawColor = orange.cgColor
        } else {
            titleText.textColor = UIColor(displayP3Red: 255/255, green: 162/255, blue: 46/255, alpha: 1)
            textField.textColor = UIColor(displayP3Red: 255/255, green: 162/255, blue: 46/255, alpha: 1)
        }
    }
    
    @IBAction func ColorPicker(_ sender: Any) {
        if redButton.isHidden == true {
            showColors()
            UIView.animate(withDuration: 0.4, animations: {
                self.blackButton.frame = CGRect(x: self.colorPickerButton.frame.origin.x, y: self.colorPickerButton.frame.origin.y + 45, width: 40, height: 40)
                self.whiteButton.frame = CGRect(x: self.colorPickerButton.frame.origin.x, y: self.blackButton.frame.origin.y + 45, width: 40, height: 40)
                self.redButton.frame = CGRect(x: self.colorPickerButton.frame.origin.x, y: self.whiteButton.frame.origin.y + 45, width: 40, height: 40)
                self.orangeButton.frame = CGRect(x: self.colorPickerButton.frame.origin.x, y: self.redButton.frame.origin.y + 45, width: 40, height: 40)
                self.yellowButton.frame = CGRect(x: self.colorPickerButton.frame.origin.x, y: self.orangeButton.frame.origin.y + 45, width: 40, height: 40)
                self.greenButton.frame = CGRect(x: self.colorPickerButton.frame.origin.x, y: self.yellowButton.frame.origin.y + 45, width: 40, height: 40)
                self.blueButton.frame = CGRect(x: self.colorPickerButton.frame.origin.x, y: self.greenButton.frame.origin.y + 45, width: 40, height: 40)
                self.purpleButton.frame = CGRect(x: self.colorPickerButton.frame.origin.x, y: self.blueButton.frame.origin.y + 45, width: 40, height: 40)
            })
        } else {
            animateHideColors()
        }
    }
    
    func animateHideColors() {
        UIView.animate(withDuration: 0.4, animations: {
            self.blackButton.frame = self.colorPickerButton.frame
            self.whiteButton.frame = self.colorPickerButton.frame
            self.redButton.frame = self.colorPickerButton.frame
            self.orangeButton.frame = self.colorPickerButton.frame
            self.yellowButton.frame = self.colorPickerButton.frame
            self.greenButton.frame = self.colorPickerButton.frame
            self.blueButton.frame = self.colorPickerButton.frame
            self.purpleButton.frame = self.colorPickerButton.frame
        })
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.41) {
             self.hideColors()
        }
    }
    
    @IBAction func textColorPicker(_ sender: Any) {
        if redTextButton.isHidden == true {
            showTextColors()
            UIView.animate(withDuration: 0.4, animations: {
                self.blackTextButton.frame = CGRect(x: self.textColorPickerButton.frame.origin.x-55, y: 15, width: 40, height: 40)
                self.whiteTextButton.frame = CGRect(x: self.blackTextButton.frame.origin.x-55, y: 15, width: 40, height: 40)
                self.yellowTextButton.frame = CGRect(x: self.textColorPickerButton.frame.origin.x, y: self.textColorPickerButton.frame.origin.y + 55, width: 40, height: 40)
                self.orangeTextButton.frame = CGRect(x: self.blackTextButton.frame.origin.x, y: self.yellowTextButton.frame.origin.y, width: 40, height: 40)
                self.redTextButton.frame = CGRect(x: self.whiteTextButton.frame.origin.x, y: self.orangeTextButton.frame.origin.y, width: 40, height: 40)
                self.purpleTextButton.frame = CGRect(x: self.yellowTextButton.frame.origin.x, y: self.yellowTextButton.frame.origin.y + 55, width: 40, height: 40)
                self.blueTextButton.frame = CGRect(x: self.orangeTextButton.frame.origin.x, y: self.purpleTextButton.frame.origin.y, width: 40, height: 40)
                self.greenTextButton.frame = CGRect(x: self.redTextButton.frame.origin.x, y: self.blueTextButton.frame.origin.y, width: 40, height: 40)
                self.changeFontButton.frame = CGRect(x: self.whiteTextButton.frame.origin.x - 55, y: self.whiteTextButton.frame.origin.y, width: 40, height: 40)
            })
        } else {
            self.view.bringSubview(toFront: self.textColorPickerButton)
            UIView.animate(withDuration: 0.4, animations: {
                self.blackTextButton.frame = self.textColorPickerButton.frame
                self.whiteTextButton.frame = self.textColorPickerButton.frame
                self.yellowTextButton.frame = self.textColorPickerButton.frame
                self.orangeTextButton.frame = self.textColorPickerButton.frame
                self.redTextButton.frame = self.textColorPickerButton.frame
                self.purpleTextButton.frame = self.textColorPickerButton.frame
                self.blueTextButton.frame = self.textColorPickerButton.frame
                self.greenTextButton.frame = self.textColorPickerButton.frame
                self.changeFontButton.frame = CGRect(x: self.textColorPickerButton.frame.origin.x - 55, y: self.textColorPickerButton.frame.origin.y, width: 40, height: 40)
            })
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.35, execute: {
                self.hideTextColors()
            })
        }
    }
    
    @IBAction func eraser(_ sender: Any) {
        if allowDrawing == true {
            lineColor = .clear
            hideColors()
        } else {
            titleText.textColor = UIColor(displayP3Red: 255/255, green: 162/255, blue: 46/255, alpha: 1)
            textField.textColor = UIColor(displayP3Red: 255/255, green: 162/255, blue: 46/255, alpha: 1)
        }
    }
    
    @objc func showKeyboard(notification: NSNotification) {
        
        keyboard = ((notification.userInfo?[UIKeyboardFrameEndUserInfoKey]! as AnyObject).cgRectValue)!
        self.titleText.frame.size.width = self.view.frame.size.width
        self.textField.frame.size.width = self.view.frame.size.width
        self.titleText.frame.origin.y = self.view.frame.size.height - self.titleText.frame.size.height + commentHeight - keyboard.height - 10
        self.textField.frame.origin.y = self.view.frame.size.height - self.textField.frame.size.height + commentHeight - keyboard.height
        print(textField.frame.size.height)
    }
}
