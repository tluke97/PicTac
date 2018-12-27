//
//  FriendProfileVC.swift
//  CorkBoard
//
//  Created by Tanner Luke on 10/19/17.
//  Copyright © 2017 CorkBoard Co. All rights reserved.
//

import UIKit
import Parse
import AVFoundation

var friendName = [String]()

class FriendProfileVC: UICollectionViewController {
    
    var refresher: UIRefreshControl!
    var page: Int = 10
    var locked: String!
    var canLoadPosts: Bool!
    var mediaTypeArray = [String]()
    var uuidArray = [String]()
    var picArray = [PFFile]()
    var timeArray = [Date?]()
    let background = UIImageView()
    var time: String!
    let grayColor = UIColor(displayP3Red: 239/255, green: 239/255, blue: 241/255, alpha: 1)
    var followerArray = [String]()
    var player = AVPlayer()
    var playerLayer: AVPlayerLayer!
    var bioHeight: String!
    var height: CGFloat = 0
    
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        networkNotification()
        self.collectionView?.alwaysBounceVertical = true
        refresher = UIRefreshControl()
        refresher.addTarget(self, action: #selector(HomePageVC.refresh), for: UIControlEvents.valueChanged)
        collectionView?.addSubview(refresher)
        NotificationCenter.default.addObserver(self, selector: #selector(HomePageVC.reload(_:)), name: NSNotification.Name(rawValue: "reload"), object: nil)
        self.navigationItem.title = friendName.last
        self.navigationItem.hidesBackButton = true
        let image = UIImage(named: "BackButton.png")
        let backButton = UIBarButtonItem(image: image!, style: UIBarButtonItemStyle.plain, target: self, action: #selector(FriendProfileVC.back(_:)))
        self.navigationItem.leftBarButtonItem = backButton
        let backSwipe = UISwipeGestureRecognizer(target: self, action: #selector(FriendProfileVC.back(_:)))
        backSwipe.direction = UISwipeGestureRecognizerDirection.right
        self.view.addGestureRecognizer(backSwipe)
        canLoadThePosts()
        getBio()
        /*
        let width = UIScreen.main.bounds.width
        
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        let bioQuery = PFQuery(className: "_User")
        bioQuery.whereKey("username", equalTo: friendName.last!)
        bioQuery.findObjectsInBackground { (objects, error) in
            if error == nil {
                for object in objects! {
                    self.bioHeight = object.object(forKey: "bio") as! String
                    if self.bioHeight == "" {
                        layout.headerReferenceSize = CGSize(width: 360, height: 250)
                    } else {
                        layout.headerReferenceSize = CGSize(width: 360, height: 290)
                    }
                }
            }
        }
        layout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 10, right: 0)
        layout.itemSize = CGSize(width: (width/4)-1, height: (width/4))
        layout.minimumInteritemSpacing = 0.5
        layout.minimumLineSpacing = 0.5
        collectionView!.collectionViewLayout = layout
 */
        self.tabBarController?.tabBar.isHidden = false
        self.navigationController?.navigationBar.isHidden = false
        loadThePosts()
    }
    
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        self.navigationController?.navigationBar.isHidden = false
        self.tabBarController?.tabBar.isHidden = false
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

    @objc func refresh() {
        collectionView?.reloadData()
        refresher.endRefreshing()
    }
    
    @objc func reload(_ notification:Notification) {
        collectionView?.reloadData()
    }
    
    @objc func back(_ sender: UIBarButtonItem) {
        _ = self.navigationController?.popViewController(animated: true)
        if !friendName.isEmpty {
            friendName.removeLast()
        }
    }
    
    func getBio() {
        
        let query = PFQuery(className: "_User")
        query.whereKey("username", equalTo: friendName.last!)
        query.findObjectsInBackground { (objects, error) in
            if error == nil {
                for object in objects! {
                    self.bioHeight = object.object(forKey: "bio") as? String
                    //print(self.bioHeight)
                    let checkTextHeight = UITextView(frame: CGRect(x: 20, y: 100, width: self.view.frame.size.width - 40, height: 20))
                    checkTextHeight.font = UIFont(name: "Helvetica Neue", size: 15)
                    checkTextHeight.textAlignment = .center
                    checkTextHeight.textContainerInset = UIEdgeInsets(top: 5, left: 0, bottom: 5, right: 0)
                    checkTextHeight.textColor = .clear
                    checkTextHeight.backgroundColor = .clear
                    checkTextHeight.isHidden = true
                    checkTextHeight.isUserInteractionEnabled = false
                    self.view.addSubview(checkTextHeight)
                    checkTextHeight.text = self.bioHeight
                    //checkTextHeight.sizeToFit()
                    
                    self.height = checkTextHeight.contentSize.height
                    print(self.height)
                    
                    let width = UIScreen.main.bounds.width
                    let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
                    
                    if self.bioHeight == "" || self.bioHeight ==  " " || self.bioHeight == "  " {
                        print("this")
                        layout.headerReferenceSize = CGSize(width: 360, height: 218)
                    } else {
                        
                        print("hello")
                        
                        //print(bioHeight)
                        //print(getHeight)
                        layout.headerReferenceSize = CGSize(width: 360, height: 218 + self.height)
                    }
                    layout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 10, right: 0)
                    layout.itemSize = CGSize(width: (width/4)-1, height: (width/4))
                    layout.minimumInteritemSpacing = 0.5
                    layout.minimumLineSpacing = 0.5
                    self.collectionView!.collectionViewLayout = layout
                    
                }
                
            } else {
                
                print(error!.localizedDescription)
            }
        }
        
        
    }
    
    
    func canLoadThePosts() {
        let lockQuery = PFQuery(className: "_User")
        lockQuery.whereKey("username", equalTo: friendName.last!)
        lockQuery.findObjectsInBackground { (objects, error) in
            if error == nil {
                for object in objects! {
                    self.locked = object.object(forKey: "locked") as? String
                    if self.locked == "yes" {
                        let findFollower = PFQuery(className: "follow")
                        findFollower.whereKey("following", equalTo: friendName.last!)
                        findFollower.whereKey("follower", equalTo: PFUser.current()!.username!)
                        findFollower.countObjectsInBackground(block: { (count, error) in
                            if error == nil {
                                if count != 0 {
                                    self.canLoadPosts = true
                                } else {
                                    self.background.image = UIImage(named: "lock.png")
                                    self.collectionView?.backgroundView = self.background
                                    self.canLoadPosts = false
                                }
                            } else {
                                
                            }
                        })
                    } else {
                        self.canLoadPosts = true
                    }
                }
            } else {
                
            }
        }
    }
    
    func loadPosts() {
        let query = PFQuery(className: "posts")
        query.whereKey("username", equalTo: friendName.last!)
        query.addAscendingOrder("index")
        query.limit = page
        query.findObjectsInBackground { (objects, error) in
            if error == nil {
                self.mediaTypeArray.removeAll(keepingCapacity: false)
                self.uuidArray.removeAll(keepingCapacity: false)
                self.picArray.removeAll(keepingCapacity: false)
                self.timeArray.removeAll(keepingCapacity: false)
                for object in objects! {
                    self.mediaTypeArray.append(object.value(forKey: "mediatype") as! String)
                    self.uuidArray.append(object.value(forKey: "uuid") as! String)
                    self.picArray.append(object.value(forKey: "media") as! PFFile)
                    self.timeArray.append(object.createdAt)
                }
                self.collectionView?.reloadData()
            } else {
               
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
            query.whereKey("username", equalTo: friendName.last!)
            query.addAscendingOrder("index")
            query.limit = page
            query.findObjectsInBackground(block: { (objects, error) in
                if error == nil {
                    self.mediaTypeArray.removeAll(keepingCapacity: false)
                    self.uuidArray.removeAll(keepingCapacity: false)
                    self.picArray.removeAll(keepingCapacity: false)
                    self.timeArray.removeAll(keepingCapacity: false)
                    for object in objects! {
                        self.mediaTypeArray.append(object.value(forKey: "mediatype") as! String)
                        self.uuidArray.append(object.value(forKey: "uuid") as! String)
                        self.picArray.append(object.value(forKey: "media") as! PFFile)
                        self.timeArray.append(object.createdAt)
                    }
                    self.collectionView?.reloadData()
                } else {
                    
                    print(error!.localizedDescription)
                }
            })
        }
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
      return picArray.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as! pictureCell
        let type = mediaTypeArray[indexPath.row]
        let uuid = uuidArray[indexPath.row]
        if type == "photo" {
            cell.videoView.isHidden = true
            picArray[indexPath.row].getDataInBackground { (data, error) -> Void in
                if error == nil {
                    cell.pictureImage.image = UIImage(data: data!)
                } else {
                   
                    print(error!.localizedDescription)
                }}
            } else if type == "video" {
            cell.videoView.isHidden = false
            var videoUrl: String!
            var videoFile: PFFile
            let videoURL = picArray[indexPath.row].url
            func setupVideoPlayerWithURL(url:NSURL) {
                player = AVPlayer(url: url as URL)
                playerLayer = AVPlayerLayer(player: self.player)
                playerLayer.videoGravity = AVLayerVideoGravity.resizeAspectFill
                playerLayer.frame = cell.videoView.frame   // take up entire screen
                cell.videoView.layer.addSublayer(self.playerLayer)
            }
            setupVideoPlayerWithURL(url: NSURL(string: videoURL!)!)
        }
        let lockPosts = PFQuery(className: "_User")
        lockPosts.whereKey("username", equalTo: friendName.last!)
        lockPosts.findObjectsInBackground { (objects, error) in
            if error == nil {
                for object in objects! {
                    self.locked = object.object(forKey: "locked") as? String
                    if self.locked == "yes" {
                        let findFollower = PFQuery(className: "follow")
                        findFollower.whereKey("following", equalTo: friendName.last!)
                        findFollower.findObjectsInBackground(block: { (objects, error) in
                            if error == nil {
                                self.followerArray.removeAll(keepingCapacity: false)
                                for object in objects! {
                                    self.followerArray.append(object.object(forKey: "follower") as! String)
                                    if self.followerArray.contains((PFUser.current()?.username!)!) {
                                        cell.isHidden = false
                                    } else {
                                        cell.isHidden = true
                                    }
                                }
                            }
                        })
                    } else {
                        cell.isHidden = false
                    }
                }
            } else {
                print(error!.localizedDescription)
               
            }
        }
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
                                    
                                    print(error!.localizedDescription)
                                }
                            })
                        }
                    }
                } else {
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
                              
                                    print(error!.localizedDescription)
                                }
                            })
                        }
                    }
                } else {
                    
                    print(error!.localizedDescription)
                }
            })
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
            } else {
                print(error!.localizedDescription)
                
            }
        }
        return cell
    }
   
    override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let header = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionElementKindSectionHeader, withReuseIdentifier: "Header", for: indexPath) as! HeaderView
        let infoQuery = PFQuery(className: "_User")
        
        infoQuery.whereKey("username", equalTo: friendName.last!)
        infoQuery.findObjectsInBackground { (objects, error) in
            if error == nil{
                if objects!.isEmpty {
                    let alert = UIAlertController(title: "Profile Does Not Exist", message: "User \(friendName.last!) does not exist.", preferredStyle: .alert)
                    let ok = UIAlertAction(title: "Okay", style: UIAlertActionStyle.default, handler: { (UIAlertAction) in
                        self.navigationController?.popViewController(animated: true)
                    })
                    alert.addAction(ok)
                    self.present(alert, animated: true, completion: nil)
                }
                for object in objects! {
                    self.locked = (object.object(forKey: "locked") as? String)
                    header.username.text = "@\(String(describing: object.object(forKey: "username") as!String))"
                    header.name.text = (object.object(forKey: "fullname") as? String)
                    header.bio.text = (object.object(forKey: "bio") as? String)
                    //header.bio.sizeToFit()
                    let profilePicFile: PFFile = (object.object(forKey: "profilepic") as? PFFile)!
                    profilePicFile.getDataInBackground(block: { (data, error) in
                        header.profilePic.image = UIImage(data: data!)
                    })
                }
            } else {
                
                print(error!.localizedDescription)
            }
        }
        let followQuery = PFQuery(className: "follow")
        followQuery.whereKey("follower", equalTo: PFUser.current()!.username!)
        followQuery.whereKey("following", equalTo: friendName.last!)
        followQuery.countObjectsInBackground { (count, error) in
            if error == nil {
                if count == 0 {
                    let requestQuery = PFQuery(className: "request")
                    requestQuery.whereKey("follower", equalTo: PFUser.current()!.username!)
                    requestQuery.whereKey("following", equalTo: friendName.last!)
                    requestQuery.countObjectsInBackground(block: { (count, error) in
                        if error == nil {
                            if count == 0 {
                                header.profileButton.setTitle("Follow", for: UIControlState())
                                header.profileButton.backgroundColor = .white
                                header.profileButton.setTitleColor(UIColor(displayP3Red: 75/255, green: 239/255, blue: 211/255, alpha: 1), for: .normal)
                                header.profileButton.layer.borderWidth = 1
                                header.profileButton.layer.borderColor = UIColor(displayP3Red: 75/255, green: 239/255, blue: 211/255, alpha: 1).cgColor
                            } else {
                                header.profileButton.setTitle("Requested", for: UIControlState.normal)
                                header.profileButton.backgroundColor = self.grayColor
                                header.profileButton.layer.borderWidth = 0
                                header.profileButton.setTitleColor(UIColor(displayP3Red: 75/255, green: 239/255, blue: 211/255, alpha: 1), for: .normal)
                            }
                        } else {
                            print(error!.localizedDescription)
                            
                        }
                    })
                } else {
                    header.profileButton.setTitle("Following", for: UIControlState())
                    header.profileButton.backgroundColor = UIColor(displayP3Red: 75/255, green: 239/255, blue: 211/255, alpha: 1)
                    header.profileButton.setTitleColor(.white, for: UIControlState())
                }
            } else {
              
                print(error!.localizedDescription)
            }
            
            let postsQuery = PFQuery(className: "posts")
            guard let name = friendName.last else {return}
            postsQuery.whereKey("username", equalTo: name)
            postsQuery.countObjectsInBackground(block: { (count, error) in
                if error == nil {
                    header.posts.text = "\(count)"
                } else {
                   
                    print(error!.localizedDescription)
                }
            })
 
            let followersQuery = PFQuery(className: "follow")
            
            followersQuery.whereKey("following", equalTo: name)
            followersQuery.countObjectsInBackground(block: { (count, error) in
                if error == nil {
                    header.followers.text = "\(count)"
                } else {
                    
                    print(error!.localizedDescription)
                }
            })
            
            let followingQuery = PFQuery(className: "follow")
            followingQuery.whereKey("follower", equalTo: name)
            followingQuery.countObjectsInBackground(block: { (count, error) in
                if error == nil {
                    header.following.text = "\(count)"
                } else {
             
                    print(error!.localizedDescription)
                }
            })
            let postTap = UITapGestureRecognizer(target: self, action: #selector(FriendProfileVC.postTap))
            postTap.numberOfTapsRequired = 1
            header.postsTitle.isUserInteractionEnabled = true
            header.postsTitle.addGestureRecognizer(postTap)
            let followersTap = UITapGestureRecognizer(target: self, action: #selector(FriendProfileVC.followersTap))
            followersTap.numberOfTapsRequired = 1
            header.followers.isUserInteractionEnabled = true
            header.followers.addGestureRecognizer(followersTap)
            let followingTap = UITapGestureRecognizer(target: self, action: #selector(FriendProfileVC.followingTap))
            followingTap.numberOfTapsRequired = 1
            header.following.isUserInteractionEnabled = true
            header.following.addGestureRecognizer(followingTap)
        }
        return header
    }
    
    @objc func postTap() {
        if !picArray.isEmpty {
            let index = IndexPath(item: 0, section: 0)
            self.collectionView?.scrollToItem(at: index, at: UICollectionViewScrollPosition.top, animated: true)
        }
    }
    
    @objc func followersTap() {
        user = friendName.last!
        category = "Followers"
        let followers = self.storyboard?.instantiateViewController(withIdentifier: "FollowersVC") as! FollowersVC
        self.navigationController?.pushViewController(followers, animated: true)
    }
    
    @objc func followingTap() {
        user = friendName.last!
        category = "Following"
        let followers = self.storyboard?.instantiateViewController(withIdentifier: "FollowersVC") as! FollowersVC
        self.navigationController?.pushViewController(followers, animated: true)
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        postUUID = uuidArray
        postAtIndex = indexPath.row
        globalTypeArray = mediaTypeArray
        let post = self.storyboard?.instantiateViewController(withIdentifier: "Post") as! Post
        self.navigationController?.pushViewController(post, animated: true)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "fromFriend" {
            let destinationViewController = segue.destination as? Post
            let value = false
            destinationViewController?.fromWhere = value
        }
    }

    func loadThePosts() {
        let lockPosts = PFQuery(className: "_User")
        lockPosts.whereKey("username", equalTo: friendName.last!)
        lockPosts.findObjectsInBackground { (objects, error) in
            if error == nil {
                for object in objects! {
                    self.locked = object.object(forKey: "locked") as? String
                    if self.locked == "yes" {
                        let findFollower = PFQuery(className: "follow")
                        findFollower.whereKey("following", equalTo: friendName.last!)
                        findFollower.findObjectsInBackground(block: { (objects, error) in
                            if error == nil {
                                self.followerArray.removeAll(keepingCapacity: false)
                                for object in objects! {
                                    self.followerArray.append(object.object(forKey: "follower") as! String)
                                    if self.followerArray.contains((PFUser.current()?.username!)!) {
                                        self.loadPosts()
                                    }
                                }
                            } else {
                                
                                print(error!.localizedDescription)
                            }
                        })
                    } else {
                        self.loadPosts()
                    }
                }
            } else {
                print(error!.localizedDescription)
                
            }
        }
    }
}
