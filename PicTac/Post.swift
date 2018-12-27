//
//  Post.swift
//  CorkBoard
//
//  Created by Tanner Luke on 2/2/18.
//  Copyright © 2018 CorkBoard Co. All rights reserved.
//

import UIKit
import Parse
import AVFoundation
//import KILabel



class Post: UIViewController, UIScrollViewDelegate, UIGestureRecognizerDelegate {
    
    private var playerItemContext = 0
    
    @IBOutlet weak var buttonview: UIView!
    
    @IBOutlet weak var videoOverlay: UIImageView!
    
    @IBOutlet weak var foreignUserButtonView: UIView!
    
    @IBOutlet weak var followerStack: UIStackView!
    @IBOutlet weak var userStack: UIStackView!
    
    @IBOutlet weak var backImage: UIImageView!
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var username: UIButton!
    @IBOutlet weak var time: UILabel!
    @IBOutlet weak var uuid: UILabel!
    @IBOutlet weak var likeButton: UIButton!
    @IBOutlet weak var likeCount: UIButton!
    @IBOutlet weak var commentButton: UIButton!
    @IBOutlet weak var pinButton: UIButton!
    @IBOutlet weak var moreButton: UIButton!
    @IBOutlet weak var picPost: UIImageView!
    @IBOutlet weak var videoView: UIView!
    
    
    
    @IBOutlet weak var followerLikeButton: UIButton!
    @IBOutlet weak var followerLikeCount: UIButton!
    
    var nextItemIsVideo = false
    var previousItemIsVideo = false
    
    var playbackLikelyToKeepUpKeyPathObserver: NSKeyValueObservation?
    var playbackBufferEmptyObserver: NSKeyValueObservation?
    var playbackBufferFullObserver: NSKeyValueObservation?
    
    var removeObservers: Bool = false
    
    var timeObserver: String?
    
    let generator = UIImpactFeedbackGenerator(style: .medium)
    
    
    
    let loadingIndicator = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.whiteLarge)
    
    
    @IBOutlet weak var scrollView: UIScrollView!{
        didSet{
            scrollView.delegate = self
            scrollView.minimumZoomScale = 1.0
            scrollView.maximumZoomScale = 3.0
                    }
    }
    @IBOutlet weak var comment: UILabel!
    
    let swipeUp = UISwipeGestureRecognizer()
    let swipeDown = UISwipeGestureRecognizer()
    
    var postProfilePic: PFFile!
    var postUsername: String!
    var postPicture: PFFile!
    var postDate: Date?
    var postUuid: String!
    var postTitle: String!
    var postMediaType: String!
    var photoOverlayForVideo: PFFile!
    var postOverUnder: String!
    
    var player = AVPlayer()
    var playerLayer: AVPlayerLayer!
    
    var sendNotification: Bool!
    var fromWhere: Bool!

    @objc var playerItem: AVPlayerItem?
    
    var doNotShowDot: Bool!
    
 
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        networkNotification()
       /* do {
            try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback, with: AVAudioSessionCategoryOptions.mixWithOthers)
            try AVAudioSession.setActive(true)
            
        } catch {
            print(error)
        }
*/
        likeButton.setTitleColor(.clear, for: .normal)
        
        if dot.isHidden == true {
            
           doNotShowDot = true
            
        } else {
            
            doNotShowDot = false
            dot.isHidden = true
        }
        
        
        
     
       // NotificationCenter.default.addObserver(self, selector: #selector(ThePostVC.refresh), name: NSNotification.Name(rawValue: "liked"), object: nil)
        
       // NotificationCenter.default.addObserver(self, selector: #selector(ThePostVC.back(_:)), name: NSNotification.Name(rawValue: "back"), object: nil)
        
        /*
        NotificationCenter.default.addObserver(
            forName: .UIApplicationUserDidTakeScreenshot,
            object: nil,
            queue: .main) { notification in
                print("screenshot notification dispatched")
                self.screenshotNotification()
                
                
        }
    */
        
        NotificationCenter.default.addObserver(self, selector: #selector(screenshotNotification), name: NSNotification.Name.UIApplicationUserDidTakeScreenshot, object: nil)
        
        
        
        
        player.automaticallyWaitsToMinimizeStalling = false
        
        loadingIndicator.center = self.view.center
        
        comment.sizeToFit()
       
        sendNotification = fromWhere
        
        player.currentItem?.addObserver(self, forKeyPath: "duration", options: [.new, .initial], context: nil)
        
        addTimeObserver()
        
        
        generator.prepare()
        
        
        buttonview.backgroundColor = UIColor(displayP3Red: 0, green: 0, blue: 0, alpha: 0.35)
        comment.backgroundColor = UIColor(displayP3Red: 0, green: 0, blue: 0, alpha: 0.35)
        loadPost()
        
        let downExitSwipe = UISwipeGestureRecognizer(target: self, action: #selector(Post.back(_:)))
        downExitSwipe.direction = UISwipeGestureRecognizerDirection.right
        self.scrollView.addGestureRecognizer(downExitSwipe)
        // self.view.addGestureRecognizer(downExitSwipe)
        
        backImage.frame = CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: self.view.frame.size.height)
        
       //swipeUp = UISwipeGestureRecognizer(target: self, action: #selector(Post.changePost(swipeUp: true)))
        swipeUp.addTarget(self, action: #selector(Post.changePost(_:)))
        swipeUp.direction = .up
        self.view.addGestureRecognizer(swipeUp)
        
        swipeDown.addTarget(self, action: #selector(Post.changePost(_:)))
        swipeDown.direction = .down
        self.view.addGestureRecognizer(swipeDown)
        
        
        let tapToHide = UITapGestureRecognizer(target: self, action: #selector(hide(_:)))
        tapToHide.numberOfTapsRequired = 1
        self.view.isUserInteractionEnabled = true
        self.scrollView.addGestureRecognizer(tapToHide)
        
        
        scrollView.delegate = self
        
        
        
        
        picPost.frame = CGRect(x: 0, y: 0, width: scrollView.frame.size.width, height: scrollView.frame.size.height)
        picPost.clipsToBounds = true
        
        picPost.isUserInteractionEnabled = true
        
        scrollView.addSubview(picPost)
        
        
        // picPost.contentMode = .center
        picPost.contentMode = .scaleAspectFill
        picPost.frame = CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: self.view.frame.size.height)
        
        
        followerLikeButton.setTitleColor(.clear, for: .normal) 
        
        
        comment.sizeToFit()
        
        
        userStack.isHidden = true
        followerStack.isHidden = true
        
        loadingIndicator.startAnimating()
        loadingIndicator.hidesWhenStopped = true
        videoOverlay.addSubview(loadingIndicator)
        //player.addObserver(self, forKeyPath: "currentItem.playbackLikelyToKeepUp", options: .New, context: .isPlaybackLikelyToKeepUp)
       
        
        
        
        
        // let tapGesture = UIPanGestureRecognizer(target: self, action: #selector(self.exit(sender:)))
        // self.view.addGestureRecognizer(tapGesture)
        
        self.tabBarController?.tabBar.isHidden = true
        self.navigationController?.navigationBar.isHidden = true
        
        
        
  
        
        
        
        
    }
    
    


    
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.player.play()
        self.tabBarController?.tabBar.isHidden = true
        self.navigationController?.navigationBar.isHidden = true
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        
        super.viewWillDisappear(animated)
        dot.isHidden = doNotShowDot
        self.player.pause()
        
        if self.removeObservers == true {
        
            self.player.removeObserver(self, forKeyPath:  #keyPath(AVPlayerItem.status), context: &self.playerItemContext)
            self.player.removeObserver(self, forKeyPath: "currentItem.loadedTimeRanges", context: nil)
        
        }
        self.playerItem = nil
        self.tabBarController?.tabBar.isHidden = false
        self.navigationController?.navigationBar.isHidden = false
       
    }
    
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(true)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIApplicationUserDidTakeScreenshot, object: nil)
    }
    
    override var prefersStatusBarHidden : Bool {
        return true
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    
    func checkForCommentSegue() {
        
        if goToComment == true {
            
            commentuuid.append(self.uuid.text!)
            commentowner.append(self.username.titleLabel!.text!)
            
            
            let comment = self.storyboard?.instantiateViewController(withIdentifier: "CommentViewController") as! CommentViewController
            
            self.navigationController?.pushViewController(comment, animated: true)
            
        }
        
        goToComment = false
        
    }
        
        
        //if keyPath == "duration", let duration = player.currentItem?.duration.seconds, duration > 0.0 {
            //self.loadingIndicatorView.stopAnimating()
        //}
    
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
    
  
    
    @objc func screenshotNotification() {
        
        let notificationQuery = PFQuery(className: "notification")
        notificationQuery.whereKey("uuid", equalTo: self.uuid.text!)
        notificationQuery.whereKey("by", equalTo: PFUser.current()!.username!)
        notificationQuery.whereKey("type", equalTo: "screenshot")
        notificationQuery.countObjectsInBackground { (count, error) in
            if error == nil {
                
                if count == 0 {
                    
                    if PFUser.current()?.username != self.username.titleLabel!.text! {
                        
                        print("taken")
                        
                        
                        let notificationObject = PFObject(className: "notification")
                        notificationObject["by"] = PFUser.current()!.username
                        notificationObject["profilepic"] = PFUser.current()!.object(forKey: "profilepic") as! PFFile
                        notificationObject["to"] = self.username.titleLabel!.text!
                        notificationObject["owner"] = self.username.titleLabel!.text!
                        notificationObject["uuid"] = self.uuid.text!
                        notificationObject["type"] = "screenshot"
                        notificationObject["checked"] = "no"
                        notificationObject.saveInBackground(block: { (success, error) in
                            if error == nil {
                                let push = PushNotifications()
                                guard let name = self.username.titleLabel?.text else {return}
                                push.pushScreenshotNotification(username: name)
                            }
                        })
                        
                        
                    }
                    
                    
                } else {
                    
                    print("already taken")
                    
                    
                }
                
                
            } else {
                self.parseErrorAlert()
                print(error!.localizedDescription)
            }
        }
        
    }
    
    
    
    
    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        if scrollView.zoomScale <= 1 {
            scrollView.zoomScale = 1
            scrollView.bounces = false
        }
        
        print(scrollView.zoomScale)
    }
    
    

    
 
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        
        return picPost
        
    }
    
    
    
    
    func scrollViewDidEndZooming(_ scrollView: UIScrollView, with view: UIView?, atScale scale: CGFloat) {
        
        
        scrollView.setZoomScale(1.0, animated: true)
    }
    
    
   
    
    
    @objc func hide(_ sender: UITapGestureRecognizer) {
        
      //  let touch = sender.location(in: self.view)
      //  if let indexPath = tableView.indexPathForRow(at: touch) {
       //     let cell = self.tableView.cellForRow(at: indexPath) as! ThePostCell
            
            if self.username.isHidden == false {
                
                
                self.time.isHidden = true
                self.username.isHidden = true
                self.likeButton.isHidden = true
                self.likeCount.isHidden = true
                self.comment.isHidden = true
                self.moreButton.isHidden = true
                self.pinButton.isHidden = true
                self.commentButton.isHidden = true
                self.buttonview.isHidden = true
                
                
            } else if self.username.isHidden == true {
                
                
                self.time.isHidden = false
                self.username.isHidden = false
                self.likeButton.isHidden = false
                self.likeCount.isHidden = false
                if self.comment.text == "" {
                    self.comment.isHidden = true
                } else {
                self.comment.isHidden = true
                }
                self.commentButton.isHidden = false
                self.moreButton.isHidden = false
                self.pinButton.isHidden = false
                self.buttonview.isHidden = false
                
                
            }
            
        }
    
    
    
    
  
   
    
    
        
        
        
    func loadPost() {
        
        var getPost = postUUID[postAtIndex]
        
        if postUUID.count > 1 {
            if postAtIndex != (postUUID.count - 1) {
                var nextVid = globalTypeArray[postAtIndex + 1]
                
                if nextVid == "video" {
                    nextItemIsVideo = true
                } else {
                    nextItemIsVideo = false
                }
                
            }
            if postAtIndex != 0 {
                var previousVid = globalTypeArray[postAtIndex - 1]
                
                if previousVid == "video" {
                    previousItemIsVideo = true
                } else {
                    previousItemIsVideo = false
                }
                
            }
        }
        
        
        
        
        let postQuery = PFQuery(className: "posts")
        //postQuery.whereKey("uuid", equalTo: postUUID.last!)
        postQuery.whereKey("uuid", equalTo: getPost)
        postQuery.findObjectsInBackground (block: { (objects, error) -> Void in
            if error == nil {
                for object in objects! {
                    self.postUsername = object.value(forKey: "username") as? String
                    self.postDate = object.createdAt
                    self.postPicture = object.value(forKey: "media") as? PFFile
                    self.postUuid = object.value(forKey: "uuid") as? String
                    self.postTitle = object.value(forKey: "title") as? String
                    self.postMediaType = object.value(forKey: "mediatype") as? String
                    self.photoOverlayForVideo = object.value(forKey: "photoLayer") as? PFFile
                    self.postOverUnder = object.value(forKey: "time") as? String
        
                    if self.postUsername == PFUser.current()?.username {
                        self.userStack.isHidden = false
                        self.followerStack.isHidden = true
                        self.userStack.isUserInteractionEnabled = true
                        self.followerStack.isUserInteractionEnabled = false
                    } else {
                        self.userStack.isHidden = true
                        self.followerStack.isHidden = false
                        self.userStack.isUserInteractionEnabled = false
                        self.followerStack.isUserInteractionEnabled = true
                    }
                    
                    self.username.setTitle(self.postUsername, for: UIControlState.normal)
                    //self.username.sizeToFit()
                    self.uuid.text = self.postUuid
                    self.comment.text = self.postTitle
                    let type = self.postMediaType
                    
                    self.checkForCommentSegue()
        
        if type == "photo" {
            
           
            self.removeObservers = false
            self.videoView.isHidden = true
            self.videoOverlay.isHidden = true
            
            self.postPicture.getDataInBackground { (data, error) -> Void in
                if error == nil {
                    
                    self.picPost.image = UIImage(data: data!)
                    self.backImage.image = UIImage(data: data!)
                    
                } else {
                    print(error!.localizedDescription)
                }}
            
        } else if type == "video" {
            
            self.picPost.isHidden = true
            self.videoView.isHidden = false
            
            var videoUrl: String!
            var videoFile: PFFile
            
            
            let videoURL = self.postPicture.url
            
            
            func setupVideoPlayerWithURL(url: NSURL) {
                
                
                
                //let notStarted = CMTime(seconds: 0.0, preferredTimescale: 1)
                
                //self.player.automaticallyWaitsToMinimizeStalling = false
                self.player = AVPlayer(url: url as URL)
                
                self.player.addObserver(self,
                                        forKeyPath: #keyPath(AVPlayerItem.status),
                                        options: [.old, .new],
                                        context: &self.playerItemContext)
                self.player.addObserver(self, forKeyPath: "currentItem.loadedTimeRanges", options: .new, context: nil)
               self.removeObservers = true
                self.playerLayer = AVPlayerLayer(player: self.player)
                self.playerLayer.videoGravity = AVLayerVideoGravity.resizeAspectFill
                self.playerLayer.frame = self.view.frame   // take up entire screen
                self.videoView.layer.addSublayer(self.playerLayer)
                //self.player.playImmediately(atRate: 1.0)
                
                self.player.play()
                //self.player.play()
              // print(self.player.currentTime())
               
                //self.player.play()
                loopVideo(videoPlayer: self.player)
                //self.loadingIndicator.stopAnimating()
            }
            
            func loopVideo(videoPlayer: AVPlayer) {
                NotificationCenter.default.addObserver(forName: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: nil, queue: nil) { notification in
                    videoPlayer.seek(to: kCMTimeZero)
                    videoPlayer.play()
                }
            }
            
         
            
            
            
            
            setupVideoPlayerWithURL(url: NSURL(string: videoURL!)!)
            
            
            
            self.photoOverlayForVideo.getDataInBackground { (data, error) -> Void in
                if error == nil {
                    
                    self.videoOverlay.image = UIImage(data: data!)
                    
                    
                } else {
                    self.parseErrorAlert()
                    print(error!.localizedDescription)
                }}
            /*
            let time = CMTime(value: 0, timescale: 1)
            repeat {
                
                if time != self.player.currentTime() {
                    self.loadingIndicatorView.stopAnimating()
                }
                
            }while self.player.currentTime() == time
            
            
            */
            
          
            
        }
        
                    
                    
                    
                    
        
        
        
        
                    let from = self.postDate
        let now = Date()
        let components : NSCalendar.Unit = [.second, .minute, .hour, .day, .weekOfMonth]
        let difference = (Calendar.current as NSCalendar).components(components, from: from!, to: now, options: [])
        
        
        
        if difference.second! <= 0 {
            let timeQuery = PFQuery(className: "posts")
            timeQuery.whereKey("uuid", equalTo: self.uuid.text!)
            // timeQuery.whereKey("username", equalTo: PFUser.current()!.username!)
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
            self.time.text = "now"
        }
        if difference.second! > 0 && difference.minute! == 0 {
            self.time.text = "\(difference.second!)s"
        }
        if difference.minute! > 0 && difference.hour! == 0 {
            self.time.text = "\(difference.minute!)m"
        }
        if difference.hour! > 0 && difference.day! == 0 {
            self.time.text = "\(difference.hour!)h"
        }
        if difference.day! > 0 && difference.weekOfMonth! == 0 {
            
            let timeQuery = PFQuery(className: "posts")
            timeQuery.whereKey("uuid", equalTo: self.uuid.text!)
            //  timeQuery.whereKey("username", equalTo: PFUser.current()!.username!)
            timeQuery.findObjectsInBackground(block: { (objects, error) in
                if error == nil {
                    
                    for object in objects! {
                        
                        object["time"] = "over"
                        
                        object.saveEventually()
                    }
                    
                } else {
                    self.parseErrorAlert()
                    print(error!.localizedDescription)
                }
            })
            
            self.time.text = "\(difference.day!)d"
        }
        if difference.weekOfMonth! > 0 {
            self.time.text = "\(difference.weekOfMonth!)w"
        }
        
        if (self.comment.text?.isEmpty)! {
            self.comment.isHidden = true
        }
        /*
        self.comment.userHandleLinkTapHandler = { label, handle, range in
            var mention = handle
           // mention = String(mention.characters.dropFirst())
            mention = String(mention.dropFirst()) //new one
            
            // if tapped on @currentUser go home, else go guest
            if mention == PFUser.current()?.username {
                let home = self.storyboard?.instantiateViewController(withIdentifier: "HomePageVC") as! HomePageVC
                self.navigationController?.pushViewController(home, animated: true)
            } else {
                friendName.append(mention)
                let guest = self.storyboard?.instantiateViewController(withIdentifier: "FriendProfileVC") as! FriendProfileVC
                self.navigationController?.pushViewController(guest, animated: true)
            }
        }
        
        
        
        self.comment.hashtagLinkTapHandler = { label, handle, range in
            var mention = handle
            mention = String(mention.characters.dropFirst())
            hashtag.append(mention)
            
            let theHashtag = self.storyboard?.instantiateViewController(withIdentifier: "HashtagVC") as! HashtagVC
            self.navigationController?.pushViewController(theHashtag, animated: true)
            
        }
        
        
        */
                    
                    if self.postUsername != PFUser.current()?.username {
                        
                        self.pinButton.isHidden = true
                       // self.pinButton.frame.size.width = 0
                       // self.likeCount.frame.size.width = 40
                        
                    } else {
                        
                        self.pinButton.isHidden = false
                        let didPin = PFQuery(className: "posts")
                        didPin.whereKey("uuid", equalTo: self.uuid.text!)
                        didPin.whereKey("pinned", equalTo: true)
                        didPin.whereKey("username", equalTo: PFUser.current()!.username!)
                        didPin.countObjectsInBackground(block: { (count, error) in
                            if error == nil {
                                
                                if count == 0 {
                                    //  self.pin = false
                                    self.pinButton.setTitle("Pin", for: UIControlState.normal)
                                    self.pinButton.setBackgroundImage(UIImage(named: "UnpinButton.png"), for: UIControlState.normal)
                                    
                                } else {
                                    // self.pin = true
                                    self.pinButton.setTitle("Unpin", for: UIControlState.normal)
                                    self.pinButton.setBackgroundImage(UIImage(named: "PinButton.png"), for: UIControlState.normal)
                                }
                                
                            } else {
                                self.parseErrorAlert()
                                print(error!.localizedDescription)
                            }
                        })
            
                    }
                
        
        let didLike = PFQuery(className: "likes")
        didLike.whereKey("by", equalTo: PFUser.current()!.username!)
        didLike.whereKey("to", equalTo: self.uuid.text!)
        didLike.countObjectsInBackground { (count, error) in
            if error == nil {
                if count == 0 {
                    
                    if self.postUsername == PFUser.current()?.username {
                        
                        self.likeButton.setTitle("unlike", for: UIControlState.normal)
                        self.likeButton.setBackgroundImage(UIImage(named: "unlike.png"), for: UIControlState.normal)
                        
                    } else {
                        
                        self.followerLikeButton.setTitle("unlike", for: UIControlState.normal)
                        self.followerLikeButton.setBackgroundImage(UIImage(named: "unlike.png"), for: UIControlState.normal)
                        
                        
                    }
                    
                    
                    
                } else {
                    if self.postUsername == PFUser.current()?.username {
                        
                        
                        self.likeButton.setTitle("like", for: UIControlState.normal)
                        self.likeButton.setBackgroundImage(UIImage(named: "like.png"), for: UIControlState.normal)
                    } else {
                        
                        self.followerLikeButton.setTitle("like", for: UIControlState.normal)
                        self.followerLikeButton.setBackgroundImage(UIImage(named: "like.png"), for: UIControlState.normal)
                        
                        
                    }
                }
            } else {
                print(error!.localizedDescription)
                self.parseErrorAlert()
            }
            
        }
                    
                    
                    
                    
        
        
        let countLikes = PFQuery(className: "likes")
        countLikes.whereKey("to", equalTo: self.uuid.text!)
        countLikes.countObjectsInBackground { (count, error) in
            if error == nil {
                
                if self.postUsername == PFUser.current()?.username {
                
                    if count == 0 {
                        //cell.likeCount.text = "\(count)"
                        self.likeCount.setTitle("\(count)", for: .normal)
                        //cell.likeCount.isHidden = true
                        self.likeCount.setTitleColor(.clear, for: UIControlState.normal)
                        self.likeCount.isEnabled = false
                    
                    } else {
                    
                        self.likeCount.setTitle("\(count)", for: UIControlState.normal)
                    
                        // cell.likeCount.isHidden = false
                        self.likeCount.setTitleColor(.white, for: UIControlState.normal)
                        self.likeCount.isEnabled = true
                    }
                } else {
                    
                    if count == 0 {
                        //cell.likeCount.text = "\(count)"
                        self.followerLikeCount.setTitle("\(count)", for: .normal)
                        //cell.likeCount.isHidden = true
                        self.followerLikeCount.setTitleColor(.clear, for: UIControlState.normal)
                        self.followerLikeCount.isEnabled = false
                        
                    } else {
                        
                        self.followerLikeCount.setTitle("\(count)", for: UIControlState.normal)
                        
                        // cell.likeCount.isHidden = false
                        self.followerLikeCount.setTitleColor(.white, for: UIControlState.normal)
                        self.followerLikeCount.isEnabled = true
                    }
                    
                    
                }
                
            } else {
                self.parseErrorAlert()
                print(error!.localizedDescription)
            }
            
                
                
                
        }
        
        
        
        
        
        self.picPost.frame = CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: self.view.frame.size.height)
        
        
        self.navigationController?.navigationBar.isHidden = true
        self.tabBarController?.tabBar.isHidden = true
        
        //self.username.layer.setValue(indexPath, forKey: "index")
        
        //self.commentButton.layer.setValue(indexPath, forKey: "index")
        
        //self.moreButton.layer.setValue(indexPath, forKey: "index")
        
                }
            }
        })
        
      // self.loadingIndicator.isHidden = true
      //  self.loadingIndicator.stopAnimating()
        
    }
    
    
    @objc func changePost(_ sender: UISwipeGestureRecognizer) {
        
        if self.removeObservers == true {
            
            self.player.removeObserver(self, forKeyPath:  #keyPath(AVPlayerItem.status), context: &self.playerItemContext)
            self.player.removeObserver(self, forKeyPath: "currentItem.loadedTimeRanges", context: nil)
            
        }
        
        
        self.backImage.isHidden = false
        
        if postAtIndex != (postUUID.count - 1) {
            var nextVid = globalTypeArray[postAtIndex + 1]
            
            if nextVid == "video" {
                nextItemIsVideo = true
            } else {
                nextItemIsVideo = false
            }
            
        }
        if postAtIndex != 0 {
            var previousVid = globalTypeArray[postAtIndex - 1]
            
            if previousVid == "video" {
                previousItemIsVideo = true
            } else {
                previousItemIsVideo = false
            }
            
        }
        
       
        
        var shouldRun = false
        var isUp = true
        let max = postUUID.count
        if sender.direction == .up {
            isUp = true
            if (postAtIndex) == (max - 1) {
                shouldRun = false
            } else {
                shouldRun = true
                
                postAtIndex = postAtIndex + 1
            }
        } else {
            isUp = false
            if (postAtIndex) == (0) {
                shouldRun = false
            } else {
                shouldRun = true
                postAtIndex = postAtIndex - 1
            }
        }
      
        
        if shouldRun == true {
            
            
            
            if picPost.isHidden == true {
                print("picpost is hidden")
                
                if let currentItem = player.currentItem {
                    let imageGenerator = AVAssetImageGenerator(asset: currentItem.asset)
                    if let image = try? imageGenerator.copyCGImage(at: currentItem.currentTime(), actualTime: nil) {
                        let uiImage = UIImage(cgImage: image, scale: 0.5, orientation: UIImageOrientation.right)
                        backImage.image = uiImage
                        
                        UIGraphicsBeginImageContext(self.view.frame.size)
                        if let ctx = UIGraphicsGetCurrentContext() {
                            self.videoView.isHidden = true
                            self.view.layer.render(in: ctx)
                            let thisImage = UIGraphicsGetImageFromCurrentImageContext()
                            backImage.image = thisImage
                            self.videoView.isHidden = false
                            videoOverlay.image = nil
                            UIGraphicsEndImageContext()
                            
                        }
                        player.replaceCurrentItem(with: nil)
                        player.pause()
                        
                    }
                }
                
                
               
            } else {
                backImage.image = picPost.image
            }
            
            
            
            
            
            
            picPost.image = nil
            print(isUp)
            if isUp == true {
                //backImage.frame = CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: self.view.frame.size.height)
                if nextItemIsVideo == true {
                    picPost.isHidden = true
                    videoView.isHidden = false
                    videoView.backgroundColor = .black
                    videoOverlay.isHidden = false
                    videoView.frame = CGRect(x: 0, y: self.view.frame.size.height, width: self.view.frame.size.width, height: self.view.frame.size.height)
                    videoOverlay.frame = CGRect(x: 0, y: self.view.frame.size.height, width: self.view.frame.size.width, height: self.view.frame.size.height)
                } else {
                    videoView.isHidden = true
                    videoOverlay.isHidden = true
                    picPost.isHidden = false
                    picPost.frame = CGRect(x: 0, y: self.view.frame.size.height, width: self.view.frame.size.width, height: self.view.frame.size.height)
                }
                UIView.animate(withDuration: 0.5, animations: {
                    
                    //self.backImage.frame = CGRect(x: 0, y: 0, width: self.backImage.frame.size.width, height: 0)
                    //self.backImage.frame.offsetBy(dx: 0, dy: -1000)
                    self.picPost.frame = CGRect(x: 0, y: 0, width: self.picPost.frame.size.width, height: self.picPost.frame.size.height)
                    self.videoView.frame = CGRect(x: 0, y: 0, width: self.picPost.frame.size.width, height: self.picPost.frame.size.height)
                    self.videoOverlay.frame = CGRect(x: 0, y: 0, width: self.picPost.frame.size.width, height: self.picPost.frame.size.height)
                   
                })
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: {
                    self.backImage.isHidden = true
                })
                
            } else {
                
                if previousItemIsVideo == true {
                    picPost.isHidden = true
                    videoView.isHidden = false
                    videoView.backgroundColor = .black
                    videoOverlay.isHidden = false
                    videoView.frame = CGRect(x: 0, y: -self.view.frame.size.height, width: self.view.frame.size.width, height: self.view.frame.size.height)
                    videoOverlay.frame = CGRect(x: 0, y: -self.view.frame.size.height, width: self.view.frame.size.width, height: self.view.frame.size.height)
                    
                } else {
                    
                    videoView.isHidden = true
                    videoOverlay.isHidden = true
                    picPost.isHidden = false
                    picPost.frame = CGRect(x: 0, y: -self.view.frame.size.height, width: self.view.frame.size.width, height: self.view.frame.size.height)
                }
                UIView.animate(withDuration: 0.5, animations: {
                    
                    self.videoView.frame = CGRect(x: 0, y: 0, width: self.picPost.frame.size.width, height: self.picPost.frame.size.height)
                    self.videoOverlay.frame = CGRect(x: 0, y: 0, width: self.picPost.frame.size.width, height: self.picPost.frame.size.height)
                    self.picPost.frame = CGRect(x: 0, y: 0, width: self.picPost.frame.size.width, height: self.picPost.frame.size.height)
                    
                })
                
            }
            
            var getPost = postUUID[postAtIndex]
            
            let postQuery = PFQuery(className: "posts")
            //postQuery.whereKey("uuid", equalTo: postUUID.last!)
            postQuery.whereKey("uuid", equalTo: getPost)
            postQuery.findObjectsInBackground (block: { (objects, error) -> Void in
                if error == nil {
                    
                    
                    for object in objects! {
                        
                        
                        self.postUsername = object.value(forKey: "username") as? String
                        self.postDate = object.createdAt
                        self.postPicture = object.value(forKey: "media") as? PFFile
                        self.postUuid = object.value(forKey: "uuid") as? String
                        self.postTitle = object.value(forKey: "title") as? String
                        self.postMediaType = object.value(forKey: "mediatype") as? String
                        self.photoOverlayForVideo = object.value(forKey: "photoLayer") as? PFFile
                        self.postOverUnder = object.value(forKey: "time") as? String
                        
                        if self.postUsername == PFUser.current()?.username {
                            self.userStack.isHidden = false
                            self.followerStack.isHidden = true
                            self.userStack.isUserInteractionEnabled = true
                            self.followerStack.isUserInteractionEnabled = false
                        } else {
                            self.userStack.isHidden = true
                            self.followerStack.isHidden = false
                            self.userStack.isUserInteractionEnabled = false
                            self.followerStack.isUserInteractionEnabled = true
                        }
                        
                        
                        
                        
                        self.username.setTitle(self.postUsername, for: UIControlState.normal)
                        
                        //self.username.sizeToFit()
                        self.uuid.text = self.postUuid
                        self.comment.text = self.postTitle
                        let type = self.postMediaType
                        
                        self.checkForCommentSegue()
                        
                        if type == "photo" {
                            
                            self.removeObservers = false
                            
                            self.videoView.isHidden = true
                            self.videoOverlay.isHidden = true
                            
                            self.postPicture.getDataInBackground { (data, error) -> Void in
                                if error == nil {
                                    
                                    self.picPost.image = UIImage(data: data!)
                                    //self.backImage.image = UIImage(data: data!)
                                    
                                    
                                } else {
                                    self.parseErrorAlert()
                                    print(error!.localizedDescription)
                                }}
                            
                        } else if type == "video" {
                            
                        
                            
                            self.picPost.isHidden = true
                            self.videoView.isHidden = false
                            
                            var videoUrl: String!
                            var videoFile: PFFile
                            
                            
                            let videoURL = self.postPicture.url
                            
                            
                            func setupVideoPlayerWithURL(url:NSURL) {
                                
                                
                                
                                //let notStarted = CMTime(seconds: 0.0, preferredTimescale: 1)
                                
                                //self.player.automaticallyWaitsToMinimizeStalling = false
                                self.player = AVPlayer(url: url as URL)
                                self.player.addObserver(self,
                                                        forKeyPath: #keyPath(AVPlayerItem.status),
                                                        options: [.old, .new],
                                                        context: &self.playerItemContext)
                                self.player.addObserver(self, forKeyPath: "currentItem.loadedTimeRanges", options: .new, context: nil)
                                self.removeObservers = true
                                self.playerLayer = AVPlayerLayer(player: self.player)
                                self.playerLayer.videoGravity = AVLayerVideoGravity.resizeAspectFill
                                self.playerLayer.frame = self.view.frame   // take up entire screen
                                self.videoView.layer.addSublayer(self.playerLayer)
                                self.loadingIndicator.startAnimating()
                                //self.player.playImmediately(atRate: 1.0)
                                
                                self.player.play()
                                //self.player.play()
                                // print(self.player.currentTime())
                                
                                //self.player.play()
                                loopVideo(videoPlayer: self.player)
                                //self.loadingIndicator.stopAnimating()
                            }
                            
                            func loopVideo(videoPlayer: AVPlayer) {
                                NotificationCenter.default.addObserver(forName: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: nil, queue: nil) { notification in
                                    videoPlayer.seek(to: kCMTimeZero)
                                    videoPlayer.play()
                                }
                            }
                            
                       
                            
                            
                            setupVideoPlayerWithURL(url: NSURL(string: videoURL!)!)
                            
                            
                            self.photoOverlayForVideo.getDataInBackground { (data, error) -> Void in
                                if error == nil {
                                    
                                    self.videoOverlay.image = UIImage(data: data!)
                                    
                                    
                                } else {
                                    self.parseErrorAlert()
                                    print(error!.localizedDescription)
                                }}
                            /*
                             let time = CMTime(value: 0, timescale: 1)
                             repeat {
                             
                             if time != self.player.currentTime() {
                             self.loadingIndicatorView.stopAnimating()
                             }
                             
                             }while self.player.currentTime() == time
                             
                             
                             */
                            
                            
                            
                        }
                        
                        
                        
                        
                        
                        
                        
                        
                        
                        let from = self.postDate
                        let now = Date()
                        let components : NSCalendar.Unit = [.second, .minute, .hour, .day, .weekOfMonth]
                        let difference = (Calendar.current as NSCalendar).components(components, from: from!, to: now, options: [])
                        
                        
                        
                        if difference.second! <= 0 {
                            let timeQuery = PFQuery(className: "posts")
                            timeQuery.whereKey("uuid", equalTo: self.uuid.text!)
                            // timeQuery.whereKey("username", equalTo: PFUser.current()!.username!)
                            timeQuery.findObjectsInBackground(block: { (objects, error) in
                                if error == nil {
                                    
                                    for object in objects! {
                                        
                                        object["time"] = "under"
                                        
                                        object.saveEventually()
                                    }
                                    
                                } else {
                                    self.parseErrorAlert()
                                    print(error!.localizedDescription)
                                }
                            })
                            self.time.text = "now"
                        }
                        if difference.second! > 0 && difference.minute! == 0 {
                            self.time.text = "\(difference.second!)s"
                        }
                        if difference.minute! > 0 && difference.hour! == 0 {
                            self.time.text = "\(difference.minute!)m"
                        }
                        if difference.hour! > 0 && difference.day! == 0 {
                            self.time.text = "\(difference.hour!)h"
                        }
                        if difference.day! > 0 && difference.weekOfMonth! == 0 {
                            
                            let timeQuery = PFQuery(className: "posts")
                            timeQuery.whereKey("uuid", equalTo: self.uuid.text!)
                            //  timeQuery.whereKey("username", equalTo: PFUser.current()!.username!)
                            timeQuery.findObjectsInBackground(block: { (objects, error) in
                                if error == nil {
                                    
                                    for object in objects! {
                                        
                                        object["time"] = "over"
                                        
                                        object.saveEventually()
                                    }
                                    
                                } else {
                                    self.parseErrorAlert()
                                    print(error!.localizedDescription)
                                }
                            })
                            
                            self.time.text = "\(difference.day!)d"
                        }
                        if difference.weekOfMonth! > 0 {
                            self.time.text = "\(difference.weekOfMonth!)w"
                        }
                        
                        if (self.comment.text?.isEmpty)! {
                            self.comment.isHidden = true
                        }
                        /*
                        self.comment.userHandleLinkTapHandler = { label, handle, range in
                            var mention = handle
                            // mention = String(mention.characters.dropFirst())
                            mention = String(mention.dropFirst()) //new one
                            
                            // if tapped on @currentUser go home, else go guest
                            if mention == PFUser.current()?.username {
                                let home = self.storyboard?.instantiateViewController(withIdentifier: "HomePageVC") as! HomePageVC
                                self.navigationController?.pushViewController(home, animated: true)
                            } else {
                                friendName.append(mention)
                                let guest = self.storyboard?.instantiateViewController(withIdentifier: "FriendProfileVC") as! FriendProfileVC
                                self.navigationController?.pushViewController(guest, animated: true)
                            }
                        }
                        
                        
                        
                        self.comment.hashtagLinkTapHandler = { label, handle, range in
                            var mention = handle
                            mention = String(mention.dropFirst())
                            hashtag.append(mention)
                            
                            let theHashtag = self.storyboard?.instantiateViewController(withIdentifier: "HashtagVC") as! HashtagVC
                            self.navigationController?.pushViewController(theHashtag, animated: true)
                            
                        }
                        */
                        
                        
                        
                        if self.postUsername != PFUser.current()?.username {
                            
                            self.pinButton.isHidden = true
                            // self.pinButton.frame.size.width = 0
                            // self.likeCount.frame.size.width = 40
                            
                        } else {
                            
                            self.pinButton.isHidden = false
                            let didPin = PFQuery(className: "posts")
                            didPin.whereKey("uuid", equalTo: self.uuid.text!)
                            didPin.whereKey("pinned", equalTo: true)
                            didPin.whereKey("username", equalTo: PFUser.current()!.username!)
                            didPin.countObjectsInBackground(block: { (count, error) in
                                if error == nil {
                                    
                                    if count == 0 {
                                        //  self.pin = false
                                        self.pinButton.setTitle("Pin", for: UIControlState.normal)
                                        self.pinButton.setBackgroundImage(UIImage(named: "UnpinButton.png"), for: UIControlState.normal)
                                        
                                    } else {
                                        // self.pin = true
                                        self.pinButton.setTitle("Unpin", for: UIControlState.normal)
                                        self.pinButton.setBackgroundImage(UIImage(named: "PinButton.png"), for: UIControlState.normal)
                                    }
                                    
                                } else {
                                    print(error!.localizedDescription)
                                    self.parseErrorAlert()
                                }
                            })
                            
                        }
                        
                        
                        let didLike = PFQuery(className: "likes")
                        didLike.whereKey("by", equalTo: PFUser.current()!.username!)
                        didLike.whereKey("to", equalTo: self.uuid.text!)
                        didLike.countObjectsInBackground { (count, error) in
                            if error == nil {
                                
                                
                                if count == 0 {
                                    
                                    if self.postUsername == PFUser.current()?.username {
                                        
                                        self.likeButton.setTitle("unlike", for: UIControlState.normal)
                                        self.likeButton.setBackgroundImage(UIImage(named: "unlike.png"), for: UIControlState.normal)
                                        
                                    } else {
                                        
                                        self.followerLikeButton.setTitle("unlike", for: UIControlState.normal)
                                        self.followerLikeButton.setBackgroundImage(UIImage(named: "unlike.png"), for: UIControlState.normal)
                                        
                                        
                                    }
                                    
                                    
                                    
                                } else {
                                    if self.postUsername == PFUser.current()?.username {
                                        
                                        
                                        self.likeButton.setTitle("like", for: UIControlState.normal)
                                        self.likeButton.setBackgroundImage(UIImage(named: "like.png"), for: UIControlState.normal)
                                    } else {
                                        
                                        self.followerLikeButton.setTitle("like", for: UIControlState.normal)
                                        self.followerLikeButton.setBackgroundImage(UIImage(named: "like.png"), for: UIControlState.normal)
                                        
                                        
                                    }
                                }
                            } else {
                                print(error!.localizedDescription)
                                self.parseErrorAlert()
                            }
                        }
                        
                        
                        
                        
                        
                        
                        let countLikes = PFQuery(className: "likes")
                        countLikes.whereKey("to", equalTo: self.uuid.text!)
                        countLikes.countObjectsInBackground { (count, error) in
                            if error == nil {
                                
                                if self.postUsername == PFUser.current()?.username {
                                    
                                    if count == 0 {
                                        //cell.likeCount.text = "\(count)"
                                        self.likeCount.setTitle("\(count)", for: .normal)
                                        //cell.likeCount.isHidden = true
                                        self.likeCount.setTitleColor(.clear, for: UIControlState.normal)
                                        self.likeCount.isEnabled = false
                                        
                                    } else {
                                        
                                        self.likeCount.setTitle("\(count)", for: UIControlState.normal)
                                        
                                        // cell.likeCount.isHidden = false
                                        self.likeCount.setTitleColor(.white, for: UIControlState.normal)
                                        self.likeCount.isEnabled = true
                                    }
                                } else {
                                    
                                    if count == 0 {
                                        //cell.likeCount.text = "\(count)"
                                        self.followerLikeCount.setTitle("\(count)", for: .normal)
                                        //cell.likeCount.isHidden = true
                                        self.followerLikeCount.setTitleColor(.clear, for: UIControlState.normal)
                                        self.followerLikeCount.isEnabled = false
                                        
                                    } else {
                                        
                                        self.followerLikeCount.setTitle("\(count)", for: UIControlState.normal)
                                        
                                        // cell.likeCount.isHidden = false
                                        self.followerLikeCount.setTitleColor(.white, for: UIControlState.normal)
                                        self.followerLikeCount.isEnabled = true
                                    }
                                    
                                    
                                }
                                
                            } else {
                                self.parseErrorAlert()
                                print(error!.localizedDescription)
                            }
                            
                            
                            
                            
                        }
                        
                        
                        
                        
                        
                        self.picPost.frame = CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: self.view.frame.size.height)
                        
                        
                        self.navigationController?.navigationBar.isHidden = true
                        self.tabBarController?.tabBar.isHidden = true
                        
                        //self.username.layer.setValue(indexPath, forKey: "index")
                        
                        //self.commentButton.layer.setValue(indexPath, forKey: "index")
                        
                        //self.moreButton.layer.setValue(indexPath, forKey: "index")
                        
                    }
                }
            })
        }
        
       
    }
    
    

    
    
    override func observeValue(forKeyPath keyPath: String?,
                               of object: Any?,
                               change: [NSKeyValueChangeKey : Any]?,
                               context: UnsafeMutableRawPointer?) {
        
     
        if keyPath == "currentItem.loadedTimeRanges" {
            
            if player.timeControlStatus == .playing {
                
                loadingIndicator.stopAnimating()
            } else {
                print("not yet loaded")
            }
        }
 
       
        
        
        
        
        
        if keyPath == #keyPath(AVPlayerItem.status) {
            let status: AVPlayerItemStatus
            
            
            
            // Get the status change from the change dictionary
            if let statusNumber = change?[.newKey] as? NSNumber {
                status = AVPlayerItemStatus(rawValue: statusNumber.intValue)!
            } else {
                status = .unknown
            }
            
            
            
            // Switch over the status
            switch status {
            case .readyToPlay:
               // loadingIndicator.stopAnimating()
                print("ready to play")
            // Player item is ready to play.
            case .failed:
                print("failed")
            // Player item failed. See error.
            case .unknown:
                print("not ready")
                loadingIndicator.startAnimating()
                
           
           
            }
        }
    }
    
 
    
    
    @IBAction func viewLikers(_ sender: AnyObject) {
        
        
        
        postUUID.append(uuid.text!)
        
        let likers = self.storyboard?.instantiateViewController(withIdentifier: "UsersWhoLikedVC") as! UsersWhoLikedVC
        
        self.navigationController?.pushViewController(likers, animated: true)
        
        //  self.dismiss(animated: true, completion: theSegue )
        
        
        
        
        // self.performSegue(withIdentifier: "likers", sender: self)
        
    }
    
    func theSegue() {
        let likers = self.storyboard?.instantiateViewController(withIdentifier: "UsersWhoLikedVC") as! UsersWhoLikedVC
        
        self.navigationController?.pushViewController(likers, animated: true)
        
    }
    
    
    
    @IBAction func usernameClick(_ sender: AnyObject) {
        
  
        if self.username.titleLabel?.text == PFUser.current()?.username {
            let home = self.storyboard?.instantiateViewController(withIdentifier: "HomePageVC") as! HomePageVC
            self.navigationController?.pushViewController(home, animated: true)
            
        }
        else {
            friendName.append(self.username.titleLabel!.text!)
            let friend = self.storyboard?.instantiateViewController(withIdentifier: "FriendProfileVC") as! FriendProfileVC
            self.navigationController?.pushViewController(friend, animated: true)
        }

    }
    
    
    
    
    
    @IBAction func likeButtonClick(_ sender: AnyObject) {
        
        generator.impactOccurred()
        
        
        

        
       
        if username.titleLabel?.text == PFUser.current()?.username {
       
        self.likeButton.isUserInteractionEnabled = false
        var likeNumber: Int?
        
        //let number = Int(cell.likeCount.text!)!
        let number = Int((self.likeCount.titleLabel?.text!)!)
        
        if self.likeButton.titleLabel?.text == "unlike" {
            
            if sendNotification == true {
                
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "likedPost"), object: nil)
            }
            
            UIView.animate(withDuration: 0.5) { () -> Void in
                self.likeButton.transform = CGAffineTransform(rotationAngle: CGFloat.pi)
            }
            
            UIView.animate(withDuration: 0.5, delay: 0, options: UIViewAnimationOptions.curveEaseIn, animations: { () -> Void in
                self.likeButton.transform = CGAffineTransform(rotationAngle: CGFloat.pi * 2.0)
            }, completion: nil)
            
            self.likeButton.setTitle("like", for: UIControlState.normal)
            
            
            
            self.likeButton.setBackgroundImage(UIImage(named: "like.png"), for: UIControlState.normal)
            
            
            
            let object = PFObject(className: "likes")
            object["by"] = PFUser.current()?.username
            object["to"] = self.uuid.text!
            object.saveInBackground(block: { (success, error) in
                if error == nil {
                    
                    if number == 0 {
                        likeNumber = Int((self.likeCount.titleLabel?.text!)!)! + 1
                        //likeNumber = Int(cell.likeCount.text!)! + 1
                        // cell.likeCount.text = String(likeNumber!)
                        self.likeCount.setTitle(String(likeNumber!), for: .normal)
                        //cell.likeCount.isHidden = false
                        self.likeCount.setTitleColor(.white, for: UIControlState.normal)
                        self.likeCount.isEnabled = true
                    } else {
                        likeNumber = Int((self.likeCount.titleLabel?.text!)!)! + 1
                        //likeNumber = Int(cell.likeCount.text!)! + 1
                        // cell.likeCount.text = String(likeNumber!)
                        self.likeCount.setTitle(String(likeNumber!), for: .normal)
                        // cell.likeCount.isHidden = false
                        self.likeCount.setTitleColor(.white, for: UIControlState.normal)
                        self.likeCount.isEnabled = true
                    }
                    
                    if self.username.titleLabel!.text! != PFUser.current()?.username {
                        
                        let notificationObject = PFObject(className: "notification")
                        notificationObject["by"] = PFUser.current()?.username
                        notificationObject["profilepic"] = PFUser.current()?.object(forKey: "profilepic") as! PFFile
                        notificationObject["to"] = self.username.titleLabel!.text!
                        notificationObject["owner"] = self.username.titleLabel!.text!
                        notificationObject["uuid"] = self.uuid.text
                        notificationObject["type"] = "like"
                        notificationObject["checked"] = "no"
                        notificationObject.saveInBackground(block: { (success, error) in
                            if error != nil {
                                print(error!.localizedDescription)
                            }
                        })
                        
                    }
                    
                } else {
                    print(error!.localizedDescription)
                    self.parseErrorAlert()
                }
            }
            )}
            
        else if self.likeButton.titleLabel?.text == "like" {
            
            if sendNotification == true {
                
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "unlikedPost"), object: nil)
            }
            
            
            self.likeButton.setTitle("unlike", for: UIControlState.normal)
            
            self.likeButton.setBackgroundImage(UIImage(named: "unlike.png"), for: UIControlState.normal)
            
            
            
            let query = PFQuery(className: "likes")
            query.whereKey("by", equalTo: PFUser.current()!.username!)
            query.whereKey("to", equalTo: self.uuid.text!)
            query.findObjectsInBackground(block: { (objects, error) in
                for object in objects! {
                    object.deleteInBackground(block: { (success, error) in
                        if error == nil {
                            
                            if number == 1 {
                                
                                //likeNumber = Int(cell.likeCount.text!)! - 1
                                likeNumber = Int((self.likeCount.titleLabel?.text!)!)! - 1
                                //cell.likeCount.text = String(likeNumber!)
                                self.likeCount.setTitle(String(likeNumber!), for: .normal)
                                //cell.likeCount.isHidden = true
                                self.likeCount.setTitleColor(.clear, for: UIControlState.normal)
                                self.likeCount.isEnabled = false
                                
                            } else {
                                likeNumber = Int((self.likeCount.titleLabel?.text!)!)! - 1
                                //likeNumber = Int(cell.likeCount.text!)! - 1
                                //cell.likeCount.text = String(likeNumber!)
                                self.likeCount.setTitle(String(likeNumber!), for: .normal)
                                //cell.likeCount.isHidden = false
                                self.likeCount.setTitleColor(.white, for: UIControlState.normal)
                                self.likeCount.isEnabled = true
                                
                            }
                            
                            let notificationQuery = PFQuery(className: "notification")
                            notificationQuery.whereKey("to", equalTo: self.username.titleLabel!.text!)
                            notificationQuery.whereKey("by", equalTo: PFUser.current()!.username!)
                            notificationQuery.whereKey("uuid", equalTo: self.uuid.text!)
                            notificationQuery.whereKey("type", equalTo: "like")
                            notificationQuery.findObjectsInBackground(block: { (objects, error) in
                                if error == nil {
                                    
                                    for object in objects! {
                                        
                                        object.deleteEventually()
                                        
                                    }
                                    
                                    
                                } else {
                                    print(error!.localizedDescription)
                                    self.parseErrorAlert()
                                }
                            })
                            
                            
                            
                            
                        } else {
                            print(error!.localizedDescription)
                            self.parseErrorAlert()
                        }
                    }
                    )}
            }
            )}
        } else {
            
            
            self.followerLikeButton.isUserInteractionEnabled = false
            var likeNumber: Int?
            
            //let number = Int(cell.likeCount.text!)!
            let number = Int((self.followerLikeCount.titleLabel?.text!)!)
            
            if self.followerLikeButton.titleLabel?.text == "unlike" {
                
                if sendNotification == true {
                    
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: "likedPost"), object: nil)
                }
                
                /*UIView.animate(withDuration: 0.8, animations: {
                    
                
                    self.followerLikeButton.transform = self.followerLikeButton.transform.rotated(by: 720)
                    
                    })
                */
                
                UIView.animate(withDuration: 0.5) { () -> Void in
                    self.followerLikeButton.transform = CGAffineTransform(rotationAngle: CGFloat.pi)
                }
                
                UIView.animate(withDuration: 0.5, delay: 0, options: UIViewAnimationOptions.curveEaseIn, animations: { () -> Void in
                    self.followerLikeButton.transform = CGAffineTransform(rotationAngle: CGFloat.pi * 2.0)
                }, completion: nil)
 
                self.followerLikeButton.setTitle("like", for: UIControlState.normal)
                
                
                
                self.followerLikeButton.setBackgroundImage(UIImage(named: "like.png"), for: UIControlState.normal)
                
                
                
                let object = PFObject(className: "likes")
                object["by"] = PFUser.current()?.username
                object["to"] = self.uuid.text!
                object.saveInBackground(block: { (success, error) in
                    if error == nil {
                        
                        if number == 0 {
                            likeNumber = Int((self.followerLikeCount.titleLabel?.text!)!)! + 1
                            //likeNumber = Int(cell.likeCount.text!)! + 1
                            // cell.likeCount.text = String(likeNumber!)
                            self.followerLikeCount.setTitle(String(likeNumber!), for: .normal)
                            //cell.likeCount.isHidden = false
                            self.followerLikeCount.setTitleColor(.white, for: UIControlState.normal)
                            self.followerLikeCount.isEnabled = true
                        } else {
                            likeNumber = Int((self.followerLikeCount.titleLabel?.text!)!)! + 1
                            //likeNumber = Int(cell.likeCount.text!)! + 1
                            // cell.likeCount.text = String(likeNumber!)
                            self.followerLikeCount.setTitle(String(likeNumber!), for: .normal)
                            // cell.likeCount.isHidden = false
                            self.followerLikeCount.setTitleColor(.white, for: UIControlState.normal)
                            self.followerLikeCount.isEnabled = true
                        }
                        
                        if self.username.titleLabel!.text! != PFUser.current()?.username {
                            
                            let notificationObject = PFObject(className: "notification")
                            notificationObject["by"] = PFUser.current()?.username
                            notificationObject["profilepic"] = PFUser.current()?.object(forKey: "profilepic") as! PFFile
                            notificationObject["to"] = self.username.titleLabel!.text!
                            notificationObject["owner"] = self.username.titleLabel!.text!
                            notificationObject["uuid"] = self.uuid.text
                            notificationObject["type"] = "like"
                            notificationObject["checked"] = "no"
                            notificationObject.saveInBackground(block: { (success, error) in
                                if error == nil {
                                    let push = PushNotifications()
                                    guard let name = self.username.titleLabel?.text else {return}
                                    push.pushLikeNotification(username: name)
                                }
                            })
                            
                        }
                        
                    } else {
                        print(error!.localizedDescription)
                        self.parseErrorAlert()
                    }
                }
                )}
                
            else if self.followerLikeButton.titleLabel?.text == "like" {
                
                
                if sendNotification == true {
                    
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: "unlikedPost"), object: nil)
                }
                
                
                
                self.followerLikeButton.setTitle("unlike", for: UIControlState.normal)
                
                self.followerLikeButton.setBackgroundImage(UIImage(named: "unlike.png"), for: UIControlState.normal)
                
                
                
                let query = PFQuery(className: "likes")
                query.whereKey("by", equalTo: PFUser.current()!.username!)
                query.whereKey("to", equalTo: self.uuid.text!)
                query.findObjectsInBackground(block: { (objects, error) in
                    for object in objects! {
                        object.deleteInBackground(block: { (success, error) in
                            if error == nil {
                                
                                if number == 1 {
                                    
                                    //likeNumber = Int(cell.likeCount.text!)! - 1
                                    likeNumber = Int((self.followerLikeCount.titleLabel?.text!)!)! - 1
                                    //cell.likeCount.text = String(likeNumber!)
                                    self.followerLikeCount.setTitle(String(likeNumber!), for: .normal)
                                    //cell.likeCount.isHidden = true
                                    self.followerLikeCount.setTitleColor(.clear, for: UIControlState.normal)
                                    self.followerLikeCount.isEnabled = false
                                } else {
                                    likeNumber = Int((self.followerLikeCount.titleLabel?.text!)!)! - 1
                                    //likeNumber = Int(cell.likeCount.text!)! - 1
                                    //cell.likeCount.text = String(likeNumber!)
                                    self.followerLikeCount.setTitle(String(likeNumber!), for: .normal)
                                    //cell.likeCount.isHidden = false
                                    self.followerLikeCount.setTitleColor(.white, for: UIControlState.normal)
                                    
                                    self.followerLikeCount.isEnabled = true
                                    
                                }
                                
                                let notificationQuery = PFQuery(className: "notification")
                                notificationQuery.whereKey("to", equalTo: self.username.titleLabel!.text!)
                                notificationQuery.whereKey("by", equalTo: PFUser.current()!.username!)
                                notificationQuery.whereKey("uuid", equalTo: self.uuid.text!)
                                notificationQuery.whereKey("type", equalTo: "like")
                                notificationQuery.findObjectsInBackground(block: { (objects, error) in
                                    if error == nil {
                                        
                                        for object in objects! {
                                            
                                            object.deleteEventually()
                                            
                                        }
                                        
                                        
                                    } else {
                                        print(error!.localizedDescription)
                                        self.parseErrorAlert()
                                    }
                                })
                                
                                
                                
                                
                            } else {
                                print(error!.localizedDescription)
                                self.parseErrorAlert()
                            }
                        }
                        )}
                }
                )}
            
            
            
            self.followerLikeButton.isUserInteractionEnabled = true
            
            
            
            
        }
        self.likeButton.isUserInteractionEnabled = true

    }
    
    
    
    
    @IBAction func pinPost(_ sender: AnyObject) {
        generator.impactOccurred()
        if self.pinButton.titleLabel?.text == "Pin" {
            // if pin == true {
            
            
            self.pinButton.setTitle("Unpin", for: UIControlState.normal)
            
            self.pinButton.setBackgroundImage(UIImage(named: "PinButton.png"), for: UIControlState.normal)
            let findPin = PFQuery(className: "posts")
            findPin.whereKey("uuid", equalTo: self.uuid.text!)
            findPin.findObjectsInBackground { (objects, error) in
                if error == nil {
                    
                    for object in objects! {
                        
                        object["pinned"] = true
                        object.saveEventually()
                        
                    }
                    
                } else {
                    self.parseErrorAlert()
                    print(error!.localizedDescription)
                }
               
            }
            
        } else if self.pinButton.titleLabel?.text == "Unpin" {
            
            // cell.pinButton.titleLabel?.text = "Unpin"
            self.pinButton.setTitle("Pin", for: UIControlState.normal)
            
            self.pinButton.setBackgroundImage(UIImage(named: "UnpinButton.png"), for: UIControlState.normal)
            let findPin = PFQuery(className: "posts")
            findPin.whereKey("uuid", equalTo: self.uuid.text!)
            findPin.findObjectsInBackground { (objects, error) in
                if error == nil {
                    
                    for object in objects! {
                        
                        object["pinned"] = false
                        object.saveEventually()
                        
                    }
                    
                } else {
                    print(error!.localizedDescription)
                    self.parseErrorAlert()
                }
            }
    
        }
        
        if self.pinButton.titleLabel?.text == "Pin" && self.postOverUnder == "over" {
            print("are you sure")
            pinAlert(title: "Are you sure?", message: "This post is over the 24 hour time limit. If it is untacked, it will not be able to be recovered.")
            
        }
  
    }
    
    
    
    
    
    
    
    @IBAction func commentButtonClicked(_ sender: AnyObject) {
        
        print("hello")
        
        self.tabBarController?.tabBar.isHidden = false
        
        commentuuid.append(self.uuid.text!)
        commentowner.append(self.username.titleLabel!.text!)
        
        
        let comment = self.storyboard?.instantiateViewController(withIdentifier: "CommentViewController") as! CommentViewController
        
        self.navigationController?.pushViewController(comment, animated: true)
        
        
        //  self.performSegue(withIdentifier: "comment", sender: nil)
        
        
        
       
        //self.navigationController?.present(comment, animated: true, completion:  nil)
        // self.navigationController?.show(comment, sender: self)
        
    }
    
    
    
    
    @IBAction func optionsClick(_ sender: AnyObject) {
       
        let delete = UIAlertAction(title: "Delete", style: .default) { (UIAlertAction) in
            
            self.dismiss(animated: true, completion:  nil)
            
            let postQuery = PFQuery(className: "posts")
            postQuery.whereKey("uuid", equalTo: self.uuid.text!)
            postQuery.findObjectsInBackground(block: { (objects, error) in
                if error == nil {
                    
                    for object in objects! {
                        
                        object.deleteInBackground(block: { (success, error) in
                            if error == nil {
                                
                                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "uploaded"), object: nil)
                                
                                self.navigationController?.popViewController(animated: true)
                                
                            } else {
                                self.parseErrorAlert()
                                print(error!.localizedDescription)
                            }
                        })
                        
                    }
                    
                    
                    
                } else {
                    self.parseErrorAlert()
                    print(error!.localizedDescription)
                }
            })
            
            
            let likeQuery = PFQuery(className: "likes")
            likeQuery.whereKey("to", equalTo: self.uuid.text!)
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
            commentQuery.whereKey("to", equalTo: self.uuid.text!)
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
            hashtagQuery.whereKey("to", equalTo: self.uuid.text!)
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
        }
        
        let complain = UIAlertAction(title: "Complain", style: .default) { (UIAlertAction) in
            let complainObject = PFObject(className: "complain")
            
            complainObject["by"] = PFUser.current()?.username
            complainObject["to"] = self.uuid.text
            complainObject["owner"] = self.username.titleLabel?.text
            complainObject.saveInBackground(block: { (success, error) in
                if error == nil {
                    self.alert(title: "Complaint Has Been Filed", message: "We have successfully recieved your complaint and will review the post as soon as we can. We thank you for your patience.")
                } else {
                    self.alert(title: "Error", message: error!.localizedDescription)
                }
            })
            
            
            
            
            
            
            
            
        }
        
        let savePicture = UIAlertAction(title: "Save Photo", style: .default) { (UIAlertAction) in
            let currentImage = self.picPost.image
            UIImageWriteToSavedPhotosAlbum(currentImage!, self, #selector(self.image(_:didFinishSavingWithError:contextInfo:)), nil)
        }
        
        
        
        
        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        let menu = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        if self.username.titleLabel?.text == PFUser.current()?.username {
            menu.addAction(delete)
            menu.addAction(cancel)
            menu.addAction(savePicture)
            
        } else {
            menu.addAction(complain)
            menu.addAction(cancel)
        }
        
        
        self.present(menu, animated: true, completion: nil)
        
        
        
        
    }
    
    @objc func image(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer) {
        
        if error == nil {
            print("saved")
        } else {
            let ac = UIAlertController(title: "Error", message: error?.localizedDescription, preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            present(ac, animated: true, completion: nil)
        }
    }
    
    func alert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
        let ok = UIAlertAction(title: "OK", style: UIAlertActionStyle.cancel, handler: nil)
        alert.addAction(ok)
        present(alert, animated: true, completion: nil)
    }
    
    
    
    @objc func back(_ sender: UIBarButtonItem) {
        
         NotificationCenter.default.post(name: NSNotification.Name(rawValue: "resumeMusic"), object: nil)
        self.navigationController?.popViewController(animated: true)
        //_ = self.navigationController?.popViewController(animated: true)
        
        self.navigationController?.navigationBar.isHidden = false
        self.tabBarController?.tabBar.isHidden = false
        
        if !postUUID.isEmpty {
            postUUID.removeLast()
            postUUID.removeAll(keepingCapacity: false)
        }
        
        player.replaceCurrentItem(with: nil)
        player.pause()
        
        //self.dismiss(animated: true, completion: nil)
        
       
        
        
    }
    
    @IBAction func backButton(_ sender: Any) {
        //self.dismiss(animated: true, completion: nil)
        self.navigationController?.popViewController(animated: true)
    }
    
    
    
    @IBAction func clearBack(_ sender: Any) {
        
        self.navigationController?.popViewController(animated: true)
        
    }
    
    /*
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == "duration", let duration = player.currentItem?.duration.seconds, duration > 0.0 {
            
            print("duration")
            
            self.timeObserver = getTimeString(from: player.currentItem!.duration)
            
            
        }
    }
    */
    
  
    
    
    
    
    func getTimeString(from time: CMTime) -> String {
        
        let totalSeconds = CMTimeGetSeconds(time)
        let hours = Int(totalSeconds/3600)
        let min = Int(totalSeconds/60) % 60
        let seconds = Int(totalSeconds.truncatingRemainder(dividingBy: 60))
        if hours > 0 {
            return String(format: "%i%02i:%02i", arguments: [hours, min, seconds])
        } else {
            return String(format: "%02i:%02i", arguments: [min, seconds])
        }
        
    }
    
    func addTimeObserver() {
        let interval = CMTime(seconds: 0.5, preferredTimescale: CMTimeScale(NSEC_PER_SEC))
        let mainQueue = DispatchQueue.main
        _ = player.addPeriodicTimeObserver(forInterval: interval, queue: mainQueue, using: { [weak self] time in
            guard let currentItem = self?.player.currentItem else {return}
            self?.timeObserver = self?.getTimeString(from: currentItem.currentTime())
            print("its working")
        })
    }
    
    
    func pinAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
       // let ok = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel, handler: nil)
        
        let ok = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.default) { (alert: UIAlertAction!) in
            
            self.pinButton.setTitle("Unpin", for: UIControlState.normal)
            
            self.pinButton.setBackgroundImage(UIImage(named: "PinButton.png"), for: UIControlState.normal)
            let findPin = PFQuery(className: "posts")
            findPin.whereKey("uuid", equalTo: self.uuid.text!)
            findPin.findObjectsInBackground { (objects, error) in
                if error == nil {
                    
                    for object in objects! {
                        
                        object["pinned"] = "yes"
                        object.saveEventually()
                        
                    }
                    
                } else {
                    self.parseErrorAlert()
                    print(error!.localizedDescription)
                }
                
            }
            
        }
        
        
        let unpin = UIAlertAction(title: "Unpin", style: UIAlertActionStyle.default) { (alert: UIAlertAction!) in
            print("unpinning")
            
            
                
                self.dismiss(animated: true, completion:  nil)
                
                let postQuery = PFQuery(className: "posts")
                postQuery.whereKey("uuid", equalTo: self.uuid.text!)
                postQuery.findObjectsInBackground(block: { (objects, error) in
                    if error == nil {
                        
                        for object in objects! {
                            
                            object.deleteInBackground(block: { (success, error) in
                                if error == nil {
                                    
                                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: "uploaded"), object: nil)
                                    
                                    self.navigationController?.popViewController(animated: true)
                                    
                                } else {
                                    self.parseErrorAlert()
                                    print(error!.localizedDescription)
                                }
                            })
                            
                        }
                        
                        
                        
                    } else {
                        self.parseErrorAlert()
                        print(error!.localizedDescription)
                    }
                })
            
            
            let likeQuery = PFQuery(className: "likes")
            likeQuery.whereKey("to", equalTo: self.uuid.text!)
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
            commentQuery.whereKey("to", equalTo: self.uuid.text!)
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
            hashtagQuery.whereKey("to", equalTo: self.uuid.text!)
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
            
        }
        alert.addAction(ok)
        alert.addAction(unpin)
        present(alert, animated: true, completion: nil)
        
        
    }
    
    
    
    
    
    
    
}

