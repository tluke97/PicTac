//
//  ArrangeVC.swift
//  CorkBoard
//
//  Created by Tanner Luke on 4/30/18.
//  Copyright © 2018 CorkBoard Co. All rights reserved.
//

import UIKit
import Parse
import AVFoundation

class ArrangeVC: UICollectionViewController {

    var postPicture: PFFile?
    var uuidArray = [String]()
    var picArray = [PFFile]()
    var mediaTypeArray = [String]()
    var timeArray = [Date?]()
    var player = AVPlayer()
    var playerLayer: AVPlayerLayer!
    var time: String!
    let width = UIScreen.main.bounds.width
    var currentImage: UIImage?
    var x = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        networkNotification()
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 10, right: 0)
        layout.itemSize = CGSize(width: (width/4)-1, height: (width/4)-1)
        layout.minimumInteritemSpacing = 0.5
        layout.minimumLineSpacing = 0.5
        collectionView!.collectionViewLayout = layout
        
        self.navigationItem.hidesBackButton = true
        let image = UIImage(named: "BackButton.png")
        let backButton = UIBarButtonItem(image: image!, style: UIBarButtonItemStyle.plain, target: self, action: #selector(ArrangeVC.saveAndDismiss))
        self.navigationItem.leftBarButtonItem = backButton
        
        let backSwipe = UISwipeGestureRecognizer(target: self, action: #selector(ArrangeVC.saveAndDismiss))
        backSwipe.direction = .right
        self.view.addGestureRecognizer(backSwipe)
        
        let long = UILongPressGestureRecognizer(target: self, action: #selector(longPressGesture(gesture:)))
        self.view.addGestureRecognizer(long)
        
        
        
        loadPosts()
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
    
    @IBAction func saveButton(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @objc func saveAndDismiss() {
        networkNotification()
        saveNewLayout()
        self.navigationController?.popViewController(animated: true)
    }
    
    
    func loadPosts() {
        let query = PFQuery(className: "posts")
        query.whereKey("username", equalTo: PFUser.current()!.username!)
        query.addAscendingOrder("index")
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
            }
            else{
                self.parseErrorAlert()
                print(error!.localizedDescription)
            }
        }
    }

    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return picArray.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, moveItemAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        updatePosition(startingLocation: sourceIndexPath.item, endingLocation: destinationIndexPath.item)
        print("Starting Index: \(sourceIndexPath.item)")
        print("Ending Index: \(destinationIndexPath.item)")
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as! pictureCell
        let type = mediaTypeArray[indexPath.row]
        let uuid = uuidArray[indexPath.row]
        if type == "photo" {
            //cell.type.isHidden = true
            cell.videoView.isHidden = true
            picArray[indexPath.row].getDataInBackground { (data, error) -> Void in
                if error == nil {
                    cell.pictureImage.image = UIImage(data: data!)
                    self.currentImage = cell.pictureImage.image
                } else {
                    self.parseErrorAlert()
                    print(error!.localizedDescription)
                }
            }
        } else if type == "video" {
            cell.videoView.isHidden = false
            //cell.type.isHidden = false
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
                        self.parseErrorAlert()
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
    
    override func collectionView(_ collectionView: UICollectionView, canMoveItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    @objc func longPressGesture(gesture: UILongPressGestureRecognizer) {
        switch gesture.state {
        case .began:
            guard let selectedIndexPath = collectionView?.indexPathForItem(at: gesture.location(in: collectionView)) else {
                break
            }
            collectionView?.beginInteractiveMovementForItem(at: selectedIndexPath)
        case .changed:
            collectionView?.updateInteractiveMovementTargetPosition(gesture.location(in: gesture.view))
        case .ended:
            //collectionView?.reloadData()
            collectionView?.endInteractiveMovement()
        default:
            collectionView?.cancelInteractiveMovement()
        }
    }
    
    func updatePosition(startingLocation: Int, endingLocation: Int) {
        let image = picArray[startingLocation]
        let uuid = uuidArray[startingLocation]
        let typeAtIndex = mediaTypeArray[startingLocation]
        
        
        self.picArray.remove(at: startingLocation)
        self.uuidArray.remove(at: startingLocation)
        self.mediaTypeArray.remove(at: startingLocation)
        self.mediaTypeArray.insert(typeAtIndex, at: endingLocation)
        self.picArray.insert(image, at: endingLocation)
        self.uuidArray.insert(uuid, at: endingLocation)
        
        
    }
    
    func saveNewLayout() {
        
        let lastNum = self.collectionView?.visibleCells.count
        var count = 1
        
        for cell in self.collectionView?.visibleCells as! [pictureCell] {
            
            let indexPath = collectionView?.indexPath(for: cell)
            
            
            let uuid = uuidArray[(indexPath?.row)!]
            let newIndexQuery = PFQuery(className: "posts")
            
            newIndexQuery.whereKey("uuid", equalTo: uuid)
            
            newIndexQuery.findObjectsInBackground { (objects, error) in
                if error == nil {
                    
                    for object in objects! {
                        //print(uuid)
                        object["index"] = indexPath?.row
                        
                        object.saveInBackground(block: { (success, error) in
                            if error == nil {
                                if count == lastNum {
                                    print("reloading")
                                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: "reloadTable"), object: nil)
                                }
                                count = count + 1
                                
                            } else {
                                self.parseErrorAlert()
                                print(error!.localizedDescription)
                            }
                        })
                    }
                    
                }
            }
            
            
        }
        
    }
   

}
