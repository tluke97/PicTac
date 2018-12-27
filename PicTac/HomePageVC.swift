//
//  HomePageVC.swift
//  CorkBoard
//
//  Created by Tanner Luke on 10/15/17.
//  Copyright © 2017 CorkBoard Co. All rights reserved.
//

import UIKit
import Parse
import AVFoundation


class HomePageVC: UICollectionViewController {
   
    var refresher: UIRefreshControl!
    var page: Int = 12
    var uuidArray = [String]()
    var picArray = [PFFile]()
    var mediaTypeArray = [String]()
    var timeArray = [Date?]()
    var player = AVPlayer()
    var playerLayer: AVPlayerLayer!
    var time: String!
    var bioHeight: String!
    var viewToRemove = [UIView]()
    var height: CGFloat = 0
    
    var myUsername: String?
    var myFullName: String?
    var myImage: UIImage?
    
    @IBOutlet weak var followingView: UIView!
    

    override func viewDidLoad() {
        super.viewDidLoad()
        networkNotification()
        self.collectionView?.alwaysBounceVertical = true
        refresher = UIRefreshControl()
        refresher.addTarget(self, action: #selector(HomePageVC.refresh), for: UIControlEvents.valueChanged)
        collectionView?.addSubview(refresher)
        
        
        NotificationCenter.default.addObserver(self, selector: #selector(HomePageVC.reload(_:)), name: NSNotification.Name(rawValue: "reload"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(HomePageVC.updateBio), name: NSNotification.Name(rawValue: "reloadBio"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(HomePageVC.updateBio), name: NSNotification.Name(rawValue: "reloadTable"), object: nil)
        loadPosts()
        
        
        
        getBio()
        
        self.navigationController?.navigationBar.isHidden = false
    }
   
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
    }
    
    func networkNotification() {
        if Reachability.isConnectedToNetwork() {
            
            print("connected")
        } else {
            
            let alert = UIAlertController(title: "Network Error", message: "Sorry, but there appears to be an error with your internet connection. Please try again later.", preferredStyle: .alert)
            let okay = UIAlertAction(title: "Okay", style: UIAlertActionStyle.cancel, handler: nil)
            alert.addAction(okay)
            present(alert, animated: true, completion: nil)
        }
    }
    
    
    
    
    func getBio() {
        
        let query = PFQuery(className: "_User")
        query.whereKey("username", equalTo: PFUser.current()!.username!)
        query.findObjectsInBackground { (objects, error) in
            if error == nil {
                for object in objects! {
                    
                   
                    
                    
                    self.bioHeight = object.object(forKey: "bio") as? String
                    print(self.bioHeight)
                    let checkTextHeight = UITextView(frame: CGRect(x: 20, y: 100, width: self.view.frame.size.width - 45, height: 200))
                    checkTextHeight.font = UIFont(name: "Helvetica Neue", size: 15)
                    checkTextHeight.textContainerInset = UIEdgeInsets(top: 5, left: 0, bottom: 0, right: 0)
                    checkTextHeight.textColor = .clear
                    checkTextHeight.isHidden = true
                    checkTextHeight.isUserInteractionEnabled = false
                    checkTextHeight.backgroundColor = .clear
                    self.view.addSubview(checkTextHeight)
                    checkTextHeight.text = self.bioHeight
                    //checkTextHeight.sizeToFit()
                    
                    
                    //self.height = checkTextHeight.frame.size.height + 2
                    self.height = checkTextHeight.contentSize.height
                    print(self.height)
                    
                    let width = UIScreen.main.bounds.width
                    let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
                    
                    if self.bioHeight == "" || self.bioHeight ==  " " || self.bioHeight == "  " {
                        print("this")
                        layout.headerReferenceSize = CGSize(width: 360, height: 220)
                    } else {
                        
                        print("hello")
                        
                        print(self.bioHeight)
                        print(self.height)
                        layout.headerReferenceSize = CGSize(width: 360, height: 220 + self.height)
                    }
                    layout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 10, right: 0)
                    layout.itemSize = CGSize(width: (width/4)-1, height: (width/4))
                    layout.minimumInteritemSpacing = 0.5
                    layout.minimumLineSpacing = 0.5
                    self.collectionView!.collectionViewLayout = layout
                    print(layout.headerReferenceSize)
                }
                
            } else {
                self.parseErrorAlert()
                print(error!.localizedDescription)
            }
        }
        
        
    }
   
    @objc func reloadData(notification: NSNotification) {
        collectionView?.reloadData()
    }
    
    @objc func refresh() {
       loadPosts()
    }
    
    @objc func updateBio() {
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        bioHeight = PFUser.current()?.object(forKey: "bio")! as? String
        if bioHeight == "" {
            layout.headerReferenceSize = CGSize(width: 360, height: 250)
        } else {
            layout.headerReferenceSize = CGSize(width: 360, height: 290)
        }
        self.view.setNeedsLayout()
        self.view.layoutIfNeeded()
        self.refresher.removeTarget(self, action: #selector(HomePageVC.refresh), for: UIControlEvents.valueChanged)
        self.refresher.removeFromSuperview()
        self.refresher = nil
        self.viewDidLoad()
    }
    
    @objc func reload(_ notification:Notification) {
        collectionView?.reloadData()
    }
    
    func loadPosts() {
        let query = PFQuery(className: "posts")
        query.whereKey("username", equalTo: PFUser.current()!.username!)
        query.addAscendingOrder("index")
        query.limit = page
        query.findObjectsInBackground { (objects, error) in
            if error == nil{
                self.uuidArray.removeAll(keepingCapacity: false)
                self.picArray.removeAll(keepingCapacity: false)
                self.mediaTypeArray.removeAll(keepingCapacity: false)
                self.timeArray.removeAll(keepingCapacity: false)
                for object in objects! {
                    self.uuidArray.append(object.value(forKey: "uuid") as! String)
                    self.picArray.append(object.value(forKey: "media") as! PFFile)
                    self.mediaTypeArray.append(object.value(forKey: "mediatype") as! String)
                    self.timeArray.append(object.createdAt)
                }
                self.collectionView?.reloadData()
                self.refresher.endRefreshing()
            }
            else{
                self.parseErrorAlert()
                print(error!.localizedDescription)
            }
        }
    }
    
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView.contentOffset.y >= scrollView.contentSize.height - self.view.frame.size.height {
            loadmore()
        }
    }
    
    func loadmore() {
        if page <= picArray.count {
            page = page + 12
            let query = PFQuery(className: "posts")
            query.whereKey("username", equalTo: PFUser.current()!.username!)
            query.addAscendingOrder("index")
            query.limit = page
            query.findObjectsInBackground(block: { (objects, error) in
                if error == nil {
                    self.uuidArray.removeAll(keepingCapacity: false)
                    self.picArray.removeAll(keepingCapacity: false)
                    self.mediaTypeArray.removeAll(keepingCapacity: false)
                    self.timeArray.removeAll(keepingCapacity: false)
                    for object in objects! {
                        self.mediaTypeArray.append(object.value(forKey: "mediatype") as! String)
                        self.uuidArray.append(object.value(forKey: "uuid") as! String)
                        self.picArray.append(object.value(forKey: "media") as! PFFile)
                        self.timeArray.append(object.createdAt)
                    }
                    print("more loaded")
                    self.collectionView?.reloadData()
                } else {
                    self.parseErrorAlert()
                    print(error!.localizedDescription)
                }
            })
        }
    }

    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return picArray.count
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemIndexPath indexPath: IndexPath) -> CGSize {
        let size = CGSize(width: self.view.frame.size.width / 3 , height: self.view.frame.size.width / 3)
        return size
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as! pictureCell
        let type = mediaTypeArray[indexPath.row]
        let uuid = uuidArray[indexPath.row]
        if type == "photo" {
            cell.type.isHidden = true
            cell.videoView.isHidden = true
            picArray[indexPath.row].getDataInBackground { (data, error) -> Void in
                if error == nil {
                    cell.pictureImage.image = UIImage(data: data!)
                } else {
                    self.parseErrorAlert()
                    print(error!.localizedDescription)
                }
            }
        } else if type == "video" {
            cell.videoView.isHidden = false
            cell.type.isHidden = false
            var videoUrl: String!
            var videoFile: PFFile
            let videoURL = picArray[indexPath.row].url
            func setupVideoPlayerWithURL(url:NSURL) {
                player = AVPlayer(url: url as URL)
                playerLayer = AVPlayerLayer(player: self.player)
                playerLayer.videoGravity = AVLayerVideoGravity.resizeAspectFill
                playerLayer.frame = cell.videoView.frame
                cell.videoView.layer.addSublayer(self.playerLayer)
            }
            setupVideoPlayerWithURL(url: NSURL(string: videoURL!)!)
            let from = timeArray[indexPath.row]
            let now = Date()
            let components : NSCalendar.Unit = [.second, .minute, .hour, .day, .weekOfMonth]
            let difference = (Calendar.current as NSCalendar).components(components, from: from!, to: now, options: [])
            if difference.second! <= 0 {
                let timeQuery = PFQuery(className: "posts")
                timeQuery.whereKey("uuid", equalTo: uuidArray[indexPath.row])
                timeQuery.whereKey("username", equalTo: PFUser.current()!.username!)
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
                self.time = "now"
            }
            if difference.second! > 0 && difference.minute! == 0 {
                self.time = "\(difference.second!)s"
            }
            if difference.minute! > 0 && difference.hour! == 0 {
                self.time = "\(difference.minute!)m"
            }
            if difference.hour! > 0 && difference.day! == 0 {
                self.time = "\(difference.hour!)h"
            }
            if difference.day! > 0 && difference.weekOfMonth! == 0 {
                let timeQuery = PFQuery(className: "posts")
                timeQuery.whereKey("uuid", equalTo: uuidArray[indexPath.row])
                timeQuery.whereKey("username", equalTo: PFUser.current()!.username!)
                timeQuery.findObjectsInBackground(block: { (objects, error) in
                    if error == nil {
                        for object in objects! {
                            let thePin = object["pinned"] as! Bool
                            if thePin == true {
                                cell.isHidden = false
                                object["time"] = "over"
                                object.saveEventually()
                            } else {
                                cell.isHidden = true
                                object.deleteInBackground(block: { (success, error) in
                                    if error == nil {
                                        let likeQuery = PFQuery(className: "likes")
                                        likeQuery.whereKey("to", equalTo: self.uuidArray[indexPath.row])
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
                                        commentQuery.whereKey("to", equalTo: self.uuidArray[indexPath.row])
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
                                        hashtagQuery.whereKey("to", equalTo: self.uuidArray[indexPath.row])
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
                                        notificationQuery.whereKey("uuid", equalTo: self.uuidArray[indexPath.row])
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
                self.time = "\(difference.day!)d"
            }
            if difference.weekOfMonth! > 0 {
                self.time = "\(difference.weekOfMonth!)w"
                let timeQuery = PFQuery(className: "posts")
                timeQuery.whereKey("uuid", equalTo: uuidArray[indexPath.row])
                timeQuery.whereKey("username", equalTo: PFUser.current()!.username!)
                timeQuery.findObjectsInBackground(block: { (objects, error) in
                    if error == nil {
                        for object in objects! {
                            let thePin = object["pinned"] as! Bool
                            if thePin == true {
                                cell.isHidden = false
                                object["time"] = "over"
                                object.saveEventually()
                            } else {
                                cell.isHidden = true
                                object.deleteInBackground(block: { (success, error) in
                                    if error == nil {
                                        let likeQuery = PFQuery(className: "likes")
                                        likeQuery.whereKey("to", equalTo: self.uuidArray[indexPath.row])
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
                                        commentQuery.whereKey("to", equalTo: self.uuidArray[indexPath.row])
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
                                        hashtagQuery.whereKey("to", equalTo: self.uuidArray[indexPath.row])
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
                                        notificationQuery.whereKey("uuid", equalTo: self.uuidArray[indexPath.row])
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
        }
        let postQuery = PFQuery(className: "posts")
        postQuery.whereKey("uuid", equalTo: uuid )
        postQuery.findObjectsInBackground { (objects, error) in
            if error == nil {
                for object in objects! {
                    let pin = object["pinned"] as! Bool
                    let time = object["time"] as! String
                    if pin == false && time == "over" {
                        object.deleteEventually()
                    }
                }
            }
        }
        return cell
    }
    
  
    override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let header = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionElementKindSectionHeader, withReuseIdentifier: "Header", for: indexPath) as! HeaderView
        
        let query = PFQuery(className: "_User")
        query.whereKey("username", equalTo: PFUser.current()!.username!)
        query.findObjectsInBackground { (objects, error) in
            if error == nil {
                for object in objects! {
                    header.name.text = object.object(forKey: "fullname") as? String
                    header.username.text = "@" + (object.object(forKey: "username") as? String)!
                    
                    header.bio.text = object.object(forKey: "bio") as? String
                    //print(object.object(forKey: "bio") as! String)
                    self.myFullName = header.name.text!
                    self.myUsername = header.username.text!
                    
                    
                }
            } else {
                self.parseErrorAlert()
                print(error!.localizedDescription)
            }
        }
       
        //header.name.text = PFUser.current()!.object(forKey: "fullname") as? String
        //header.username.text = "@\(String(describing: PFUser.current()!.object(forKey: "username") as!String))"
        //header.bio.text = PFUser.current()!.object(forKey: "bio") as? String
        //print(header.bio.text)
        //header.bio.sizeToFit()
        //header.profileButton.setTitle("Edit Profile", for: UIControlState.normal)
        let profilePicQuery = PFUser.current()!.object(forKey: "profilepic") as! PFFile
        profilePicQuery.getDataInBackground { (data, error) in
            header.profilePic.image = UIImage(data: data!)
            self.myImage = header.profilePic.image
        }
        let posts = PFQuery(className: "posts")
        posts.whereKey("username", equalTo: PFUser.current()!.username!)
        posts.countObjectsInBackground { (count, error) in
            if error == nil {
                header.posts.text = "\(count)"
            }
            else {
                self.parseErrorAlert()
                print(error?.localizedDescription as Any)
            }
        }
        let followers = PFQuery(className: "follow")
        followers.whereKey("following", equalTo: PFUser.current()!.username!)
        followers.countObjectsInBackground { (count, error) in
            if error == nil {
                header.followers.text = "\(count)"
            }
            else {
                self.parseErrorAlert()
                print(error?.localizedDescription as Any)
            }
        }
        let following = PFQuery(className: "follow")
        following.whereKey("follower", equalTo: PFUser.current()!.username!)
        following.countObjectsInBackground { (count, error) in
            if error == nil {
                header.following.text = "\(count)"
            }
            else {
                self.parseErrorAlert()
                print(error?.localizedDescription as Any)
            }
        }
        let postTap = UITapGestureRecognizer(target: self, action: #selector(HomePageVC.postTap))
        postTap.numberOfTapsRequired = 1
        header.posts.isUserInteractionEnabled = true
        header.posts.addGestureRecognizer(postTap)
    
        let followersTap = UITapGestureRecognizer(target: self, action: #selector(HomePageVC.followersTap))
        followersTap.numberOfTapsRequired = 1
        header.followers.isUserInteractionEnabled = true
        header.followers.addGestureRecognizer(followersTap)
    
        let followingTap = UITapGestureRecognizer(target: self, action: #selector(HomePageVC.followingTap))
        followingTap.numberOfTapsRequired = 1
        header.following.isUserInteractionEnabled = true
        header.following.addGestureRecognizer(followingTap)
        header.sizeToFit()
        return header
    }
    
    @objc func postTap() {
        if !picArray.isEmpty {
            let index = IndexPath(item: 0, section: 0)
            self.collectionView?.scrollToItem(at: index, at: UICollectionViewScrollPosition.top, animated: true)
        }
    }

    @objc func followersTap() {
        user = PFUser.current()!.username!
        category = "Followers"
        let followers = self.storyboard?.instantiateViewController(withIdentifier: "FollowersVC") as! FollowersVC
        self.navigationController?.pushViewController(followers, animated: true)
    }

    @objc func followingTap() {
        user = PFUser.current()!.username!
        category = "Following"
        let following = self.storyboard?.instantiateViewController(withIdentifier: "FollowersVC") as! FollowersVC
        self.navigationController?.pushViewController(following, animated: true)
    }

    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        postUUID = uuidArray
        postAtIndex = indexPath.row
        globalTypeArray = mediaTypeArray
        let post = navigationController?.storyboard?.instantiateViewController(withIdentifier: "Post") as! Post
        navigationController?.pushViewController(post, animated: true)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "fromHome" {
            let destinationViewController = segue.destination as? Post
            let value = false
            destinationViewController?.fromWhere = value
         }
        
        
        
    }

    @IBAction func logout(_ sender: AnyObject) {
        let settings = self.storyboard?.instantiateViewController(withIdentifier: "SettingsVC") as! SettingsVC
        settings.username = myUsername
        settings.fullName = myFullName
        settings.profilePic = myImage
        self.navigationController?.pushViewController(settings, animated: true)
        }
 }

