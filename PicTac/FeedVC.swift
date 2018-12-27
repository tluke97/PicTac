//
//  FeedVC.swift
//  CorkBoard
//
//  Created by Tanner Luke on 10/26/17.
//  Copyright © 2017 CorkBoard Co. All rights reserved.
//

import UIKit
import Parse
import AVFoundation
import UserNotifications

var postUUID = [String]()
var postAtIndex: Int!
var globalTypeArray = [String]()

class FeedVC: UITableViewController {
    
    @IBOutlet weak var indicator: UIActivityIndicatorView!
    @IBOutlet weak var indicatorView: UIView!
    var refresher = UIRefreshControl()
    var index: Int = 0
    var usernameArray = [String]()
    var uuidArray = [String]()
    var profilePicArray = [PFFile]()
    var timeArray = [Date?]()
    var likeArray = [Int]()
    var indexArray = [Int]()
    var typeArray = [String]()
    var doneLoading: Bool = false
    var canReload = true
    var amountOfPosts = 0
    var followArray = [String]()
    var page: Int = 12
    let generator = UIImpactFeedbackGenerator(style: .heavy)
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        /*
        let findUserId = PFQuery(className: "Installation")
        findUserId.whereKey("userId", equalTo: PFUser.current()?.objectId)
        findUserId.findObjectsInBackground { (objects, error) in
            if error == nil {
                
                for object in objects! {
                    object["username"] = PFUser.current()!.username!
                    object.saveInBackground()
                }
                
            }
        }
        
        */
        if runTheData == true {
            createInstallationOnParse(deviceTokenData: theData!)
        }
      
        
        
        _ = networkNotification()
        
        NotificationCenter.default.addObserver(self, selector: #selector(FeedVC.likeThePost), name: NSNotification.Name(rawValue: "likedPost"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(FeedVC.unlikeThePost), name: NSNotification.Name(rawValue: "unlikedPost"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(FeedVC.musicPlay), name: NSNotification.Name(rawValue: "resumeMusic"), object: nil)
        self.indicatorView.frame = CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: self.view.frame.size.width)
        self.indicatorView.isHidden = false
        self.navigationItem.title = "Home"
        NotificationCenter.default.addObserver(self, selector: #selector(FeedVC.likeButton(_:)), name: NSNotification.Name(rawValue: "liked"), object: nil)
        generator.prepare()
        refresher.addTarget(self, action: #selector(FeedVC.refresh(notification:))  , for: UIControlEvents.valueChanged)
        self.tableView.addSubview(refresher)
        indicator.center.x = tableView.center.x
        NotificationCenter.default.addObserver(self, selector: #selector(FeedVC.uploaded(notification:)), name: NSNotification.Name(rawValue: "uploaded"), object: nil)
        self.tabBarController?.tabBar.isHidden = false
        query()
        loadPosts()
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        
        //askToSendPushnotifications()
    }
    
    
    
    
    
    
    
    func createInstallationOnParse(deviceTokenData:Data){
        print("installing")
        if let installation = PFInstallation.current(){
            installation.setDeviceTokenFrom(deviceTokenData)
            installation.setObject(["News"], forKey: "channels")
            if let userId = PFUser.current()?.objectId {
                installation.setObject(userId, forKey: "userId")
                
            }
            
            installation.saveInBackground {
                (success: Bool, error: Error?) in
                if (success) {
                    print("You have successfully saved your push installation to Back4App!")
                } else {
                    if let myError = error{
                        print("Error saving parse installation \(myError.localizedDescription)")
                    }else{
                        print("Uknown error")
                    }
                }
            }
        }
    }
    
    
    
    
    
    
    
    
    func askToSendPushnotifications() {
        let alertView = UIAlertController(title: "Send a push to the news channel", message: nil, preferredStyle: .alert)
        let OKAction = UIAlertAction(title: "OK", style: .default) { (action:UIAlertAction) in
            //self.sendLikeNotifications()
            
        }
        alertView.addAction(OKAction)
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (action:UIAlertAction) in
        }
        alertView.addAction(cancelAction)
        if let presenter = alertView.popoverPresentationController {
            presenter.sourceView = self.view
            presenter.sourceRect = self.view.bounds
        }
        self.present(alertView, animated: true, completion:nil)
    }
    
    func sendLikeNotifications(username: String) {
        
        
        
        
        
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
        
        
        
 
        /*
        let text = "\(PFUser.current()!.username!) liked your picture, or whatever you want to say here";
        let data = [
            "badge" : "Increment",
            "alert" : text,
            ]
        let request: [String : Any] = [
            "someKey" : PFUser.current()!.objectId!,
            //PFUser.current()!.objectId!,
            "data" : data
        ]
        print("sending push notification...")
        PFCloud.callFunction(inBackground: "pushToFollowers", withParameters: request as [NSObject : AnyObject], block: { (results:AnyObject?, error:NSError?) in
            print("push (String(describing: results!))")
            if error == nil {
                print (results!)
            }
            else {
                print (error!)
            }
            } as? PFIdResultBlock)
 */
    }
    
    
    
    
    
    
    
    
    
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        self.tabBarController?.tabBar.isHidden = false
    }
    
    @objc func musicPlay() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            do {
                try AVAudioSession.sharedInstance().setActive(false, with: .notifyOthersOnDeactivation)
            } catch {
                print ("setActive(false) ERROR : \(error)")
            }
        }
        
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
                self.parseErrorAlert()
                print(error!.localizedDescription)
            }
        }
    }
    
    func networkNotification() -> Bool {
        let stopAnimator: Bool!
        
        if Reachability.isConnectedToNetwork() {
            
            print("connected")
            stopAnimator = true
        } else {
            
            stopAnimator = true
            UIView.animate(withDuration: 0.5) {
                 self.tableView.contentOffset = CGPoint(x: 0, y: 0)
            }
            self.refresher.endRefreshing()
            let alert = UIAlertController(title: "Network Error", message: "Sorry, but there appears to be an error with your internet connection. Please try again later.", preferredStyle: .alert)
            let okay = UIAlertAction(title: "Okay", style: UIAlertActionStyle.cancel, handler: nil)
            alert.addAction(okay)
            present(alert, animated: true, completion: nil)
            
        }
        return stopAnimator
    }
    
    @objc func loadPosts() {
        
        let followQuery = PFQuery(className: "follow")
        followQuery.whereKey("follower", equalTo: PFUser.current()!.username!)
        followQuery.findObjectsInBackground { (objects, error) in
            if error == nil {
                self.followArray.removeAll(keepingCapacity: false)
                for object in objects! {
                    self.followArray.append(object.object(forKey: "following") as! String)
                }
                self.followArray.append(PFUser.current()!.username!)
                let query = PFQuery(className: "posts")
                query.whereKey("username", containedIn: self.followArray)
                query.whereKey("time", contains: "under")
                query.limit = self.page
                query.addDescendingOrder("createdAt")
                query.findObjectsInBackground(block: { (objects, error) in
                    if error == nil {
                        self.usernameArray.removeAll(keepingCapacity: false)
                        self.profilePicArray.removeAll(keepingCapacity: false)
                        self.timeArray.removeAll(keepingCapacity: false)
                        self.uuidArray.removeAll(keepingCapacity: false)
                        self.typeArray.removeAll(keepingCapacity: false)
                        for object in objects! {
                            self.usernameArray.append(object.object(forKey: "username") as! String)
                            self.profilePicArray.append(object.object(forKey: "profilepic") as! PFFile)
                            self.timeArray.append(object.createdAt)
                            self.uuidArray.append(object.object(forKey: "uuid") as! String)
                            self.typeArray.append(object.object(forKey: "mediatype") as! String)
                        }
                        self.indexArray.removeAll(keepingCapacity: false)
                        self.tableView.reloadData()
                        self.amountOfPosts = self.uuidArray.count
                        print(self.amountOfPosts)
                        self.doneLoading = true
                        self.refresher.endRefreshing()
                    } else {
                        self.parseErrorAlert()
                        print(error!.localizedDescription)
                        
                    }
                })
            } else {
                self.parseErrorAlert()
                print(error!.localizedDescription)
            }
        }
        self.indicatorView.isHidden = true
    }
    
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView.contentOffset.y >= scrollView.contentSize.height - self.view.frame.size.height * 2 {
            loadMore()
        }
    }
    
    

    func loadMore() {
        if page <= uuidArray.count {
            indicator.startAnimating()
            page = page + 20
            let followQuery = PFQuery(className: "follow")
            followQuery.whereKey("follower", equalTo: PFUser.current()!.username!)
            followQuery.findObjectsInBackground { (objects, error) in
                if error == nil {
                    self.followArray.removeAll(keepingCapacity: false)
                    for object in objects! {
                        self.followArray.append(object.object(forKey: "following") as! String)
                    }
                    self.followArray.append(PFUser.current()!.username!)
                    let query = PFQuery(className: "posts")
                    query.whereKey("username", containedIn: self.followArray)
                    query.whereKey("time", equalTo: "under")
                    query.limit = self.page
                    query.addDescendingOrder("createdAt")
                    query.findObjectsInBackground(block: { (objects, error) in
                        if error == nil {
                            self.usernameArray.removeAll(keepingCapacity: false)
                            self.profilePicArray.removeAll(keepingCapacity: false)
                            self.timeArray.removeAll(keepingCapacity: false)
                            self.uuidArray.removeAll(keepingCapacity: false)
                            self.typeArray.removeAll(keepingCapacity: false)
                            for object in objects! {
                                self.usernameArray.append(object.object(forKey: "username") as! String)
                                self.profilePicArray.append(object.object(forKey: "profilepic") as! PFFile)
                                self.timeArray.append(object.createdAt)
                                self.uuidArray.append(object.object(forKey: "uuid") as! String)
                                self.typeArray.append(object.object(forKey: "mediatype") as! String)
                            }
                            self.tableView.reloadData()
                            self.amountOfPosts = self.uuidArray.count
                            print(self.amountOfPosts)
                            self.indicator.stopAnimating()
                        } else {
                            self.parseErrorAlert()
                            print(error!.localizedDescription)
                        }
                    })
                } else {
                    self.parseErrorAlert()
                    print(error!.localizedDescription)
                }
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if uuidArray.count != 0 {
        return uuidArray.count
        } else {
            return 1
        }
    }
    
    @objc func goToProfile(sender: UITapGestureRecognizer) {
        let buttonPosition = sender.location(in: tableView)
        if let indexPath = tableView.indexPathForRow(at: buttonPosition) {
            let cell = self.tableView.cellForRow(at: indexPath) as! FeedCell
            if cell.username.text! == PFUser.current()?.username {
                let home = self.storyboard?.instantiateViewController(withIdentifier: "HomePageVC") as! HomePageVC
                self.navigationController?.pushViewController(home, animated: true)
            } else {
                friendName.append(cell.username.text!)
                let friend = self.storyboard?.instantiateViewController(withIdentifier: "FriendProfileVC") as! FriendProfileVC
                self.navigationController?.pushViewController(friend, animated: true)
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if amountOfPosts != 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! FeedCell
            let tapProfile = UITapGestureRecognizer(target: self, action: #selector(FeedVC.goToProfile(sender:)))
            tapProfile.numberOfTapsRequired = 1
            cell.profilePic.isUserInteractionEnabled = true
            cell.profilePic.addGestureRecognizer(tapProfile)
            cell.username.text = usernameArray[indexPath.row]
            cell.uuidLabel.text = uuidArray[indexPath.row]
            profilePicArray[indexPath.row].getDataInBackground { (data, error) -> Void in
                cell.profilePic.image = UIImage(data: data!)
            }
            let from = timeArray[indexPath.row]
            let now = Date()
            let components : NSCalendar.Unit = [.second, .minute, .hour, .day, .weekOfMonth]
            let difference = (Calendar.current as NSCalendar).components(components, from: from!, to: now, options: [])
            if difference.second! <= 0 {
                let timeQuery = PFQuery(className: "posts")
                timeQuery.whereKey("uuid", equalTo: cell.uuidLabel.text!)
                timeQuery.findObjectsInBackground(block: { (objects, error) in
                    if error == nil {
                        for object in objects! {
                            object["time"] = "under"
                            object.saveEventually()
                        }
                    } else {
                        print(error!.localizedDescription)
                    }
                })
                cell.dateLabel.text = "now"
            }
            if difference.second! > 0 && difference.minute! == 0 {
                cell.dateLabel.text = "\(difference.second!)s"
            }
            if difference.minute! > 0 && difference.hour! == 0 {
                cell.dateLabel.text = "\(difference.minute!)m"
            }
            if difference.hour! > 0 && difference.day! == 0 {
                cell.dateLabel.text = "\(difference.hour!)h"
            }
            if difference.day! > 0 && difference.weekOfMonth! == 0 {
                amountOfPosts -= 1
                cell.isHidden = true
                let timeQuery = PFQuery(className: "posts")
                timeQuery.whereKey("uuid", equalTo: cell.uuidLabel.text!)
                timeQuery.findObjectsInBackground(block: { (objects, error) in
                    if error == nil {
                        for object in objects! {
                            let thePin = object["pinned"] as! Bool
                            if thePin == true {
                                object["time"] = "over"
                                object.saveEventually()
                            } else {
                                object.deleteInBackground(block: { (success, error) in
                                    if error == nil {
                                        let likeQuery = PFQuery(className: "likes")
                                        likeQuery.whereKey("to", equalTo: cell.uuidLabel.text!)
                                        likeQuery.findObjectsInBackground { (objects, error) in
                                            if error == nil {
                                                for object in objects! {
                                                    object.deleteEventually()
                                                }
                                            } else {
                                                self.parseErrorAlert()
                                                print(error!.localizedDescription)
                                            }
                                        }
                                        let commentQuery = PFQuery(className: "comments")
                                        commentQuery.whereKey("to", equalTo: cell.uuidLabel.text!)
                                        commentQuery.findObjectsInBackground { (objects, error) in
                                            if error == nil {
                                                for object in objects! {
                                                    object.deleteEventually()
                                                }
                                            } else {
                                                self.parseErrorAlert()
                                                print(error!.localizedDescription)
                                            }
                                        }
                                        let hashtagQuery = PFQuery(className: "hashtag")
                                        hashtagQuery.whereKey("to", equalTo: cell.uuidLabel.text!)
                                        hashtagQuery.findObjectsInBackground { (objects, error) in
                                            if error == nil {
                                                for object in objects! {
                                                    object.deleteEventually()
                                                }
                                            } else {
                                                self.parseErrorAlert()
                                                print(error!.localizedDescription)
                                            }
                                        }
                                        let notificationQuery = PFQuery(className: "notification")
                                        notificationQuery.whereKey("uuid", equalTo: cell.uuidLabel.text!)
                                        notificationQuery.findObjectsInBackground(block: { (objects, error) in
                                            if error == nil {
                                                for object in objects! {
                                                    object.deleteEventually()
                                                }
                                            }
                                        })
                                    } else {
                                        self.parseErrorAlert()
                                        print(error!.localizedDescription)
                                    }
                                })
                             }
                        }
                    } else {
                        self.parseErrorAlert()
                        print(error!.localizedDescription)
                    }
                })
                cell.dateLabel.text = "\(difference.day!)d"
            }
            if difference.weekOfMonth! > 0 {
                amountOfPosts -= 1
                cell.isHidden = true
                cell.dateLabel.text = "\(difference.weekOfMonth!)w"
                let timeQuery = PFQuery(className: "posts")
                timeQuery.whereKey("uuid", equalTo: cell.uuidLabel.text!)
                timeQuery.findObjectsInBackground(block: { (objects, error) in
                    if error == nil {
                        for object in objects! {
                            let thePin = object["pinned"] as! Bool
                            if thePin == true {
                                object["time"] = "over"
                                object.saveEventually()
                            } else {
                                object.deleteInBackground(block: { (success, error) in
                                    if error == nil {
                                        let likeQuery = PFQuery(className: "likes")
                                        likeQuery.whereKey("to", equalTo: cell.uuidLabel.text!)
                                        likeQuery.findObjectsInBackground { (objects, error) in
                                            if error == nil {
                                                for object in objects! {
                                                    object.deleteEventually()
                                                }
                                            } else {
                                                self.parseErrorAlert()
                                                print(error!.localizedDescription)
                                            }
                                        }
                                        let commentQuery = PFQuery(className: "comments")
                                        commentQuery.whereKey("to", equalTo: cell.uuidLabel.text!)
                                        commentQuery.findObjectsInBackground { (objects, error) in
                                            if error == nil {
                                                for object in objects! {
                                                    object.deleteEventually()
                                                }
                                            } else {
                                                self.parseErrorAlert()
                                                print(error!.localizedDescription)
                                            }
                                        }
                                        let hashtagQuery = PFQuery(className: "hashtag")
                                        hashtagQuery.whereKey("to", equalTo: cell.uuidLabel.text!)
                                        hashtagQuery.findObjectsInBackground { (objects, error) in
                                            if error == nil {
                                                for object in objects! {
                                                    object.deleteEventually()
                                                }
                                            } else {
                                                self.parseErrorAlert()
                                                print(error!.localizedDescription)
                                            }
                                        }
                                        let notificationQuery = PFQuery(className: "notification")
                                        notificationQuery.whereKey("uuid", equalTo: cell.uuidLabel.text!)
                                        notificationQuery.findObjectsInBackground(block: { (objects, error) in
                                            if error == nil {
                                                for object in objects! {
                                                    object.deleteEventually()
                                                }
                                            }
                                        })
                                    } else {
                                        self.parseErrorAlert()
                                        print(error!.localizedDescription)
                                    }
                                })
                            }
                        }
                    } else {
                        self.parseErrorAlert()
                        print(error!.localizedDescription)
                    }
                })
            }
            let didLike = PFQuery(className: "likes")
            didLike.whereKey("by", equalTo: PFUser.current()!.username!)
            didLike.whereKey("to", equalTo: cell.uuidLabel.text!)
            didLike.countObjectsInBackground { (count, error) in
                if count == 0 {
                    cell.likeButton.setTitle("unlike", for: UIControlState.normal)
                    cell.likeButton.setBackgroundImage(UIImage(named: "unlike.png"), for: UIControlState.normal)
                } else {
                    cell.likeButton.setTitle("like", for: UIControlState.normal)
                    cell.likeButton.setBackgroundImage(UIImage(named: "like.png"), for: UIControlState.normal)
                }
            }
            let countLikes = PFQuery(className: "likes")
            countLikes.whereKey("to", equalTo: cell.uuidLabel.text!)
            countLikes.countObjectsInBackground { (count, error) in
                if error == nil {
                    if count == 0 {
                        cell.likeLabel.isHidden = true
                        cell.likeLabel.text = String(count)
                    } else {
                        cell.likeLabel.isHidden = false
                        cell.likeLabel.text = String(count)
                    }
                } else {
                    self.parseErrorAlert()
                    print(error!.localizedDescription)
                }
            }
            let postQuery = PFQuery(className: "posts")
            postQuery.whereKey("uuid", equalTo: cell.uuidLabel.text!)
            postQuery.findObjectsInBackground { (objects, error) in
                if error == nil {
                    for object in objects! {
                        let pin = object["pinned"] as! Bool
                        let time = object["time"] as! String
                        if pin == false && time == "over" {
                            object.deleteInBackground(block: { (success, error) in
                                if error == nil {
                                    if self.amountOfPosts == 0 {
                                        self.viewDidLoad()
                                    } else {
                                        self.parseErrorAlert()
                                        print(error!.localizedDescription)
                                    }
                                }
                            })
                        }
                    }
                }
            }
            if self.amountOfPosts != 0 {
                self.tableView.rowHeight = 65
                return cell
            } else {
                
                let theCell = self.tableView.dequeueReusableCell(withIdentifier: "NoPostsCell") as! NoPostsCell
                self.tableView.rowHeight = 90
                if doneLoading == false {
                    cell.isHidden = true
                } else {
                    cell.isHidden = false
                }
                self.viewDidLoad()
                return theCell
                
                
            }
            
        }  else {
            let cell = self.tableView.dequeueReusableCell(withIdentifier: "NoPostsCell") as! NoPostsCell
            self.tableView.rowHeight = 90
            if doneLoading == false {
                cell.isHidden = true
            } else {
                cell.isHidden = false
            }
            return cell
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if tableView.cellForRow(at: indexPath)?.selectionStyle == .default {
            globalTypeArray = typeArray
            postUUID = uuidArray
            indexArray.append(indexPath.row)
            postAtIndex = indexPath.row
            self.performSegue(withIdentifier: "fromFeed", sender: self)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "fromFeed" {
            let destinationViewController = segue.destination as? Post
            let value = true
            destinationViewController?.fromWhere = value
        }
    }

    @IBAction func likeButton(_ sender: AnyObject) {
        generator.impactOccurred()
        let buttonPosition = sender.convert(CGPoint.zero, to: tableView)
        let indexPath: IndexPath? = tableView.indexPathForRow(at: buttonPosition)
        let cell = self.tableView.cellForRow(at: indexPath!) as! FeedCell
        cell.likeButton.isEnabled = false
        var likeNumber: Int?
        let number = Int(cell.likeLabel.text!)!
        if cell.likeButton.titleLabel?.text == "unlike" {
            UIView.animate(withDuration: 0.8) { () -> Void in
                cell.likeButton.transform = CGAffineTransform(rotationAngle: CGFloat.pi)
            }
            UIView.animate(withDuration: 0.8, delay: 0, options: UIViewAnimationOptions.curveEaseIn, animations: { () -> Void in
                cell.likeButton.transform = CGAffineTransform(rotationAngle: CGFloat.pi * 2.0)
            }, completion: nil)
            cell.likeButton.setTitle("like", for: UIControlState.normal)
            cell.likeButton.setBackgroundImage(UIImage(named: "like.png"), for: UIControlState.normal)
            let object = PFObject(className: "likes")
            object["by"] = PFUser.current()?.username
            object["to"] = cell.uuidLabel.text
            
            object.saveInBackground(block: { (success, error) in
                
                if error == nil {
                    
                    let shouldSendNote = PFQuery(className: "notification")
                    shouldSendNote.whereKey("uuid", equalTo: cell.uuidLabel.text!)
                    shouldSendNote.whereKey("by", equalTo: PFUser.current()!.username!)
                    shouldSendNote.countObjectsInBackground(block: { (count, error) in
                        if error == nil {
                            if count == 0 {
                                self.sendLikeNotifications(username: cell.username.text!)
                            }
                        }
                    })
                    
                    
                    
                    if number == 0 {
                        likeNumber = Int(cell.likeLabel.text!)! + 1
                        cell.likeLabel.text = String(likeNumber!)
                        cell.likeLabel.isHidden = false
                    } else {
                        likeNumber = Int(cell.likeLabel.text!)! + 1
                        cell.likeLabel.text = String(likeNumber!)
                        cell.likeLabel.isHidden = false
                    }
                    if cell.username.text != PFUser.current()!.username! {
                        let notificationObject = PFObject(className: "notification")
                        notificationObject["by"] = PFUser.current()?.username
                        notificationObject["profilepic"] = PFUser.current()?.object(forKey: "profilepic") as! PFFile
                        notificationObject["to"] = cell.username.text
                        notificationObject["owner"] = cell.username.text
                        notificationObject["uuid"] = cell.uuidLabel.text
                        notificationObject["type"] = "like"
                        notificationObject["checked"] = "no"
                        notificationObject.saveEventually()
                        
                        
                        
                    }
                }
            }
        )} else if cell.likeButton.titleLabel?.text == "like" {
            cell.likeButton.setTitle("unlike", for: UIControlState.normal)
            cell.likeButton.setBackgroundImage(UIImage(named: "unlike.png"), for: UIControlState.normal)
            let query = PFQuery(className: "likes")
            query.whereKey("by", equalTo: PFUser.current()!.username!)
            query.whereKey("to", equalTo: cell.uuidLabel.text!)
            query.findObjectsInBackground(block: { (objects, error) in
                for object in objects! {
                    object.deleteInBackground(block: { (success, error) in
                        if error == nil {
                            if number == 1 {
                            likeNumber = Int(cell.likeLabel.text!)! - 1
                            cell.likeLabel.text = String(likeNumber!)
                                cell.likeLabel.isHidden = true
                            } else {
                                likeNumber = Int(cell.likeLabel.text!)! - 1
                                cell.likeLabel.text = String(likeNumber!)
                                cell.likeLabel.isHidden = false
                            }
                            /*
                            let notificationQuery = PFQuery(className: "notification")
                            notificationQuery.whereKey("to", equalTo: cell.username.text!)
                            notificationQuery.whereKey("by", equalTo: PFUser.current()!.username!)
                            notificationQuery.whereKey("uuid", equalTo: cell.uuidLabel.text!)
                            notificationQuery.whereKey("type", equalTo: "like")
                            notificationQuery.findObjectsInBackground(block: { (objects, error) in
                                if error == nil {
                                    for object in objects! {
                                        object.deleteEventually()
                                    }
                                }
                            })
                            */
                        }
                    }
                )}
            }
        )}
        cell.likeButton.isEnabled = true
    }
    
    @objc func refresh(notification: NSNotification) {
        //viewDidLoad()
        
        let boomHeyThere = networkNotification()
        
        if boomHeyThere == true {
            print("run")
            if canReload == true {
                loadPosts()
                canReload = false
            
                DispatchQueue.main.asyncAfter(deadline: .now() + 5, execute: {
                    self.canReload = true
                })
            } else if canReload == false  {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: {
                    self.refresher.endRefreshing()
                })
            }
        }
        
    }
    
    @objc func uploaded(notification: NSNotification) {
        loadPosts()
    }
    
    @objc func loadLikes() {
        self.tableView.reloadData()
    }
        
    func checkPosts() {
        let followQuery = PFQuery(className: "follow")
        followQuery.whereKey("follower", equalTo: PFUser.current()!.username!)
        followQuery.findObjectsInBackground { (objects, error) in
            if error == nil {
                self.followArray.removeAll(keepingCapacity: false)
                for object in objects! {
                    self.followArray.append(object.object(forKey: "following") as! String)
                }
                self.followArray.append(PFUser.current()!.username!)
            }
        }
    }
    
    @IBAction func postSomething(_ sender: Any) {
        self.tabBarController?.selectedIndex = 2
    }
    
    @objc func likeThePost() {
        if indexArray.isEmpty == false {
            let indexPath = IndexPath(row: indexArray.last!, section: 0)
            let cell = self.tableView.cellForRow(at: indexPath) as! FeedCell
            cell.likeButton.isEnabled = false
            var likeNumber: Int?
            let number = Int(cell.likeLabel.text!)!
            cell.likeButton.setTitle("like", for: UIControlState.normal)
            cell.likeButton.setBackgroundImage(UIImage(named: "like.png"), for: UIControlState.normal)
            if number == 0 {
                likeNumber = Int(cell.likeLabel.text!)! + 1
                cell.likeLabel.text = String(likeNumber!)
                cell.likeLabel.isHidden = false
            } else {
                likeNumber = Int(cell.likeLabel.text!)! + 1
                cell.likeLabel.text = String(likeNumber!)
                cell.likeLabel.isHidden = false
            }
            cell.likeButton.isEnabled = true
        }
    }
       
    @objc func unlikeThePost() {
        if indexArray.isEmpty == false {
            let indexPath = IndexPath(row: indexArray.last!, section: 0)
            let cell = self.tableView.cellForRow(at: indexPath) as! FeedCell
            cell.likeButton.isEnabled = false
            var likeNumber: Int?
            let number = Int(cell.likeLabel.text!)!
            cell.likeButton.setTitle("unlike", for: UIControlState.normal)
            cell.likeButton.setBackgroundImage(UIImage(named: "unlike.png"), for: UIControlState.normal)
                if number == 1 {
                    likeNumber = Int(cell.likeLabel.text!)! - 1
                    cell.likeLabel.text = String(likeNumber!)
                    cell.likeLabel.isHidden = true
                } else {
                    likeNumber = Int(cell.likeLabel.text!)! - 1
                    cell.likeLabel.text = String(likeNumber!)
                    cell.likeLabel.isHidden = false
                }
            cell.likeButton.isEnabled = true
        }
    }
}

extension UIViewController {
    func parseErrorAlert() {
       
            let alert = UIAlertController(title: "Error", message: "There was an error while retrieving data", preferredStyle: UIAlertControllerStyle.alert)
            let ok = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel, handler: nil)
        
                
                
        
            alert.addAction(ok)
    
            present(alert, animated: true, completion: nil)
            
    }
        
        
    
}

